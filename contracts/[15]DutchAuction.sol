// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721{
    /// creating interface for the function we will be using in our mein contract
    /// to transfer the NFT automatically after the bid.

    function transferFrom(
        address from ,
        address to,
        uint tokenId
    ) external ;
}

// auction in which an auctioneer starts with a very high price, incrementally lowering the price until someone places a bid

contract DutchAuction {

    // immutable is like constant, it can be defined in constructor but can't be changed afterwards
    address payable public immutable owner;
    IERC721 public immutable nft;
    uint public immutable nftId;
    uint public immutable startingPrice;
    // price that will decrement over time
    uint public immutable discountRate;
    uint public constant duration = 14 days;
    uint public immutable startAt;
    uint public immutable expiresAt;

    constructor(address _nft, uint _nftId, uint _startingPrice, uint _discountRate){
        owner = payable(msg.sender);
        
        startingPrice = _startingPrice;
        discountRate = _discountRate; 
        startAt = block.timestamp;
        expiresAt = block.timestamp + duration; 

        // we need to check if the starting price is greater then the discounted rate after the durations
        require(_startingPrice >= duration * _discountRate, "");
        nft = IERC721(_nft);
        nftId = _nftId;
    }

    event sold(address buyer , uint price) ;

    function getPrice() internal view returns(uint){
        uint timeElapsed = block.timestamp - startAt;
        uint discount = timeElapsed * discountRate;
        return startAt - discount; 
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction ended");
        uint price = getPrice();

        require(msg.value >= price, "ETH < price");
        nft.transferFrom(owner, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        emit sold(msg.sender, price);
        selfdestruct(owner);
    }

    receive() external payable{}
    fallback() external payable{}
}