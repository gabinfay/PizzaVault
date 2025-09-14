// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IWETH} from "../src/PizzaVault.sol";

contract SummerFiForkTest is Test {
    IERC4626 ethVault = IERC4626(0x2bb9ad69FEBA5547b7cD57aAfe8457D40bF834af);
    IWETH weth = IWETH(0x4200000000000000000000000000000000000006);
    address user = address(1);

    function testFork() public {
        assertEq(weth.totalSupply(), 0);
    }

    function testDepositAndWithdraw() public {
        vm.deal(user, 1 ether);
        vm.startPrank(user);

        // Deposit ETH to get WETH
        weth.deposit{value: 1 ether}();
        assertEq(weth.balanceOf(user), 1 ether);

        // Approve vault to spend WETH
        weth.approve(address(ethVault), 1 ether);

        // Deposit WETH into Summer.fi vault
        uint256 shares = ethVault.deposit(1 ether, user);
        assertGt(shares, 0);
        assertEq(weth.balanceOf(user), 0);
        assertGt(ethVault.balanceOf(user), 0);

        // Withdraw WETH from Summer.fi vault
        ethVault.withdraw(1 ether, user, user);
        assertEq(ethVault.balanceOf(user), 0);
        assertGt(weth.balanceOf(user), 0);

        vm.stopPrank();
    }
}
