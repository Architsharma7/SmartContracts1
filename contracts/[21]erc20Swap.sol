// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

// 2 tokens will be swapped
// user will decide the exchange rate of both

/*
How to swap tokens

1. Alice has 100 tokens from AliceCoin, which is a ERC20 token.
2. Bob has 100 tokens from BobCoin, which is also a ERC20 token.
3. Alice and Bob wants to trade 10 AliceCoin for 20 BobCoin.
4. Alice or Bob deploys ERC20Swap
5. Alice approves ERC20Swap to withdraw 10 tokens from AliceCoin
6. Bob approves ERC20Swap to withdraw 20 tokens from BobCoin
7. Alice or Bob calls ERC20Swap.swap()
8. Alice and Bob traded tokens successfully.
*/

contract ERC20Swap {
    IERC20 public token1;
    uint public amount1;
    address public owner1;
    IERC20 public token2;
    uint public amount2;
    address public owner2;

    constructor(
        address _token1,
        address _owner1,
        uint _amount1,
        address _token2,
        address _owner2,
        uint _amount2
    ) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        owner1 = _owner1;
        amount1 = _amount1;
        owner2 = _owner2;
        amount2 = _amount2;
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }

    function swap() public {
        require(msg.sender == owner1 || msg.sender == owner2 , "not authorised");
        //check if the amount approved to swap is equal or greater than the amount swapped
        require(token1.allowance(owner1, address(this)) >= amount1, "token 1 allowance too low to spend");
        require(token2.allowance(owner2, address(this)) >= amount2, "token 2 allowance too low to spend");

        _safeTransferFrom(token1 ,owner1 , owner2 , amount1) ;
        _safeTransferFrom(token2 ,owner2 , owner1 , amount2) ;
    }

    // function allowance(address owner, address spender) external view returns (uint256);
    // The ERC-20 standard allows an address to give an allowance to another address to be able to retrieve tokens from it. This getter returns the remaining number of tokens that the spender will be allowed to spend on behalf of owner. This function is a getter and does not modify the state of the contract and should return 0 by default.

}
