### task Description: 

- Тестовое задание по Solidity.

Необходимо на тестовой сети Rinkeby создать смарт контракт, один из которых ERC 721a (К1), второй все равно какой (К2). В К1 необходимо сминтить токен на кошелек 1. Далее  необходимо реализовать процедуру по которой K2 получит возможность распоряжаться токеном Кошелька 1, что бы потом без участия Кошелька 1, K2 мог передать его токен на любой другой Кошелек в K1.
#### contracts : 	
- OLD (в старой версии есть описание всех методов) : 
contract EasyMarketPlace = https://rinkeby.etherscan.io/address/0x8b6c277c5E6A34058a43C66e0495c9B58f5df89D#code
contract SimpleERC721 = https://rinkeby.etherscan.io/address/0x10e6971b80942F8eF469638aDFC001B56966Ea9b#code
- UPDATE: 
contract EasyMarketPlace = 
contract SimpleERC721 = 

#### All packages:
```
yarn init 
yarn add --dev hardhat 
yarn add --dev @nomiclabs/hardhat-ethers ethers 
yarn add --dev @nomiclabs/hardhat-waffle ethereum-waffle chai
yarn add --save-dev @nomiclabs/hardhat-etherscan
yarn add install dotenv 
yarn add --dev solidity-coverage 
yarn add --dev hardhat-gas-reporter 
yarn add --dev hardhat-gas-reporter
yarn add --dev hardhat-contract-sizer
```
#### Main command:
```
npx hardhat 
npx hardhat run scripts/file-name.js
npx hardhat test 
npx hardhat coverage
npx hardhat run --network localhost scripts/deploy.js
npx hardhat run scripts/deploy.js --network rinkiby
npx hardhat verify <contract_address> --network rinkiby
npx hardhat verify --constructor-args scripts/arguments.js <contract_address> --network rinkiby
yarn run hardhat size-contracts 
yarn run hardhat size-contracts --no-compile
```

#### Testing report   


