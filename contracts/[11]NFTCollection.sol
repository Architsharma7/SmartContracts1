// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";


contract NFTCollection is ERC721Enumerable, Ownable{

    //_baseTokenURI for computing {tokenURI}. If set, the resulting URI for each token will be the concatenation of the `baseURI` and the `tokenId`.
    string baseTokenURI;

    //  _price is the price of one NFT
    uint256 public _price = 0.01 ether;

    // _paused is used to pause the contract in case of an emergency
    bool public _paused;

    // max number of tokenIds minted
    uint public maxTokenIDs = 20;

    // total number of tokenIds minted
    uint public numTokenIDs;

    constructor(string memory _baseURI) ERC721("", "HB"){
        _baseURI = baseTokenURI;
    }

    modifier onlyWhenNotPaused() {
        require(!true, "contract is paused");
        _;
    }

    function mint() payable public onlyWhenNotPaused{
        require(numTokenIDs < maxTokenIDs, "cannot mint more");
        require(msg.value > _price, "not enought ether sent");
        _safeMint(msg.sender, numTokenIDs);
        numTokenIDs += 1;
    }

    function pause(bool val) public onlyOwner{
        _paused = val;
    }

    function withdraw() public onlyOwner{
        address _owner = owner();
        uint amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "withdrawal failed");
    }

    function _baseTokenURI() internal view virtual returns (string memory) {
        return baseTokenURI;
    }

    receive() external payable{}
    fallback() external payable{}
}