// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {Test} from "forge-std/Test.sol";
import {PizzaVault} from "../src/PizzaVault.sol";
import {ChainlinkOracle} from "../src/ChainlinkOracle.sol";
import {IOracle} from "../src/IOracle.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract RebalanceTest is Test {
    PizzaVault public pizzaVault;
    ChainlinkOracle public oracle;

    address ethVault = 0x2bb9ad69FEBA5547b7cD57aAfe8457D40bF834af;
    address usdcVault = 0x98C49e13bf99D7CAd8069faa2A370933EC9EcF17;
    address weth = 0x4200000000000000000000000000000000000006;
    address usdc = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address ethUsdPriceFeed = 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
    address usdcUsdPriceFeed = 0xb9d3Ba222295B2866265d6A363a23214319842a2;

    function setUp() public {
        oracle = new ChainlinkOracle();
        oracle.setPriceFeed(weth, ethUsdPriceFeed);
        oracle.setPriceFeed(usdc, usdcUsdPriceFeed);

        pizzaVault = new PizzaVault(
            ethVault,
            usdcVault,
            weth,
            usdc,
            address(oracle),
            "PizzaVault",
            "PIZZA"
        );
    }

    function testRebalanceToUSDC() public {
        vm.deal(address(this), 1 ether);
        deal(weth, address(this), 1 ether);
        IERC20(weth).approve(address(pizzaVault), 1 ether);
        pizzaVault.depositETH{value: 1 ether}();
        assertEq(address(pizzaVault.activeVault()), ethVault);

        pizzaVault.setPizzaSignal(3);

        assertEq(address(pizzaVault.activeVault()), usdcVault);
    }

    function testRebalanceToETH() public {
        vm.deal(address(this), 1 ether);
        deal(weth, address(this), 1 ether);
        IERC20(weth).approve(address(pizzaVault), 1 ether);
        pizzaVault.depositETH{value: 1 ether}();
        pizzaVault.setPizzaSignal(3);
        assertEq(address(pizzaVault.activeVault()), usdcVault);

        pizzaVault.setPizzaSignal(2);

        assertEq(address(pizzaVault.activeVault()), ethVault);
    }
}
