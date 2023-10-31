require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.19",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
      ],
    },
    mainnet: {
      url: "https://bsc-dataseed.bnbchain.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
      ],
    },
  },
};
