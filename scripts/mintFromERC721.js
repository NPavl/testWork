const { ethers }  = require('hardhat');

// const { PRIVATE_KEY, URL_ALCHEMY, MINTER_ADDRESS, BUYER, 
//    ACCOUNT_MPCONTRACT, SIMPLE_ERC721, META_DATA_URL } = process.env

// простой пример без заморчек рабоа с подписями: https://xtremetom.medium.com/verifying-solidity-signatures-4898d003846b
// пример используемый в проекте: https://github.com/OpenZeppelin/workshops/tree/master/06-nft-merkle-drop/scripts

// npx hardhat run scripts/mintFromERC721.js --network localhost
// npx hardhat run scripts/mintFromERC721.js --network rinkiby

async function main() { 

const [ADMIN, MINTER_ADDRESS, BUYER] = await ethers.getSigners()

const META_DATA_URL = "ipfs://testUri.json"
const value = ethers.utils.parseEther('0.001');

//   const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
//   admin = new ethers.Wallet(PRIVATE_KEY, provider)
//   const myContract = await ethers.getContractAt('SimpleERC721', SIMPLE_ERC721, ADMIN)
  
const Contract = await ethers.getContractFactory("SimpleERC721");
const myContract = await Contract.deploy(); 

await myContract.connect(ADMIN).grantRole(await myContract.MINTER_ROLE(), MINTER_ADDRESS.address);

const tx = await myContract.connect(BUYER).PaidMintTokensForAll(META_DATA_URL, { value });
const result = tx.wait()

const buyerTokenBalance = await myContract.connect(BUYER).balanceOf(BUYER.address)

console.log("Account balance:", (await deployer.getBalance()).toString())

  console.log(`Contract address: ${myContract.address}, 
               Admin address: ${ADMIN.address},
               Buyer address: ${BUYER.address},
               Buyer token balance: ${buyerTokenBalance},
               Buyer balance ETH: ${buyerBalance},
               Account to: ${MINTER_ADDRESS.address}, 
               Minted Token Id: ${tokenId}, 
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

