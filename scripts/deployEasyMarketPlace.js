const { ethers }  = require('hardhat');
const { PRIVATE_KEY, URL_ALCHEMY, CONTRACT_ADDRESS, SIMPLE_ERC721, VESTING_PERIOD, MINTER_ADDRESS } = process.env

// npx hardhat run scripts/deployEasyMarketPlace.js --network localhost
// npx hardhat run scripts/deployEasyMarketPlace.js--network rinkiby
// npx hardhat verify --constructor-args scripts/arg.js <contract_address> --network rinkiby

async function main() {

  // const contractAddress = CONTRACT_ADDRESS
  // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // const admin = new ethers.Wallet(PRIVATE_KEY, provider)
  // const myContract = await ethers.getContractAt('ERC721LazyMintWith712', contractAddress, admin)
  // const value = ethers.utils.parseEther('10')
  // await myContract.connect(admin).mint(admin.address, value)

  // ДЕПЛОЙ:   

  const [deployer] = await ethers.getSigners()
  // const VESTING_PERIOD = 60;
  // const SIMPLE_ERC721 = '';
  
  const EasyMarketPlace = await ethers.getContractFactory("EasyMarketPlace")
  const easyMarketPlace = await EasyMarketPlace.deploy(VESTING_PERIOD, SIMPLE_ERC721) // 60 сек 
  
  const tx = await easyMarketPlace.connect(deployer).grantRole(await easyMarketPlace.MINTER_ROLE(), MINTER_ADDRESS.address)
  const result = tx.wait()

  console.log("Contract EasyMarketPlace address:", easyMarketPlace.address)
  console.log("Account balance:", (await deployer.getBalance()).toString())

//   console.log(`Deploying contracts EasyMarketPlace address and balances address:`);

//   console.log(`Deploying contracts EasyMarketPlace address and balances address:`);
//   console.log(`- admin:   ${admin.address} (${ethers.utils.formatEther(await admin.getBalance())} ${ethers.constants.EtherSymbol})`);
//   console.log(`- minter:  ${minter.address} (${ethers.utils.formatEther(await minter.getBalance())} ${ethers.constants.EtherSymbol})`);
//   console.log(`- relayer: ${relayer.address} (${ethers.utils.formatEther(await relayer.getBalance())} ${ethers.constants.EtherSymbol})`);
 
  // Устанавливаем роль минтера с админского адреса DEFAULT_ADMIN_ROLE методом grantRole устанавливаем 
  // роль .MINTER_ROLE() и передаем адрес минтера. rolesRegistrar == contractAddress
//   const rolesRegistrator = eRC721LazyMintWith712.connect(admin);
//   await rolesRegistrator.grantRole(await rolesRegistrator.MINTER_ROLE(), minter.address)
  
  // проще написать так в одну строчку:
  
//   console.log({ rolesRegistrator: rolesRegistrator.address }); 
  // console.log({ eRC721LazyMintWith712: eRC721LazyMintWith712.address }); 
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });