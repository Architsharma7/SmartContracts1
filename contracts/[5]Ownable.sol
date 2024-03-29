// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Ownable{
    address public owner ;

    event OwnershipTransferred(address indexed previousOwner , address indexed newOwner) ;

    constructor() {
        owner == msg.sender ;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function currentOwner() public view returns(address) {
        return owner ;
    }

    function transferOwnership(address newOwner ) public onlyOwner{
        require(newOwner != address(0),"The new Owner address is not valid");
        owner = newOwner ;
        emit OwnershipTransferred(msg.sender , owner) ;
    }
}