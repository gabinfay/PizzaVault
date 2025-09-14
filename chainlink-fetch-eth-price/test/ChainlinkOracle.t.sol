// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ChainlinkOracle.sol";

contract ChainlinkOracleTest is Test {
    ChainlinkOracle public oracle;

    function setUp() public {
        oracle = new ChainlinkOracle();
    }

    function testGetPrice() public {
        address ethUsdPriceFeed = 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
        address ethToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // Common address for ETH

        oracle.setPriceFeed(ethToken, ethUsdPriceFeed);

        uint256 price = oracle.getPrice(ethToken);

        console.log("ETH/USD Price: ", price);
        assertTrue(price > 0, "Price should be greater than 0");
    }
}

