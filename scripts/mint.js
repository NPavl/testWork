
const { ERC721CONTRACT_ADDRESS, META_DATA_URL} = process.env

  // npx hardhat run scripts/mint1155.js --network rinkeby

async function mintNFT(ERC721CONTRACT_ADDRESS, META_DATA_URL) {
   const SimpleERC721 = await ethers.getContractFactory("SimpleERC721")
   const [owner] = await ethers.getSigners()
   const response = await SimpleERC721.attach(ERC721CONTRACT_ADDRESS)
      .safeMint(owner.address, META_DATA_URL, {
         value: ethers.utils.parseEther('0.001'),
         gasLimit: 500_000
      }) 
   // const response = await SimpleERC721.connect(owner.address).mintTo(owner.address) 
   console.log("NFT minted to: ", owner.address)
   console.log(`Transaction Hash: ${response.hash}`)
}
   
mintNFT(ERC721CONTRACT_ADDRESS, META_DATA_URL)
   .then(() => process.exit(0))
   .catch((error) => {
      console.error(error);
      process.exit(1);
   });