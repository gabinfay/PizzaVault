# Chainlink Price Oracle on Base

This project demonstrates how to fetch the price of ETH/USD using a Chainlink price oracle on the Base network.

## Setup

1.  **Install Foundry:**
    If you don't have Foundry installed, you can get it by running the following command:
    ```shell
    curl -L https://foundry.paradigm.xyz | bash
    ```
    Then, in a new terminal session or after reloading your profile, run `foundryup` to install the latest version.

2.  **Initialize a new Foundry project:**
    ```shell
    forge init --no-git --no-deps --force my-chainlink-oracle
    cd my-chainlink-oracle
    ```

3.  **Install Dependencies:**
    ```shell
    forge install smartcontractkit/chainlink-brownie-contracts
    forge install foundry-rs/forge-std
    ```

## Smart Contracts

Here is the complete code for this project.

### 1. `src/IOracle.sol`

This interface defines the standard for any oracle contract that returns a price.

```solidity
//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * Oracle Interface for fetching token prices
 * @author Avanguard Index
 */
interface IOracle {
    /**
     * @dev Get the current price of a token in USD with 8 decimals
     * @param token The token address to get price for
     * @return price The current price in USD (8 decimals)
     */
    function getPrice(address token) external view returns (uint256 price);
}
```

### 2. `src/ChainlinkOracle.sol`

This contract implements the `IOracle` interface and fetches the price from a Chainlink `AggregatorV3Interface`.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./IOracle.sol";

contract ChainlinkOracle is IOracle {
    mapping(address => address) public priceFeeds;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function setPriceFeed(address token, address feed) external onlyOwner {
        priceFeeds[token] = feed;
    }

    function getPrice(address token) external view override returns (uint256 price) {
        address feedAddress = priceFeeds[token];
        require(feedAddress != address(0), "Price feed not found");

        AggregatorV3Interface priceFeed = AggregatorV3Interface(feedAddress);
        (
            ,
            int256 latestPrice,
            ,
            ,
            
        ) = priceFeed.latestRoundData();

        // Chainlink prices can have different decimals, we need to convert to 8
        uint8 decimals = priceFeed.decimals();
        if (decimals > 8) {
            return uint256(latestPrice) / (10**(uint256(decimals) - 8));
        } else {
            return uint256(latestPrice) * (10**(8 - uint256(decimals)));
        }
    }
}
```

### 3. `test/ChainlinkOracle.t.sol`

This is the test contract that verifies the functionality of `ChainlinkOracle.sol`.

```solidity
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
        // ETH/USD Price Feed on Base
        address ethUsdPriceFeed = 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
        address ethToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // Common address for ETH

        oracle.setPriceFeed(ethToken, ethUsdPriceFeed);

        uint256 price = oracle.getPrice(ethToken);

        console.log("ETH/USD Price: ", price);
        assertTrue(price > 0, "Price should be greater than 0");
    }
}
```

## Running the Test

To run the test, you'll need to fork the Base mainnet. You can use any RPC URL for Base.

```shell
forge test --fork-url https://mainnet.base.org -vvv
```

You should see a successful test run, with the ETH/USD price logged to the console.
