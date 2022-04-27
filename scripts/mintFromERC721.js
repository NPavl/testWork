const { ethers }  = require('hardhat');

// const { PRIVATE_KEY, URL_ALCHEMY, MINTER_ADDRESS, BUYER, 
//    ACCOUNT_MPCONTRACT, SIMPLE_ERC721, META_DATA_URL, TOKEN_ID } = process.env

// простой пример без заморчек работа с подписями: https://xtremetom.medium.com/verifying-solidity-signatures-4898d003846b
// пример используемый в проекте: https://github.com/OpenZeppelin/workshops/tree/master/06-nft-merkle-drop/scripts

// npx hardhat run scripts/mintFromERC721.js --network localhost
// npx hardhat run scripts/mintFromERC721.js --network rinkiby

async function main() { 

const [ADMIN, MINTER_ADDRESS, BUYER] = await ethers.getSigners()

const SIMPLE_ERC721 = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
const META_DATA_URL = "ipfs://testUri.json"
const value = ethers.utils.parseEther('0.001');
const TOKEN_ID = 1
// PROVIDER = "http://127.0.0.1:8545/" // http://localhost:8545 // // URL_ALCHEMY
  
// const Contract = await ethers.getContractFactory("SimpleERC721");
// const myContract = await Contract.deploy(); 

// const _provider = new ethers.providers.JsonRpcProvider("http://localhost:8545") // URL_ALCHEMY
// const ADMIN = new ethers.Wallet(PRIVATE_KEY, _provider)
const myContract = await ethers.getContractAt('SimpleERC721', SIMPLE_ERC721, ADMIN)

const tx = await myContract.connect(BUYER).PaidMintTokensForAll(META_DATA_URL, { value });
const result = tx.wait()

const buyerTokenBalance = await myContract.balanceOf(BUYER.address)
console.log("Account balance:", (await BUYER.getBalance()).toString())
console.log("buyerTokenBalance:", buyerTokenBalance)
const _uri = await myContract.connect(BUYER).tokenURI(TOKEN_ID)
console.log("uri return: ", _uri)

  console.log(`Contract address: ${myContract.address}, 
               Admin address: ${ADMIN.address},
               Buyer address: ${BUYER.address},
               Buyer token balance: ${buyerTokenBalance},
               Minted Token Id: ${TOKEN_ID}, 
               URI: ${META_DATA_URL},   
               receipt: ${result} 
               `);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

