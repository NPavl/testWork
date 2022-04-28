const { ethers }  = require('hardhat');
const { PRIVATE_KEY, URL_ALCHEMY, SIMPLE_ERC721 } = process.env

// npx hardhat run scripts/getERC721ContractData.js --network rinkiby

async function main() {

// const deployerEasyMarketPlace = "0xD8b46be309a729f6BAcb48D32DeA5D4aAF3a8CDE" 
const deployerSimpleERC721 = "0x0B642b7bD0ac3D4cACc92877c1Ed4B433Ecfd86c"   
const BUYER_AS_MPCONTRACT = "0x1F0A8A923c0D47737c1FFC5eA77C4742c053B67E"
const MINTER_ROLE = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
const id = 1

const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
const admin = new ethers.Wallet(PRIVATE_KEY, provider)
const ercContract = await ethers.getContractAt('SimpleERC721', SIMPLE_ERC721, admin)

const balance = await admin.getBalance()
const adminBalance = ethers.utils.formatEther(balance);  
console.log("Admin balance in ETH: " + adminBalance);

const totalSales = await ercContract.totalSales()
const _totalSales = ethers.utils.formatEther(totalSales); 
console.log("EasyMarketPlace contract totalSales in ETH: ", _totalSales)

const balanceOf = await ercContract.balanceOf(BUYER_AS_MPCONTRACT) 
console.log("EasyMarketPlace token balance: ", balanceOf)

const HASROLE = await ercContract.hasRole(MINTER_ROLE, BUYER_AS_MPCONTRACT)
console.log("MINTER_ROLE address 0x0B642b7bD0ac3D4cACc92877c1Ed4B433Ecfd86c = : ", HASROLE)

const tokenUri = await ercContract.tokenURI(id)
console.log(`tokenUri by ID ${id}: ${tokenUri}`)

const owner = await ercContract.ownerOf(id)
console.log(`OwnerOf by tokenId: ${id} = ${owner}`)

const basetokenUri = await ercContract.baseTokenURI()
console.log(`Base tokenUri: ${basetokenUri}`)

const mintPrice = await ercContract.MINT_PRICE()
const _mintPrice = ethers.utils.formatEther(mintPrice); 
console.log(`Mint price: ${_mintPrice}`)

const TOTAL_SUPPLY = await ercContract.TOTAL_SUPPLY()
console.log(`Total supply: ${TOTAL_SUPPLY}`) 

const result  = await ercContract.remainingTokensforMint()
console.log(`Total supply - allready minted = : ${result}`) 

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });