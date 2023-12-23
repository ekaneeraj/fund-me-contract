// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Get funds from users
    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent 5$
        // 1. How do we send ETH to this contract?

        // Set a minimum funding value in USD
        require(msg.value.getConversionPrice(s_priceFeed) >= MINIMUM_USD, "Didn't sent enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    // Withdraw with cheaper gas price
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        
        for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send failed");
    }

    // Withdraw funds
    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");a

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send failed");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure functions (Getters)
     */

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getAddressToAmountFunded(address _fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[_fundingAddress];
    }

    function getFunder(uint256 _index) external view returns (address) {
        return s_funders[_index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
