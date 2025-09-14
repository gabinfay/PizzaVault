// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IOracle} from "./IOracle.sol";
import {console} from "forge-std/console.sol";

interface ISummerVault is IERC4626 {
    function switchVault(uint256 shares, address newVault, address recipient) external;
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

contract PizzaVault is ERC4626, Ownable {
    ISummerVault public immutable ethHigherRiskVault;
    ISummerVault public immutable usdcLowerRiskVault;
    IWETH public immutable weth;
    IERC20 public immutable usdc;
    IOracle public immutable oracle;

    ISummerVault public activeVault;

    uint8 public pizzaSignal; // 0-5 (from pizzint.watch oracle)

    constructor(
        address _ethHigherRisk,
        address _usdcLowerRisk,
        address _weth,
        address _usdc,
        address _oracle,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC4626(IERC20(_weth)) Ownable(msg.sender) {
        ethHigherRiskVault = ISummerVault(_ethHigherRisk);
        usdcLowerRiskVault = ISummerVault(_usdcLowerRisk);
        weth = IWETH(_weth);
        usdc = IERC20(_usdc);
        oracle = IOracle(_oracle);
        activeVault = ethHigherRiskVault; // Default to ETH vault
    }

    function depositETH() external payable {
        console.log("depositETH start, value:", msg.value);
        weth.deposit{value: msg.value}();
        console.log("WETH deposited");
        deposit(msg.value, msg.sender);
        console.log("depositETH end");
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256) internal virtual override {
        console.log("_deposit start");
        uint256 calculatedShares = previewDeposit(assets);
        console.log("calculatedShares:", calculatedShares);
        _mint(receiver, calculatedShares);
        emit Deposit(caller, receiver, assets, calculatedShares);

        // console.log("Transferring WETH to active vault:", address(activeVault));
        // weth.transfer(address(activeVault), assets);
        // console.log("WETH transferred");
        // activeVault.deposit(assets, address(this));
        // console.log("Deposited to active vault");
    }

    function withdrawETH(uint256 shares, address recipient) external {
        uint256 assets = previewWithdraw(shares);
        _burn(msg.sender, shares);
        activeVault.withdraw(assets, address(this), address(this));
        weth.withdraw(assets);
        payable(recipient).transfer(assets);
    }

    function setPizzaSignal(uint8 _signal) external onlyOwner {
        require(_signal <= 5, "Invalid signal");
        pizzaSignal = _signal;
        rebalance();
    }

    function rebalance() internal {
        uint256 currentAssets = totalAssets();

        if (pizzaSignal <= 2) {
            // Calm → move into ETH Higher Risk
            if (activeVault != ethHigherRiskVault) {
                usdcLowerRiskVault.switchVault(convertToShares(currentAssets), address(ethHigherRiskVault), address(this));
                activeVault = ethHigherRiskVault;
            }
        } else {
            // Spike → move into USDC Lower Risk
            if (activeVault != usdcLowerRiskVault) {
                ethHigherRiskVault.switchVault(convertToShares(currentAssets), address(usdcLowerRiskVault), address(this));
                activeVault = usdcLowerRiskVault;
            }
        }
    }

    function totalAssets() public view virtual override returns (uint256) {
        uint256 summerVaultShares = activeVault.balanceOf(address(this));
        console.log("summerVaultShares:", summerVaultShares);
        uint256 assetsInSummerVault = activeVault.convertToAssets(summerVaultShares);
        console.log("assetsInSummerVault:", assetsInSummerVault);

        if (activeVault.asset() == address(weth)) {
            console.log("active vault is weth");
            return assetsInSummerVault;
        } else if (activeVault.asset() == address(usdc)) {
            console.log("active vault is usdc");
            uint256 usdcPrice = oracle.getPrice(address(usdc)); // 8 decimals
            console.log("usdcPrice:", usdcPrice);
            uint256 ethPrice = oracle.getPrice(address(weth)); // 8 decimals
            console.log("ethPrice:", ethPrice);
            // usdc has 6 decimals, weth has 18
            return (assetsInSummerVault * usdcPrice * 1e12) / ethPrice;
        } else {
            return 0;
        }
    }

    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual override returns (uint256) {
        if (totalSupply() == 0) {
            return assets;
        }
        return super._convertToShares(assets, rounding);
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual override returns (uint256) {
        if (totalSupply() == 0) {
            return shares;
        }
        return super._convertToAssets(shares, rounding);
    }

    receive() external payable {}
}
