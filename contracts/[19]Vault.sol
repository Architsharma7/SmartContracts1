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


}