// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// - Some amount of shares are minted when an users deposits
// - The DEFI protocol would use the user’s deposit to generate yield , the value of shares increases with yield .
// - User burn shares to withdraw 
/// user can deposit his money 
/// it wll mint some share
/// vault generate some yield
/// user can withdraw the shares with the increased amount 

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


contract Vault {

    IERC20 public immutable token;
    uint256 public totalSupply;

    mapping(address => uint) balanceOf;

    constructor(address _token){
        token = IERC20(_token);
    }

    function mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function burn(address _to, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_to] -= _shares;
    }

    function deposit(uint _amount) external {
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint shares;
        if(totalSupply == 0){
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }
        mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _amount) external {
        uint shares;
        shares = (_amount * totalSupply) / token.balanceOf(address(this));
        burn(msg.sender, shares);
        token.transfer(msg.sender, _amount);
    }
}