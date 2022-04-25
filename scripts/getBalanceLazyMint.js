const { ethers } = require('hardhat');
const { PRIVATE_KEY, URL_ALCHEMY, CONTRACT_ADDRESS } = process.env
// npx hardhat run scripts/getBalanceLazyMint.js --network localhost

async function main() {
  const [signer] = await ethers.getSigners();
  const account = process.env.ACCOUNT || '0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc';
  const contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
  const myContract = await ethers.getContractAt('ERC721LazyMintWith712', contractAddress, signer)

  // const contractAddress = CONTRACT_ADDRESS
  // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // const admin = new ethers.Wallet(PRIVATE_KEY, provider)
  // const signer = new ethers.Wallet(PRIVATE_KEY2, provider)
  // const myContract = await ethers.getContractAt('ERC20token', contractAddress, signer)

  try {
    // ETH balance
    const balance = await myContract.connect(account.address).balanceOf(account.address)
    await myContract.connect(signer.address)._setTokenURI(tokenId, "ipfs://funny.json")
    const tokenUri = myContract.connect(account.address).tokenURI(tokenId)

    // console.log("Account ETH balance:", (await account.getBalance()).toString())
    console.log(`Address Token balance: ${account.address} is equal to: ${balance}`)
    console.log(`Get Token URI by ID: ${account.address} is equal to: ${tokenUri}`)
  
  } catch (error) {
    console.log('Something went wrong: ', error)
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })