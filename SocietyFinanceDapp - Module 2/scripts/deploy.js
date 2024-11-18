const hre = require("hardhat");

async function main() {
  const SocietyContract = await hre.ethers.getContractFactory("SocietyManagement");
  const assessment = await SocietyContract.deploy();
  
  await assessment.deployed();
  console.log(`Society Management Contract deployed to localhost Chain [Address]: ${assessment.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
