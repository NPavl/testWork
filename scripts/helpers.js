require("@nomiclabs/hardhat-ethers")
const { getContractAt } = require("@nomiclabs/hardhat-ethers/internal/helpers")
// const {PRIVATE_KEY, ALCHEMY_API_KEY, NETWORK, ERC721CONTRACT_ADDRESS} = process.env


// https://docs.opensea.io/docs/minting-from-your-new-contract-and-improvements
// Helper method for fetching environment variables from .env
function getEnvVariable(key, defaultValue) {
    if (process.env[key]) {
        return process.env[key];
    }
    if (!defaultValue) {
        throw `${key} is not defined and no default value was provided`;
    }
    return defaultValue;
}

// Helper method for fetching a connection provider to the Ethereum network
function getProvider() {
    return ethers.getDefaultProvider(getEnvVariable("NETWORK", "rinkeby"), {
        alchemy: getEnvVariable("ALCHEMY_API_KEY"),
    })
}

// Helper method for fetching a wallet account using an environment variable for the PK
function getAccount() {
    return new ethers.Wallet(getEnvVariable("PRIVATE_KEY"), getProvider())
}

// Helper method for fetching a contract instance at a given address
function getContract(contractName, hre) {
    const account = getAccount()
    return getContractAt(hre, contractName, getEnvVariable("ERC721CONTRACT_ADDRESS"), account)
}

module.exports = {
    getEnvVariable,
    getProvider,
    getAccount,
    getContract,
}