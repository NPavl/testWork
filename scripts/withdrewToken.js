
const { ethers }  = require('hardhat');

// const { PRIVATE_KEY, ADMIN, URL_ALCHEMY, MINTER_ADDRESS, BUYER, SIGNATURE,  
//    ACCOUNT_MPCONTRACT, MARKET_PLACE_CONTRACT, SIMPLE_ERC721, META_DATA_URL } = process.env

// простой пример без заморчек: https://xtremetom.medium.com/verifying-solidity-signatures-4898d003846b
// пример используемый в проекте: https://github.com/OpenZeppelin/workshops/tree/master/06-nft-merkle-drop/scripts

// npx hardhat run scripts/withdrewToken.js --network localhost
// npx hardhat run scripts/withdrewToken.js --network rinkiby

async function main() { 
  
 const [ADMIN, MINTER_ADDRESS, BUYER] = await ethers.getSigners()
  
  const SIGNATURE = ""
  const TOKEN_ID = 1
  MARKET_PLACE_CONTRACT = ""

  myContract = await ethers.getContractFactory("EasyMarketPlace");
  myContract.attach(MARKET_PLACE_CONTRACT); 

 // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // admin = new ethers.Wallet(PRIVATE_KEY, provider)
  // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // buyer = new ethers.Wallet(PRIVATE_KEY, provider)
  
  // const myContract = await ethers.getContractAt('EasyMarketPlace', MARKET_PLACE_CONTRACT, admin)
  // const myContract = await ethers.getContractAt('ERC721LazyMintWith712', MARKET_PLACE_CONTRACT, buyer)

// покупатель забирает свой токен после окончания периода вестинга: 

// в методе  withdrawToken происходит проверка подписи - require(_verify(_digest, signature), "Invalid signature");

const _tx = await myContract.connect(BUYER).withdrawToken(TOKEN_ID, SIGNATURE)
const _result = await _tx.wait()
console.log("result from method createItemFromERC721Contract: ", _result)

const buyerTokenBalance = await myContract.connect(BUYER).balanceOf(BUYER.address)

const { _uri } = await myContract.getTokenURIFromERC721Contract(TOKEN_ID)
console.log("URI: ", _uri)

console.log("buyerBalance ETH:", (await BUYER.getBalance()).toString());
console.log("buyerBalance token:", buyerTokenBalance);

 
console.log("=====================================FINAL RESULT: ")
console.log(`Contract address: ${myContract.address}, 
             Signature: ${SIGNATURE}, 
             Buyer address: ${BUYER.address}, 
             Bought Token Id: ${TOKEN_ID}, 
             URI: ${_uri}
             `);
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});