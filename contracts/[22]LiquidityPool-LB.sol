// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// liquidity pools can have multiple uses cases like lending-borrowing (similar to aave) or token swapping (similar to uniswap)
// this contract is a lending-borrowing contract
// a swap contract would need a pair of tokens but a lending-borrowing contract just need a single token with different lend and borrow rates.

// in this contract, a lender can deposit funds (provide liquidity) and gain interest on it
// a borrower can borrow funds (limited) and pay back with interest
// a lender can take out their funds with some interest

// it should contain
// -- lending 
// -- borrowing 
// -- repaying
// -- withdrawing 

contract LiquidityPool_LB {

    // token used for interest
    IERC20 token;
    uint256 totalSupply;

    // the rate earned by the lender per second (interest/second)
    uint256 lendrate = 100;
    // the rate paid by the borrower per second (interest/second)
    uint256 borrowrate = 130;

    uint256 periodBorrowed;

    // strcut containing amount borrowed or lended and the time of it
    struct aboutAmountandTime {
        uint amount;
        uint startAt;
    }

    // mapping to know if the lenders or borrowers have any lended or borrowed funds
    mapping (address => bool) lenders;
    mapping (address => bool) borrowers;

    // amount lent by a user in the protocol
    mapping (address => aboutAmountandTime) public lendAmount;
    // amount gained as interest when lending funds to the protocol (interest earned by lender) 
    mapping (address => uint256) public earnedInterest;

    // amount borrowed by a user in the protocol
    mapping (address => aboutAmountandTime) public borrowedAmount;
    // amount need to be paid as interest when borrowing funds to the protocol (interest to be paid by borrower) 
    mapping (address => uint256) public borrowedInterest;

    // adding tokens in the starting of the pool
    constructor (address _tokenAddress, uint _amount) payable {
        token = IERC20(_tokenAddress);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function lend(uint _amount) external {
        require(_amount != 0, "amount cannot be 0");

        // adding the lended amount to the pool
        token.transferFrom(msg.sender, address(this), _amount);

        lenders[msg.sender] = true;
        lendAmount[msg.sender].amount = _amount;
        lendAmount[msg.sender].startAt = block.timestamp;
        totalSupply += _amount;
    }

    function borrow(uint _amount) external {
        require(_amount < totalSupply, "pool does not have enough funds");
        require(_amount != 0, "amount cannot be 0");

        // updating records first
        borrowedAmount[msg.sender].amount = _amount;
        borrowedAmount[msg.sender].startAt = block.timestamp;
        borrowers[msg.sender] = true;
        totalSupply -= _amount;

        token.transferFrom(address(this), msg.sender, _amount);
    }

    function repay() external {
        require(borrowers[msg.sender] == true);
        uint _amount = borrowedAmount[msg.sender].amount;
        uint timeBorrowed = block.timestamp - borrowedAmount[msg.sender].startAt;
        uint amountToBeRepayed = (_amount + _amount * (timeBorrowed * borrowrate * 1e18)/totalSupply);

        require(amountToBeRepayed!= 0 ," amount can not be 0");

        token.transferFrom(msg.sender, address(this), amountToBeRepayed);

        totalSupply += amountToBeRepayed;
        borrowers[msg.sender] = false;
        delete borrowedAmount[msg.sender];
    }

    // lender can withdraw their funds 
    function withdraw() external {
        require(lenders[msg.sender] == true);
        uint _amount = lendAmount[msg.sender].amount;
        uint timeLended = block.timestamp - lendAmount[msg.sender].startAt;
        uint amountToGet = (_amount + _amount * (timeLended * lendrate * 1e18)/totalSupply);

        require(amountToGet!= 0 ," amount can not be 0");

        token.transferFrom(msg.sender, address(this), amountToGet);

        totalSupply -= amountToGet;
        borrowers[msg.sender] = false;
        delete lendAmount[msg.sender];
    }
}