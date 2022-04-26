const { ethers }  = require('hardhat');

// const { PRIVATE_KEY, URL_ALCHEMY, MINTER_ADDRESS, 
//    ACCOUNT_MPCONTRACT, MARKET_PLACE_CONTRACT, SIMPLE_ERC721, META_DATA_URL } = process.env

// простой пример без заморчек: https://xtremetom.medium.com/verifying-solidity-signatures-4898d003846b
// пример используемый в проекте: https://github.com/OpenZeppelin/workshops/tree/master/06-nft-merkle-drop/scripts

// npx hardhat run scripts/mintFromMarketPlace.js --network localhost
// npx hardhat run scripts/mintFromMarketPlace.js --network rinkiby

async function main() { 
  
  const [admin, minter, relayer] = await ethers.getSigners();
  const MINTER_ADDRESS = ""
  const MARKET_PLACE_CONTRACT = ""
  const META_DATA_URL = ""

  // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // admin = new ethers.Wallet(PRIVATE_KEY, provider)
  // const myContract = await ethers.getContractAt('EasyMarketPlace', MARKET_PLACE_CONTRACT, admin)
  // const myContract = await ethers.getContractAt('ERC721LazyMintWith712', MARKET_PLACE_CONTRACT, admin)

  myContract = await ethers.getContractFactory("EasyMarketPlace");
  myContract.attach(address); 

  // перед вызовом createItemFromERC721Contract() необходимо установить роль минтера, 
  // если этого еще не произошло тогда: 
  // await myContract.connect(admin).grantRole(await myContract.MINTER_ROLE(), minter.address);

  const tokenId = await myContract.connect(MINTER_ADDRESS)
  .createItemFromERC721Contract(META_DATA_URL, randomNum, _digest, signature)
  const receipt = await tokenId.wait(); // дождаться результата


  console.log(`Contract address: ${myContract.address}, 
               Admin address: ${admin.address},
               Account to: ${MINTER_ADDRESS}, 
               Account minter: ${MARKET_PLACE_CONTRACT},
               Signature: ${signature}, 
               Minted Token Id: ${tokenId}, 
               URI: ${META_DATA_URL},  
               receipt: ${receipt} 
               `);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

