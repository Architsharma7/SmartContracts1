// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WhiteList {

    uint public maxWhiteListedAddresses;

    mapping(address => bool) public whiteListedAddresses;

    uint public numAddressesWhiteListed;

    constructor(uint _maxWhiteListedAddresses) {
        maxWhiteListedAddresses = _maxWhiteListedAddresses;
    }

    function addAddressToWhitelist() external {
        require(!whiteListedAddresses[msg.sender] , "address already whitelisted");
        require(maxWhiteListedAddresses > numAddressesWhiteListed, "can't whitelist more addresses");
        whiteListedAddresses[msg.sender] = true;
        numAddressesWhiteListed += 1;
    }

    function checkIfAddressIsWhiteListed(address user) public view returns (bool){
        return whiteListedAddresses[user];
    }

}