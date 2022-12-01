/* hardhat.config.js */
require("@nomiclabs/hardhat-waffle")
const fs = require("fs")
const privateKey = fs.readFileSync(".secret").toString()
const projectId = "e5195d3c13194634beb7b933ecbcf465"
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },

  sepolia: {
    url: "https://sepolia.infura.io/v3/e5195d3c13194634beb7b933ecbcf465",
    accounts: [privateKey]
  },
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}