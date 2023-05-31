// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PiggyBank {

    address payable public owner;

    constructor(){
        owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    event Withdraw(uint _amount);

    function withdraw(uint _amount) external onlyOwner{
        payable(msg.sender).transfer(_amount);
        emit Withdraw(_amount);
        //The remaining Ether stored at that address is sent to a designated target and then the storage and code is removed from the state.
        selfdestruct(payable(owner));
    }

    event Deposit(uint _balance, address indexed account);

    receive() external payable {
        emit Deposit(msg.value, msg.sender);
    }

    fallback() external payable{}

    function getBalance() external view returns(uint balance) {
        return address(this).balance;
    }
}