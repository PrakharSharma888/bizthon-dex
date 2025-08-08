// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDEX {
    IERC20 public tokenA;
    IERC20 public tokenB;

    event Swapped(address indexed user, address fromToken, address toToken, uint256 fromAmount, uint256 toAmount);

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    // Swap TokenA for TokenB
    function swapAForB(uint256 amountAIn) external returns (uint256 amountBOut) {
        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "Transfer failed");
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Constant product formula: x * y = k
        // Calculate amountBOut using the formula: dy = (y * dx) / (x + dx)
        amountBOut = (reserveB * amountAIn) / (reserveA + amountAIn);
        require(tokenB.transfer(msg.sender, amountBOut), "Transfer failed");

        emit Swapped(msg.sender, address(tokenA), address(tokenB), amountAIn, amountBOut);
    }

    // Swap TokenB for TokenA
    function swapBForA(uint256 amountBIn) external returns (uint256 amountAOut) {
        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "Transfer failed");
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Constant product formula: x * y = k
        // Calculate amountAOut using the formula: dx = (x * dy) / (y + dy)
        amountAOut = (reserveA * amountBIn) / (reserveB + amountBIn);
        require(tokenA.transfer(msg.sender, amountAOut), "Transfer failed");

        emit Swapped(msg.sender, address(tokenB), address(tokenA), amountBIn, amountAOut);
    }
}
