const { ethers }  = require('hardhat');
const { PRIVATE_KEY, MINTER_ADDRESS, ACCOUNT, CONTRACT_ADDRESS } = process.env

// npx hardhat run scripts/signRedeemAndMint.js --network localhost
// npx hardhat run scripts/signRedeemAndMint.js --network rinkiby

async function main() { 
  
  const contractAddress = CONTRACT_ADDRESS
  const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  const admin = new ethers.Wallet(PRIVATE_KEY, provider)
  
  const myContract = await ethers.getContractAt('ERC721LazyMintWith712', contractAddress, admin)
  
  const tokenId = await myContract.connect(admin).totalMint()
  console.log(tokenId) 
  tokenId += 1
  const { chainId } = await ethers.provider.getNetwork();
  const signature   = await MINTER_ADDRESS._signTypedData(
    // Domain
    {
      name: 'Name',
      version: '1.0.0',
      chainId,
      verifyingContract: contractAddress.address,
    },
    // Types
    {
      NFT: [
        { name: 'tokenId', type: 'uint256' },
        { name: 'account', type: 'address' },
      ],
    },
    // Value
    { tokenId, ACCOUNT },
  );
  
  // Восстанавливаем подпись и минтим токен, MINTER_ADDRESS - адрес минтера, ACCOUNT - кому минтим токен (маркетплейс)
  const tx = await myContract.connect(MINTER_ADDRESS).buyItem(ACCOUNT, tokenId, signature);
  const receipt = await tx.wait(); // Wait for the transaction to be mined...
  
  console.log(receipt);
  console.log("account minter: ", myContract.address);
  console.log("account admin: ", admin.address);
  // console.log("account relayer: ", relayer.address);

  console.log({ registry: myContract.address, tokenId, ACCOUNT, signature });
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });