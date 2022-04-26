const { ethers }  = require('hardhat');

// const { PRIVATE_KEY, ADMIN, PRIVATE_KEY_BYER, 
          //  URL_ALCHEMY, MINTER_ADDRESS, 
          //  BUYER, ACCOUNT_MPCONTRACT, 
          //  MARKET_PLACE_CONTRACT, SIMPLE_ERC721
          //  META_DATA_URL, VESTING_PERIOD, TOKEN_ID} = process.env

// npx hardhat run scripts/buyItem.js --network localhost
// npx hardhat run scripts/buyItem.js --network rinkiby

  // простой пример https://xtremetom.medium.com/verifying-solidity-signatures-4898d003846b
  // ппример для генерации хэша:
  // const messageHash = ethers.utils.solidityKeccak256( ["address", "uint"], [userWallet.address, timestamp]);

// используемый в проекте: https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/scripts

async function main() { 
  
  const [ADMIN, MINTER_ADDRESS, BUYER] = await ethers.getSigners()
  
  const TOKEN_ID = 1
  const VESTING_PERIOD = 60 // сек 
  const META_DATA_URL = "ipfs://testUri.json"
  const SIMPLE_ERC721 = ""

  // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // ADMIN = new ethers.Wallet(PRIVATE_KEY, provider)
  // const provider = new ethers.providers.JsonRpcProvider(URL_ALCHEMY)
  // BUYER = new ethers.Wallet(PRIVATE_KEY_BYER, provider)
  
  // const myContract = await ethers.getContractAt('EasyMarketPlace', MARKET_PLACE_CONTRACT, ADMIN)

  // первый этап деплой конракта, создание роли минтера, минт 1 токена: 

  const Contract = await ethers.getContractFactory("EasyMarketPlace");
  const myContract = await Contract.deploy(VESTING_PERIOD, SIMPLE_ERC721); // uint32 _vestingPeriod, address _simpleERC721
  
  const { chainId } = await ethers.provider.getNetwork()
  
  await myContract.connect(ADMIN).grantRole(await myContract.MINTER_ROLE(), MINTER_ADDRESS.address);
  
  const tx = await myContract.connect(MINTER_ADDRESS).createItemFromERC721Contract(META_DATA_URL)
  const result = await tx.wait()
  console.log("result from method createItemFromERC721Contract: ", result)
  
  // второй этап покупатель покупает токен: 

  const { _uri } = await myContract.getTokenURIFromERC721Contract(TOKEN_ID)
  console.log("URI: ", _uri)

  {setRandom, _digest} await myContract.connect(BUYER).buyItem(TOKEN_ID)
  //   const _digestToBytes32 = ethers.utils.arrayify(_digest);
  //   https://docs.ethers.io/v4/api-utils.html
  //   utils.arrayify(hexStringOrBigNumberOrArrayish)=>Uint8Array

  // ethers.utils.parseBytes32(_digest) 
  //  ethers.utils.formatUnits(_digest, 18) 
  // https://web3-type-converter.onbrn.com/
  // https://github.com/BrunoBernardino/web3-type-converter/blob/master/src/js/main.js  
  // STEP 2: 32 bytes of data in Uint8Array
  // const messageHashBinary = ethers.utils.arrayify(messageHash);
  
  console.log("result random from setRandomNumber: ", setRandom)
  console.log("result _digest from setRandomNumber: ", _digest)
  
  // используемый подход подписи в маркетплейс контракте для подписи покупок: 
  // EIP712(name, "1.0.0")  (draft-EIP712.sol) 
  // второй вариант:  https://docs.ethers.io/v5/api/signer/#Signer-signTypedData
  const signature  = await BUYER._signTypedData(
   // Domain 
    {
      name: 'Vasia',  
      version: '1.0.0',
      chainId,
      verifyingContract: myContract.address,
    }, 
   // Types
    {
      NFT: [
         { name: 'Buyer', type: 'address' },
        { name: 'RandomNum', type: 'uint256' },
        { name: 'URI', type: 'string' },
      ],
    },   
    // Value
    { BUYER, setRandom, _uri }, 
  );
  console.log("Signature: ", signature);

  // 3 этап покупатель забирает свой ранее купленный токен на свой адрес со сверкой подписи : 
  
  const _tx = await myContract.connect(BUYER).withdrawToken(TOKEN_ID)
  const _result = await _tx.wait()
  console.log("result from method createItemFromERC721Contract: ", _result)
  
  const buyerTokenBalance = await myContract.connect(BUYER).balanceOf(BUYER.address)

  console.log("buyerBalance ETH:", (await BUYER.getBalance()).toString());
  console.log("buyerBalance token:", buyerTokenBalance);
  
  console.log("=====================================FINAL RESULT: ")
  console.log(`MARKET address:: ${myContract.address}, 
               ERC721 address: ${SIMPLE_ERC721}, 
               Admin address: ${ADMIN.address},
               Minter address: ${MINTER_ADDRESS.address},
               RandomNumber: ${setRandom}, 
               Digest: ${_digest},
               Buyer address: ${BUYER.address}, 
               Signature: ${signature}, 
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


