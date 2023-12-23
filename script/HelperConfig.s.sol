// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public DECIMALS = 8;
    int256 public INITIAL_PRICE = 2000e8;

    address priceFeedAddressSepolia = vm.envAddress("SEPOLIA_PRICE_FEED");
    address priceFeedAddressMainnet = vm.envAddress("MAINNET_PRICE_FEED");

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepliaEthConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: priceFeedAddressSepolia});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: priceFeedAddressMainnet});
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
