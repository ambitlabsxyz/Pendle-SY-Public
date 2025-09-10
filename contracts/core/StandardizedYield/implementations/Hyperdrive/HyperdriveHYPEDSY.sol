// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {SYBaseUpgV2} from "../../v2/SYBaseUpgV2.sol";
import {IPTokenWithSupplyCap} from "../../../../interfaces/IPTokenWithSupplyCap.sol";
import {IERC4626} from "../../../../interfaces/IERC4626.sol";
import {IERC7535} from "../../../../interfaces/Hyperdrive/IERC7535.sol";
import {IHYPED} from "../../../../interfaces/Hyperdrive/IHYPED.sol";

contract HyperdriveHYPEDSY is SYBaseUpgV2, IPTokenWithSupplyCap {
    address public constant HYPED = 0x4d0fF6a0DD9f7316b674Fb37993A3Ce28BEA340e;

    constructor() SYBaseUpgV2(HYPED) {}

    function initialize(address _owner) external virtual initializer {
        __SYBaseUpgV2_init("SY Hyperdrive Liquid Staked HYPE", "SY-HYPED", _owner);
    }

    function _deposit(
        address tokenIn,
        uint256 amountDeposited
    ) internal override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == yieldToken) {
            return amountDeposited;
        }
        return IERC7535(yieldToken).deposit{value: msg.value}(amountDeposited, address(this));
    }

    function _redeem(
        address receiver,
        address /*tokenOut*/,
        uint256 amountSharesToRedeem
    ) internal virtual override returns (uint256) {
        _transferOut(yieldToken, receiver, amountSharesToRedeem);
        return amountSharesToRedeem;
    }

    function _previewDeposit(
        address tokenIn,
        uint256 amountTokenToDeposit
    ) internal view virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == yieldToken) return amountTokenToDeposit;
        else return IERC4626(yieldToken).previewDeposit(amountTokenToDeposit);
    }

    function _previewRedeem(
        address /*tokenOut*/,
        uint256 amountSharesToRedeem
    ) internal pure override returns (uint256 /*amountTokenOut*/) {
        return amountSharesToRedeem;
    }

    function exchangeRate() public view virtual override returns (uint256) {
        return IERC4626(yieldToken).convertToAssets(1e18);
    }

    function getTokensIn() public view override returns (address[] memory res) {
        res = new address[](2);
        res[0] = NATIVE;
        res[1] = yieldToken;
    }

    function getTokensOut() public view override returns (address[] memory res) {
        res = new address[](1);
        res[0] = yieldToken;
    }

    function isValidTokenIn(address token) public view override returns (bool) {
        return token == NATIVE || token == yieldToken;
    }

    function isValidTokenOut(address token) public view override returns (bool) {
        return token == yieldToken;
    }

    function assetInfo() external pure returns (AssetType assetType, address assetAddress, uint8 assetDecimals) {
        return (AssetType.TOKEN, NATIVE, 18);
    }

    function getAbsoluteSupplyCap() external view returns (uint256) {
        return IHYPED(HYPED).getMaximumSupply();
    }

    function getAbsoluteTotalSupply() external view returns (uint256) {
        return IERC4626(HYPED).totalAssets();
    }
}
