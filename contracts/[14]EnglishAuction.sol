// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC721{
    /// creating interface for the function we will be using in our mein contract
    /// to transfer the NFT automatically after the bid.
    function safeTransferFrom(
        address from , 
        address to ,
        uint tokenId
    ) external ;

    function transferFrom(
        address from ,
        address to,
        uint tokenId
    ) external ;
}

contract EnglishAuction {

    address payable public owner;

    constructor(address _nft, uint _nftId, uint _startingBid){
        owner = payable(msg.sender);
        nft = IERC721(_nft);
        nftId = _nftId;
        highestBid = _startingBid;
    }

    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    uint public endAt;
    bool public started;
    bool public ended;

    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount) ;

    IERC721 public nft ;
    uint public nftId;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public bids;

    function startBid(uint _endAt) external onlyOwner{
        require(!started, "already started");
        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = block.timestamp + _endAt;
        emit Start();
    }

    //called by the buyer to make a bid
    function Bidding() external payable {
        require(started, "not yet started");
        require(endAt > block.timestamp, "ended");
        require(msg.value > highestBid, "not the highest bid");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(highestBidder, highestBid);
    }

    // for the remaining people who bid their money , can withdraw after highest bidder gets nft
    function withdraw() external payable{
        uint balance = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(balance);

        emit Withdraw(msg.sender, balance);
    }

    function endBid() external onlyOwner{
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;

        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            owner.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), owner, nftId);
        }

        emit End(highestBidder, highestBid);
    }

}