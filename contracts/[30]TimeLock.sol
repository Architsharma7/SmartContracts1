// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

// after contract deployment a time for 365 days is set
// this contract accepts deposits and until the time is not completed the funds are locked

contract TimeLock {
    uint public constant duration = 365 days;

    uint public immutable endAt;
    address payable immutable owner;

    constructor(address payable _owner) {
        owner = _owner;
        endAt = block.timestamp + duration;
    }

    function deposit(uint _amount, address _token) external {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    receive() external payable {}

    function withdraw(address token, uint amount) external {
        require(msg.sender == owner, "only owner");
        require(block.timestamp >= end, "too early");

        if (token == address(0)) {
            owner.transfer(amount);
        } else {
            IERC20(token).transfer(owner, amount);
        }
    }
}
