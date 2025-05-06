const hre = require("hardhat");
const fs = require("fs");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contract from:", deployer.address);

    const EnergyTrade = await hre.ethers.getContractFactory("EnergyTrade");
    const energyTrade = await EnergyTrade.deploy();
    await energyTrade.waitForDeployment();

    const contractAddress = await energyTrade.getAddress();
    console.log("✅ EnergyTrade deployed!");
    console.log("Deployer Address:", deployer.address);
    console.log("Contract Address:", contractAddress);

    // Save the contract address to a file
    fs.writeFileSync(
        "./backend/contractAddress.json",
        JSON.stringify({ contractAddress }, null, 2)
    );

    // Save the ABI to a file
    const abi = JSON.parse(energyTrade.interface.formatJson());
    fs.writeFileSync(
        "./backend/contractABI.json",
        JSON.stringify(abi, null, 2)
    );
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
