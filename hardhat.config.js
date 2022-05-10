require("@nomiclabs/hardhat-waffle");

const fs = require("fs")
const privateKey = fs.readFileSync(".secret").toString()

const keys = require("./keys.json")
const MUMBAI_RPC_URL = keys.MUMBAI_RPC_URL
const MNEMONIC = keys.MNEMONIC

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
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    mumbai: {
      url: MUMBAI_RPC_URL,
      accounts: {
        mnemonic: MNEMONIC
      },
      saveDeployments: true
    }
  },
    solidity: "0.8.4"
  
};
