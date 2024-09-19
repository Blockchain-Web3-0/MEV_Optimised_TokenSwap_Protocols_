async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const TokenSwap = await ethers.getContractFactory("TokenSwap");
    const tokenSwap = await TokenSwap.deploy("0xToken1Address", "0xToken2Address");

    console.log("TokenSwap deployed to:", tokenSwap.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});