// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

// fetch the swap rate of a pair with uniswap price query method

import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol";
import "https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/OracleLibrary.soll";

contract UniswapFeed {
    // addresses of tokenIn, tokenOut, and pool for the tokens
    address public immutable token0;
    address public immutable token1;
    address public immutable pool;

    constructor(
        address _factory,
        address _token0,
        address _token1,
        uint24 _fee
    ) {
        token0 = _token0;
        token1 = _token1;

        // pool is created using uniswap factory with token addresses and fees
        address _pool = IUniswapV3Factory(_factory).getPool(
            _token0,
            _token1,
            _fee
        );

        require(_pool != address(0), "Pool does not exsist");

        pool = _pool;
    }

    function estimateAmountOut(
        address tokenIn,
        uint128 amountIn,
        uint32 secondsAgo
    ) external view returns (uint amountOut) {
        require(tokenIn == token0 || tokenIn == token1, "invalid token");
        address tokenOut = token1 == token0 ? token1 : token0;

        //  finding the tick in the pool , for a particular timestamp by passing ssecondsAgo 
        (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo);

        // calculate amount out at a particular tick
        amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            amountIn,
            tokenIn,
            tokenOut
        );
    }
}
