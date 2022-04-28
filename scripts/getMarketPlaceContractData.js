const { ethers }  = require('hardhat');
const { PRIVATE_KEY2, URL_ALCHEMY, MARKET_PLACE_CONTRACT} = process.env

// npx hardhat run scripts/getMarketPlaceContractData.js --network rinkiby

async function main() {

const deployerEasyMarketPlace = "0xD8b46be309a729f6BAcb48D32DeA5D4aAF3a8CDE" 
const deployerSimpleERC721 = "0x0B642b7bD0ac3D4cACc92877c1Ed4B433Ecfd86c"   
const BUYER = "0x4D17188052A4a825a4017279BDAF8B570BEa4E90"
const MINTER_ROLE = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"

const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
const admin = new ethers.Wallet(PRIVATE_KEY2, provider)
const myMPContract = await ethers.getContractAt('EasyMarketPlace', MARKET_PLACE_CONTRACT, admin)

// console.log("Admin Account balance:", (await admin.getBalance()).toString())
const balance = await admin.getBalance()
const adminBalance = ethers.utils.formatEther(balance);  
console.log("Admin balance: " + adminBalance);

const totalSales = await myMPContract.totalSales()
const _totalSales = ethers.utils.formatEther(totalSales); 
console.log("EasyMarketPlace contract totalSales in ETH: ", _totalSales)

const HASROLE = await myMPContract.hasRole(MINTER_ROLE, deployerEasyMarketPlace)
console.log("MINTER_ROLE address 0xD8b46be309a729f6BAcb48D32DeA5D4aAF3a8CDE = : ", HASROLE)

const isBAYER = await myMPContract.isBayer(BUYER)
console.log("Bayer address 0x4D17188052A4a825a4017279BDAF8B570BEa4E90 = : ", isBAYER)

const vestingPeriod = await myMPContract.vestingPeriod()
console.log("EasyMarketPlace vesting period: ", vestingPeriod)

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });