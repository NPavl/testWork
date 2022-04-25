const { ethers }  = require('hardhat');
// const { PRIVATE_KEY, URL_ALCHEMY, CONTRACT_ADDRESS } = process.env

// npx hardhat run scripts/deploySimpleERC721.js --network localhost
// npx hardhat run scripts/deploySimpleERC721.js --network rinkiby
// npx hardhat verify <0x10e6971b80942F8eF469638aDFC001B56966Ea9b> --network rinkiby

async function main() {
   
    //  const [admin, minter, relayer] = await ethers.getSigners();
    const [deployer] = await ethers.getSigners()
    
    const SimpleERC721 = await ethers.getContractFactory("SimpleERC721") 
    const simpleERC721 = await SimpleERC721.deploy() // "NFTForMarketPlace", "NFT01"
    
  console.log("Contract SimpleERC721 address:", simpleERC721.address)
  console.log("Account balance:", (await deployer.getBalance()).toString())

//   console.log(`Deploying contracts EasyMarketPlace address and balances address:`);

//   console.log(`- admin:   ${admin.address} (${ethers.utils.formatEther(await admin.getBalance())} ${ethers.constants.EtherSymbol})`);
//   console.log(`- minter:  ${minter.address} (${ethers.utils.formatEther(await minter.getBalance())} ${ethers.constants.EtherSymbol})`);
//   console.log(`- relayer: ${relayer.address} (${ethers.utils.formatEther(await relayer.getBalance())} ${ethers.constants.EtherSymbol})`);
 
  // Устанавливаем роль минтера с админского адреса DEFAULT_ADMIN_ROLE методом grantRole устанавливаем 
  // роль .MINTER_ROLE() и передаем адрес минтера. rolesRegistrar == contractAddress
//   const rolesRegistrator = eRC721LazyMintWith712.connect(admin);
//   await rolesRegistrator.grantRole(await rolesRegistrator.MINTER_ROLE(), minter.address)
  
  // проще написать так в одну строчку:
  // await eRC721LazyMintWith712.connect(admin).grantRole(await eRC721LazyMintWith712.MINTER_ROLE(), minter.address)

//   console.log({ rolesRegistrator: rolesRegistrator.address }); 
  // console.log({ eRC721LazyMintWith712: eRC721LazyMintWith712.address }); 
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });