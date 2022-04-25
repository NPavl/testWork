
// SPDX-License-Identifier: Unlicense
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // наследует ERC721  
// import "@openzeppelin/contracts/access/Ownable.sol"; // более простой механизм с одной «ролью» владельца
import "@openzeppelin/contracts/utils/math/SafeMath.sol"; // стандартная безопасная библиотека для простых арифетич вычислений 
import "@openzeppelin/contracts/utils/Counters.sol"; // безопасный способ для инкремента  
import "@openzeppelin/contracts/security/PullPayment.sol"; // возможность безопасно принимать платежи в контракт 
import "@openzeppelin/contracts/access/AccessControl.sol"; // библиотка для ролей, альтернатива Ownable 
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; // создание  верификация криптографич подписи 
// import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
// import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol"; 

contract SimpleERC721 is ERC721URIStorage, AccessControl, PullPayment{
  using Counters for Counters.Counter; // билиотека для автоматич инкремента id токена 
  using SafeMath for uint256; // безопасна библиотека для арифметич вычислений 
  bytes32 digest; // хэш подписи 
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // bytes32 идентификатор роли 
  address private mpContract; // адрес контракта маркет плейса для вызова метода FreeMintTokenForMarketPlace() 
  Counters.Counter private currentTokenId;
  uint256 public constant TOTAL_SUPPLY = 100_000; // максим возможный минт токенов 
  uint256 public constant MINT_PRICE = 0.001 ether; // плата за минт токенов 
  uint public totalSales; // общее кол-во продаж 
  string public baseTokenURI; // базовая строка URI 
  
  constructor(address _mpContract) 
  ERC721("NFTForMarketPlace", "NFT01")  // Initializes the domain separator and parameter caches. draft-EIP712.sol 
  { 
         baseTokenURI = "ipfs://"; // установить базовый URI для всех токенов 
         mpContract = _mpContract;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // роль администратора 
        _grantRole(MINTER_ROLE, mpContract); // роль минтера для маркетплейс контракта 
        // КОРОТКОЕ ПОЯСНЕНИЕ К РОЛЯМ: 
        // В данном конракте 2 роли роль Админа корневой (bytes32 0x00) (это адрес деплоера контракта)
        // 2 роль для минта токенов MINTER_ROLE - адрес контракта маркетплейса mpContract 
        // Только Корневой адрес может управлять всеми ролями контракта, вот основные методы для работы с ролями 
        // которые доступны в этом контракте, вызывать методы может только корневой адресс Админа:  
        // grantRole(bytes32 role, address account) установить роль из root адреса 0x00. 
        // revokeRole(bytes32 role, address account) отозвать роль у адреса. 
        // hasRole(bytes32 role, address account) чекнуть роль на наличие в контракте return bool. 
  }

// проверка на то что толко адресс маркет плейса может вызывать метод
// modifier onlyMarketPlace(address _address) {
//         require(_address == mpContract, "you are not in the list of buyers");
//         _;  
// }

// установить адресс маркетплейса , это может сделать только DEFAULT_ADMIN_ROLE
function setMarketPlaceAddress(address _mpContract) external onlyRole(DEFAULT_ADMIN_ROLE){
    
    mpContract = _mpContract;
}
   // платный метод для чеканки токенов любому желающему за установленную админом контракта плату MINT_PRICE
    function PaidMintTokensForAll(string memory _uri) public payable returns (uint _id) {
    uint tokenId = currentTokenId.current();
    require(tokenId < TOTAL_SUPPLY, "Max supply reached");
    require(msg.value == MINT_PRICE, "Transaction value did not equal the mint price");
    
    currentTokenId.increment(); 
    uint newItemId = currentTokenId.current();
    _safeMint(msg.sender, newItemId); // мин токена 
    _setTokenURI(newItemId, _uri); // установить URI для токена (можно предать любую строку и изменть позже)
    totalSales = totalSales.add(msg.value); // обще кол-во собранные платежей за минт токенов с пользователей 
    return newItemId;
  }
   // бесплатный метод минта токенов только для маркетплейса, минитить токены может только адесс маркетплейса 
   // аргументами необходимо передать заранее сгенерированную строку метаданных _uri 
   function FreeMintTokenForMarketPlace(string memory _uri, bytes32 _digest, bytes calldata signature) 
   public onlyRole(MINTER_ROLE) returns (uint _id) { // payable (remix)
    uint tokenId = currentTokenId.current();
    require(tokenId < TOTAL_SUPPLY, "Max supply reached");
    currentTokenId.increment();
    _id = currentTokenId.current();
    require(_verify(_digest, signature), "Invalid signature"); // подпишем и проверим адррес маркетплейса
    _safeMint(mpContract, _id);  // минт токенов и отправка их на адрес маркетплейса 
    _setTokenURI(_id, _uri); // установить URI для токена 
    return (_id); // вернем просто id токена 
   }
  // устновить базовый URI для всех токенов  
  function setBaseTokenURI(string memory _baseTokenURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
    baseTokenURI = _baseTokenURI;
  }
  // вернуть URI по токен Id 
  function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

  // снять полученные платежи в ETH от минта токенов в аргументах передается аддрес дя получения, вызвать метод может только админ 
  function withdrawPayments(address payable payee) public override onlyRole(DEFAULT_ADMIN_ROLE) virtual {
      super.withdrawPayments(payee);
      totalSales = 0;
  } // альтернатива https://github.com/NPavl/donationContract/blob/5663cc8aa2400d0e17563263fda097e321b48b74/contracts/Donation.sol#L91
  // генерация хэша для подписи 
  function _hash(address account, string memory _uri, uint _randomNum) internal pure returns (bytes32)
    {   // захэшируем адрес получателя токена (маркетплейс) и токен id 
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(account, _uri, _randomNum)));
    }
  // верификация подписи 
  function _verify(bytes32 digest_, bytes memory signature) internal view returns (bool)
    {   // проверка что подпись валидна и адрес минтера совпадает с адресом маркетплейса 
        // реализация бессмысленная сделана просто для тренировки на подписях. возвращает bytes 65 
        return hasRole(MINTER_ROLE, ECDSA.recover(digest_, signature));
    }
     // служебный метод, необходимо переопределить в контракте от базового ERC721, AccessControl
     function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // простой метод который вернет общее оставшееся кол-во для минта токенов 
    function remainingTokensforMint() public view returns(uint res) {
    res = TOTAL_SUPPLY - currentTokenId.current(); 
    return res;
    } 
}