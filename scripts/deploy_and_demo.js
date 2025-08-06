const { ethers } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers");

async function main() {
  // Deploy TokenA
  const Token = await ethers.getContractFactory("MyToken");
const tokenA = await Token.deploy("TokenA", "TKA", ethers.utils.parseUnits("1000000", 18));
  await tokenA.deployed();
  console.log("TokenA deployed to:", tokenA.address);

  // Deploy TokenB
const tokenB = await Token.deploy("TokenB", "TKB", ethers.utils.parseUnits("1000000", 18));
  await tokenB.deployed();
  console.log("TokenB deployed to:", tokenB.address);

  // Set initial rate (e.g., 1 TKA = 2 TKB)
  const rate = 2;

  // Deploy SwapDEX
  const SwapDEX = await ethers.getContractFactory("SwapDEX");
  const swapDEX = await SwapDEX.deploy(tokenA.address, tokenB.address, rate);
  await swapDEX.deployed();
  console.log("SwapDEX deployed to:", swapDEX.address);

  // Optionally, transfer some tokens to SwapDEX for liquidity
  const liquidityB = ethers.utils.parseUnits("200000", 18);
  const liquidityA = ethers.utils.parseUnits("200000", 18);
  
  await tokenA.transfer(swapDEX.address, liquidityA);
  await tokenB.transfer(swapDEX.address, liquidityB);

  console.log("Liquidity added to SwapDEX.");

  // Demonstrate a swap: swap 1000 TokenA for TokenB
  const swapAmountA = ethers.utils.parseUnits("1000", 18);

  // Approve SwapDEX to spend TokenA
  await tokenA.approve(swapDEX.address, swapAmountA);

  const [deployer] = await ethers.getSigners()
  console.log(deployer)
  // Log balances before swap
  const balA_before = await tokenA.balanceOf(deployer.address);
  const balB_before = await tokenB.balanceOf(deployer.address);
  console.log("Deployer balances before swap:");
  console.log("TokenA:", ethers.utils.formatUnits(balA_before, 18));
  console.log("TokenB:", ethers.utils.formatUnits(balB_before, 18));

  // Perform the swap
  const tx = await swapDEX.swapAforB(swapAmountA);
  await tx.wait();

  // Log balances after swap
  const balA_after = await tokenA.balanceOf(deployer.address);
  const balB_after = await tokenB.balanceOf(deployer.address);
  console.log("Deployer balances after swap:");
  console.log("TokenA:", ethers.utils.formatUnits(balA_after, 18));
  console.log("TokenB:", ethers.utils.formatUnits(balB_after, 18));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});