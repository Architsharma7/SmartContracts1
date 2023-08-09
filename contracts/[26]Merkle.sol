// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// openzeppling merkle proof contracts to access the verify function
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/cryptography/MerkleProof.sol";

// a merkle root is the root of a no. of hashes of transactions and is stored in the block header
// a merkle proof can be used to verify a transaction
// mostly it's done by a lightweight node bc it only contains the block header

contract Merkle {
    // merkle root
    bytes32 public merkleRoot;

    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }

    function createHash(
        address _address,
        uint256 _nonce
    ) public returns (bytes32) {
        return keccak256(abi.encodePacked(_address, _nonce));
    }

    function verify(
        bytes32[] calldata _proof,
        bytes32 _hash
    ) public returns (bool) {
        bytes leaf = _hash;
        return MerkleProof.verify(_proof,merkleRoot,leaf);
    }
}
