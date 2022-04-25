### task Description: 

https://testnets.opensea.io/get-listed/
https://app.pinata.cloud/pinmanager

#### contracts : 	

- contract EasyMarketPlace = ''
- contract SimpleERC721 = ''

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
npx hardhat verify --constructor-args scripts/arguments.js <conract_address> --network rinkiby
yarn run hardhat size-contracts 
yarn run hardhat size-contracts --no-compile
```

#### Testing report   

How to use TokenTimelock.sol to lock up tokens?
https://forum.openzeppelin.com/t/how-to-use-tokentimelock-sol-to-lock-up-tokens/738/2
Protect Your Users With Smart Contract Timelocks
https://www.youtube.com/watch?v=W2k32FrAD1k

https://docs.openzeppelin.com/contracts/2.x/crowdsales#postdeliverycrowdsale  The PostDeliveryCrowdsale, как следует из названия, распределяет токены после завершения краудсейла, позволяя пользователям звонить withdrawTokens, чтобы получить купленные ими токены.

How To Use AccessControl.sol
https://medium.com/coinmonks/how-to-use-accesscontrol-sol-9ea3a57f4b15
Access Control - OpenZeppelin Docs
https://docs.openzeppelin.com/contracts/4.x/api/access

Роли можно назначать и отзывать динамически с помощью функций grantRole и . revokeRole С каждой ролью связана роль администратора, и только учетные записи, имеющие роль администратора роли, могут вызывать grantRole и revokeRole.

По умолчанию роль администратора для всех ролей — DEFAULT_ADMIN_ROLE, что означает, что только учетные записи с этой ролью смогут предоставлять или отзывать другие роли. Более сложные ролевые отношения можно создать с помощью _setRoleAdmin. Он DEFAULT_ADMIN_ROLE также является собственным администратором: у него есть право назначать и отзывать эту роль. Следует принять дополнительные меры предосторожности для защиты учетных записей, которым он был предоставлен!.  https://docs.openzeppelin.com/contracts/4.x/api/access#AccessControl

