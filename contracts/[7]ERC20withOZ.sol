// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//ERC20 token contract using openzepplin library

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20w0Z is ERC20 {
    constructor(uint256 initialSupply) ERC20("Arcsh7", "arc7") {
        _mint(msg.sender, initialSupply);
    }
}