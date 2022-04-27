const { ethers }  = require('hardhat');

// const { PRIVATE_KEY, URL_ALCHEMY, MINTER_ADDRESS, 
//    ACCOUNT_MPCONTRACT, MARKET_PLACE_CONTRACT, SIMPLE_ERC721, META_DATA_URL } = process.env

// простой пример без заморчек: https://xtremetom.medium.com/verifying-solidity-signatures-4898d003846b
// пример используемый в проекте: https://github.com/OpenZeppelin/workshops/tree/master/06-nft-merkle-drop/scripts

// npx hardhat run scripts/mintFromMarketPlace.js --network localhost
// npx hardhat run scripts/mintFromMarketPlace.js --network rinkiby

async function main() { 
  
  const [ADMIN, MINTER_ADDRESS, BUYER] = await ethers.getSigners();
  const MARKET_PLACE_CONTRACT = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
  const SIMPLE_ERC721 = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
  const META_DATA_URL = "ipfs://testUriFromMarketPlace.json"
  const MINTER_ROLE = '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6'
  const TOKEN_ID = 1

  // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // admin = new ethers.Wallet(PRIVATE_KEY, provider)
  // const myContract = await ethers.getContractAt('EasyMarketPlace', MARKET_PLACE_CONTRACT, ADMIN)

  const myContract = await ethers.getContractAt('EasyMarketPlace', MARKET_PLACE_CONTRACT, ADMIN)

  // myContract = await ethers.getContractFactory("EasyMarketPlace");
  // myContract.attach(address); 

  // перед вызовом createItemFromERC721Contract() необходимо установить роль минтера, 
  // если этого еще не произошло тогда: 

  // проверка есть ли роль минтера, hasRole(bytes32 role, address account)
  const _result = await myContract.connect(ADMIN).hasRole(MINTER_ROLE, MINTER_ADDRESS.address)
  console.log("MINTER_ROLE: ",  _result)

  const _promis = await myContract.connect(ADMIN).grantRole(await myContract.MINTER_ROLE(), MINTER_ADDRESS.address);
  const result = await _promis.wait(); // дождаться результата
  
  const tokenId = await myContract.connect(MINTER_ADDRESS).createItemFromERC721Contract(META_DATA_URL)
  const receipt = await tokenId.wait(); // дождаться результата

  const tokenBalance = await myContract.connect(ADMIN).getContractTokenBalance()

  console.log(`Contract address: ${myContract.address}, 
               Admin address: ${ADMIN.address},
               MINTER_ADDRESS: ${MINTER_ADDRESS}, 
               MINTER_ADDRESS Tokens balance: ${tokenBalance}, 
               Minted Token Id: ${META_DATA_URL}, 
               URI: ${META_DATA_URL},  
               `);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

