// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";

interface INFT{
    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

}

abstract contract ICO is ERC20, Ownable{
    uint public constant tokenPrice = 0.01 ether;

    // Each NFT would give the user 10 tokens
    // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
    // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
    // is actually equal to (10 ^ -18) tokens.
    // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
    uint public constant tokensPerNFT = 10 * 10^18;

    uint public constant maxTotalSupply = 10000 * 10^18;

    // instance of INFT
    INFT NFT;

    // to keep track the tokenIDs that are claimed
    mapping(uint => bool) public tokenIdsClaimed;

    constructor(address _nft) ERC20("MyToken", "MT") {
        NFT = INFT(_nft);
    }

    function mint(uint amount) public payable{
        uint _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "not enought ether sent");
        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds the max total supply available.");
        _mint(msg.sender, amountWithDecimals);
    }


    function claim() public {
        address sender = msg.sender;
        // Get the number of NFT's held by a given sender address
        uint balance = NFT.balanceOf(sender);
        require(balance < 0 , "you don't own any nft");
        // amount keeps track of number of unclaimed tokenIds
        uint amount = 0;
        // loop over the balance and get the token ID owned by `sender` at a given `index` of its token list.
        for(uint i; i < balance ; i++){
            uint tokenId = NFT.tokenOfOwnerByIndex(sender, i);
            if(!tokenIdsClaimed[tokenId]){
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        require(amount > 0, "NFT already claimed");

        _mint(sender, amount * tokensPerNFT);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
} 
