const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { FIGHT_PUNKS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  // Address of the Fight Punk NFT contract that was deployed previously
  const fightPunksNFTContract = FIGHT_PUNKS_NFT_CONTRACT_ADDRESS;

  /*
    A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
    so fghtPunksTokenContract here is a factory for instances of our FightPunkToken contract.
    */
  const fightPunksTokenContract = await ethers.getContractFactory(
    "FightPunksToken"
  );

  // deploy the contract
  const deployedFightPunksTokenContract = await fightPunksTokenContract.deploy(
    fightPunksNFTContract
  );

  // print the address of the deployed contract
  console.log(
    "Fight Punks Token Contract Address:",
    deployedFightPunksTokenContract.address
  );
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
