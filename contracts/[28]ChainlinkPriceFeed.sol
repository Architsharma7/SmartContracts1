// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceFeed {

    AggregatorV3Interface internal priceFeed;

    // address of the token / otken pair for which the price is needed
    constructor (address _address) {
        priceFeed = AggregatorV3Interface(_address);
    }

    function getLatestPrice() external view returns(uint){
         (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
}