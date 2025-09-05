// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IERC7535 {
    function deposit(uint256 assets, address receiver) external payable returns (uint256 shares);
}
