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

// - Rewards user for staking their tokens 
// - User can withdraw and deposit 
// - Earns token while withdrawing 

/// rewards are calculated with reward rate and time period staked for 

contract Staking{

    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint public rewardRate = 100 ;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored ; 

    // address of user to reward of user
    mapping(address => uint256) public rewards;
    
    // address of user to rewards per token
    mapping(address => uint256) public _rewardsPerToken;

    // address of user to staked amount
    mapping(address => uint256) public stakedAmount;

    // total supply of staked token in contract
    uint256 public _totalSupply;

    constructor(address _stakingToken, address _rewardsToken){
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function rewardsPerToken() public view returns (uint){
        if(totalSupply == 0){
            return _rewardsPerToken;
        }
        return rewardPerTokenStored + (((rewardRate * (block.timestamp - lastUpdateTime) * 1e18 )) / _totalSupply);
    }

    //to calculate the earned rewards for the token staked
    // account is address for which it is calculated
    // returns amount of earned rewards
    function earnedRewards(address _account) public view returns(uint256){
        return(
            (stakedAmount[_account] * ((rewardsPerToken() - rewardPerTokenStored[_account]) / 1e18)) + rewards[account];
        )
    }
}