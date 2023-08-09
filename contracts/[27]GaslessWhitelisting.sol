// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/cryptography/MerkleProof.sol" ;

// a merkle proof allows user to prove ownership if being whitelisted
// so we are using it for a gasless whitelisting bc user just have to sign a transaction without paying gas

contract Whitelist {

    bytes32 public merkleRoot ;

    constructor(bytes32 _merkleRoot) {
        /// provide the merkle root initially which is obtained by using all the address whitelisted 
        merkleRoot = _merkleRoot ;
    }

    /// @dev to check if the address is in the whitelist 
    /// @param proof - proof which the user has 
    /// @param maxAllowanceToMint - max tokens that can be minted 
    /// @return bool - check the verification is true or not 
    function checkInWhitelist(bytes32[] calldata proof, uint64 maxAllowanceToMint) view public returns (bool) {

        bytes32 leaf = keccak256(abi.encode(msg.sender, maxAllowanceToMint));

        bool verified = MerkleProof.verify(proof, merkleRoot,leaf );
        return verified ;

    }
}