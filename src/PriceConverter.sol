// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionPrice(uint256 _ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // 1 ETH?
        // 2000_00000000000000000
        uint256 ethPrice = getPrice(priceFeed);
        // (2000_00000000000000000 * 1_00000000000000000) / 1e18;
        // $2000 = 1 ETH
        uint256 ethAmountInUSD = (ethPrice * _ethAmount) / 1e18;
        return ethAmountInUSD;
    }
}
