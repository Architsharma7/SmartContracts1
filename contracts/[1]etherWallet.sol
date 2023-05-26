// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EtherWallet {
    address payable public owner;

    modifier onlyOwner{
        require(owner == msg.sender, "not the owner");
        _;
    }

    constructor (){
        owner = payable(msg.sender);  // payable is used to indicate that this address must be paid 
    }

    function withdraw (uint _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    } 

    function getBalance() external view returns(uint balance) {
        return address(this).balance;
    }

    event Deposit(address indexed account, uint amount); //event to deposit into contract

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

}