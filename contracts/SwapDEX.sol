// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SwapDEX {
    address public owner;
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public rate; // Number of tokenB units per tokenA

    event Swapped(address indexed user, address fromToken, address toToken, uint256 fromAmount, uint256 toAmount);
    event RateUpdated(uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _tokenA, address _tokenB, uint256 _rate) {
        owner = msg.sender;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        rate = _rate;
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;
        emit RateUpdated(_rate);
    }

    // Swap tokenA for tokenB
    function swapAforB(uint256 amountA) external {
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer of tokenA failed");
        uint256 amountB = amountA * rate;
        require(tokenB.balanceOf(address(this)) >= amountB, "Insufficient tokenB liquidity");
        require(tokenB.transfer(msg.sender, amountB), "Transfer of tokenB failed");
        emit Swapped(msg.sender, address(tokenA), address(tokenB), amountA, amountB);
    }

    // Swap tokenB for tokenA
    function swapBforA(uint256 amountB) external {
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer of tokenB failed");
        uint256 amountA = amountB / rate;
        require(tokenA.balanceOf(address(this)) >= amountA, "Insufficient tokenA liquidity");
        require(tokenA.transfer(msg.sender, amountA), "Transfer of tokenA failed");
        emit Swapped(msg.sender, address(tokenB), address(tokenA), amountB, amountA);
    }

    // Owner can withdraw tokens
    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner, amount);
    }
}
