const { ethers }  = require('hardhat');
const { PRIVATE_KEY, MINTER_ADDRESS, SIGNATURE} = process.env

 // sample https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/scripts/3-redeem.js

// npx hardhat run scripts/onlyRedeem.js --network localhost
// npx hardhat run scripts/onlyRedeem.js --network rinkiby

async function attach(name, address) {
  const contractFactory = await ethers.getContractFactory(name);
  return contractFactory.attach(address);
}

async function main() {
  const [admin, minter, relayer ] = await ethers.getSigners();
  console.log(`Redeem token:`);
  
  const registry    = (await attach('ERC721LazyMintWith712', MINTER_ADDRESS)).connect(relayer);
  const tokenId     = process.env.TOKENID || 1;
  const account     = process.env.ACCOUNT || '0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc';
  const signature   = SIGNATURE;

  const tx = await registry.redeem(account, tokenId, signature);
  const receipt = await tx.wait(); // Wait for the transaction to be mined...

  console.log(receipt);
  console.log("account minter: ", registry.address);
  console.log("account admin: ", admin.address);
  console.log("account relayer: ", relayer.address);
  
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });