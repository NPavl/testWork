const { NFTStorage, File }= require("nft.storage"); // https://yarnpkg.com/package/nft.storage
const fs = require("fs"); 
require('dotenv').config();
const {NFT_STORAGE_API_KEY} = process.env 

// npx hardhat run scripts/createMetatadata.js --network rinkeby

async function storeAsset() {
   const client = new NFTStorage({ token: NFT_STORAGE_API_KEY })
   const metadata = await client.store({
       name: 'ExampleNFT',
       description: 'My ExampleNFT is an awesome artwork!',
       image: new File(
           [await fs.promises.readFile('images/11.jpg')],
           'images/11.jpg',
           { type: 'image/jpg' }
       ),
       external_url: "https://example.com/?token_id=11",
        attributes: [
            {
               "trait_type" : "level",
               "value" : 3
            },
            {
               "trait_type" : "stamina",
               "value" : 11.7
            },
            {
               "trait_type" : "personality",
               "value" : "sleepy"
            },
            {
               "display_type" : "boost_number",
               "trait_type" : "aqua_power",
               "value" : 30
            },
            {
               "display_type" : "boost_percentage",
               "trait_type" : "stamina_increase",
               "value" : 15
            },
            {
               "display_type" : "number",
               "trait_type" : "generation",
               "value" : 1
            }
         ],
   })
   console.log("Metadata stored on Filecoin and IPFS with URL:", metadata.url)
} 

storeAsset()
   .then(() => process.exit(0))
   .catch((error) => {
       console.error(error);
       process.exit(1);
   });