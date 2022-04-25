// SPDX-License-Identifier: Unlicense
pragma solidity >=0.4.22 <0.9.0;

import "./SimpleERC721.sol";
import "./VRFConsumerBase.sol"; // 
// import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/utils/Context.sol"; // 
import "@openzeppelin/contracts/utils/math/SafeMath.sol"; // безопасная библиотека для простых арифетич вычислений 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // удобно для хранения метаданных Nft, наследует ERC721 ()
import "@openzeppelin/contracts/access/AccessControl.sol"; // библиотека для ролей, вместо библиотки Ownable.sol 
import "@openzeppelin/contracts/security/PullPayment.sol"; // библиотека для приема платежей на контракт 
import "hardhat/console.sol"; // вспомогатльная при разработке библиотка для вывода консольных сообщений 
import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol"; // простая библиотека периода lock(а) токенов
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; // подпись
// import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol"; // проверка подписи 

// https://docs.openzeppelin.com/contracts/2.x/crowdsales#postdeliverycrowdsale
// https://www.youtube.com/watch?v=W2k32FrAD1k  Protect Your Users With Smart Contract Timelocks (OZ Defender)
// 

contract EasyMarketPlace is AccessControl, PullPayment {

bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

using SafeMath for uint256; // SafeMath - для безопасных арифме 
SimpleERC721 private simpleERC721; 
// bytes32 _digest;
uint public totalSales; // общее количество продаж
uint32 private vestingPeriod; // time in seconds
address payable private withdrewAddr; 
mapping(address => uint[]) private marketPlaceItems; // список все токенов маркеплайса  
mapping(uint => bool) internal tokenSaleStatus; // стутус продажи токена true в продаже false нет 
// address private externalERC721Contract;
// mapping(uint => Auction) private _dealerInAuction; // idтокена => структура сделки на аукцион
mapping(uint => Deal) private _dealerInDeal; // idтокена => nftContract => структура сделки на продажу
mapping(address => uint[]) private byersItems; // адрес покупателя => его id токены
// address[] private byers; // в массив покупателей попадают только те пользователи кто уже фактически владеют купленным или полученным 
                        // в результате розыгрыша аукцона но еще не прошли период vestingа для факичекой передачи токена 
                        // на адрес пользователя.   

constructor(uint32 _vestingPeriod, address _simpleERC721) {
vestingPeriod = _vestingPeriod; // time in seconds 
simpleERC721 = SimpleERC721(_simpleERC721);
_grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
_grantRole(MINTER_ROLE, _msgSender()); // роль минтера токенов по умолxfнию msg.sender 
// withdrewAddr = _withdrewAddr; // адрес, если на контракт будут приходить платежи 
}

// enum Step {ListItem, BuyItem}

// проверка что период вестинга уже истек
modifier chekVestingPeriod(uint _selectId) {
    require(byersItems[msg.sender].length != 0, "this buyer did not make a deal to buy this token"); 
    uint _purchaseTime = _dealerInDeal[_selectId].purchaseTime;
    require(block.timestamp >= _purchaseTime + vestingPeriod,"vesting period has not yet expired"); 
    _;
}
// проверка что вызвать метод может только покупатель 
modifier onlyBuyer(address _address) {
     (bool exist) = isBayer(_address);
        require(exist, "you are not in the list of buyers");
        _;  
}

// событие создать токен 
event createItemEvent(  
    uint _selectId, 
    string _uri, 
    uint setRandomNum,
    bytes32 sign
    );
// событие разместить на продажу токен 
event ListItemEvent(
    address indexed _dealer,
    uint _selectId, 
    uint price
    );  

// // событие кто то купил токен 
event BuyItemEvent(
    address indexed _dealer,
    address indexed _buyer, 
    uint _selectId, 
    uint price,
    uint purchaseTime, 
    bytes32 digest
    );

// срукура для сделки 
struct Deal {
        address dealer;
        uint id;
        uint price;
        uint purchaseTime;
    }
// struct Auction { }
// минт токенов из данного контракта  
function createItemFromERC721Contract(string memory _uri, uint setRandomNum, bytes calldata signature) external onlyRole(MINTER_ROLE) returns(uint _id){
 // require(keccak256(bytes(_uri)) != keccak256(bytes("null")), "Invalid Name"); // проверка на пустую строку 
    require(bytes(_uri).length != 0, "empty uri line"); 
    require(setRandomNum > 0, "num less then 0"); 
    (uint _setRandom) = setRandomNumber(_uri, setRandomNum);
    bytes32 _sign = _hash(msg.sender, _setRandom, _uri); // хэшируем данные 
    (_id) = simpleERC721.FreeMintTokenForMarketPlace(_uri, _sign, signature); // отправляем на сверку хэшир данные 
    marketPlaceItems[address(this)].push(_id);
    tokenSaleStatus[_id] == false;
    emit createItemEvent(_id, _uri, _setRandom, _sign);
    return _id; 
}   
// служебный метод для генерации рандом числа 
function setRandomNumber(string memory _uri, uint _setRandomNum) private view returns(uint _setRandom) {
    require(bytes(_uri).length != 0, "empty uri line");
    require(_setRandomNum > 0, "num less then 0"); 
    uint32 module = 1000;
    return _setRandom = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _setRandomNum))) % module;
}

// верификация подписи 
function _verify(bytes32 digest, bytes calldata signature)
    internal view returns (bool)
    {
        address signer;
        signer = ECDSA.recover(digest, signature);
            if (signer == msg.sender) { 
                return true;
            } else {
                return false;
            }
    }
 // генерация хэша для подписи 
function _hash(address account, uint256 randomNum, string memory _uri)
    internal pure returns (bytes32)
    {
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(account, randomNum, _uri)));
    }

// размещение токена на продажу 
 function listItemOnSale( 
        uint _selectId, // id токена 
        uint _price  // в ETH, нативная валюта блокчейна 
    )   
        external
        onlyRole(DEFAULT_ADMIN_ROLE) 
        returns(bool)
    {
    require(_price > 0, "price less then 0");      
    require(tokenSaleStatus[_selectId] == false, "this token is already on sale"); 
    
     for (uint i = 0; i < marketPlaceItems[msg.sender].length;) {
            if (_selectId == marketPlaceItems[msg.sender][i]){
                _dealerInDeal[_selectId] = Deal({
                    dealer: msg.sender,
                    id: _selectId,
                    price: _price,  
                    purchaseTime: 0
                });
                tokenSaleStatus[_selectId] == true;
                emit ListItemEvent(address(this), _selectId, _price);
                return true;
            } i++;
             } 
              console.log("this contract does not have such IDs: ", _selectId);
              return false;
    }

// купить токен 
 function buyItem(uint _selectId)
        public
        payable  
    { 
    require(tokenSaleStatus[_selectId] == true, "this token has already been sold"); 
    require(_dealerInDeal[_selectId].price == msg.value, "sent amount in ETH not corresponding to the price of the token");  
    string memory _uri = simpleERC721.tokenURI(_selectId);
    // по логикике здесь должна быть исполонена функция трансфер для передачи токена покупателю 
    // но так как по замыслу и в целях безопасноси покупатель получает токены только спустя 
    // определенное время тогда просто добавлем в корзину покупателя данный токен и ставим в лист ожидания на получение: 
    // simpleERC721.safeTransferFrom( // нужен approve
    //                 address(this), 
    //                 msg.sender, 
    //                 _selectId  
    //             );  
    require(bytes(_uri).length != 0, "empty uri line"); 
    (uint _setRandom) = setRandomNumber(_uri, _selectId);
    bytes32 digest = _hash(msg.sender, _setRandom, _uri);
    byersItems[msg.sender].push(_selectId); // корзина покупок покупателя 
    _dealerInDeal[_selectId].purchaseTime = block.timestamp;
    tokenSaleStatus[_selectId] == false;
    totalSales = totalSales.add(msg.value); 
    emit BuyItemEvent(address(this), msg.sender, _selectId, 
    _dealerInDeal[_selectId].price , _dealerInDeal[_selectId].purchaseTime, digest);
    }

//  снять токены после покупки, ползователя не может забрать свой ранее купленный токен пока не пройдет период вестинга 
function withdrawToken(uint _selectId, bytes32 _digest, bytes calldata signature) public chekVestingPeriod(_selectId) onlyBuyer(msg.sender) {
(string memory _uri) = simpleERC721.tokenURI(_selectId);
require(bytes(_uri).length != 0, "empty uri line");
require(_verify(_digest, signature), "Invalid signature");
for (uint i = 0; i < byersItems[msg.sender].length; i++) {
            if (_selectId == byersItems[msg.sender][i]){
                ERC721URIStorage(address(this)).transferFrom(address(this), msg.sender, _selectId); // необх approve на списание
                // ERC721(address(this)).transferFrom(address(this), msg.sender, _selectId); // необх approve на списание
            }
    } 
// допиши метод который удаляет покупателя если у него нет больше покупок в корзине 
}
 // снять полученные платежи в ETH от продажи токенов в аргументах передается аддрес для получения, вызвать метод может только админ 
function withdrawPayments(address payable payee) public override onlyRole(DEFAULT_ADMIN_ROLE) virtual {
    require(payee != address(0), "wrong payment address");
    //   require(withdrewAddr == payee, "address does not match");
      super.withdrawPayments(payee);
  }

// снять с адреса маркетплейса полученные от продажи токенов платежи только в указанном кол-ве _value
 function withdrawPayments(uint256 _value) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint _balance = address(this).balance;
        require(_value <= _balance, "wrong amount");
        _balance = _balance.sub(_value);
        totalSales = _balance;
        withdrewAddr.transfer(_value);
    }
// смена адреса на который можно отправить выручку от продажи токенов 
function setAddrForWithdrewPayments(address payable _withdrewAddr) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(_withdrewAddr != address(0), "wrong new payment address");
        withdrewAddr = _withdrewAddr;
}
 // проверка есть ли покупатель в массиве покупателей 
 function isBayer(address _address) public view returns (bool) {
     if(byersItems[_address].length != 0) {
     return true;    
     } else {return false;}
  }

// изменить период вестинга (задержки токена на балансе маркетплейса) после продажи/акуциона 
function changeVestingPeriod(uint32 _newVestigTime) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_newVestigTime > 0, "time in sec must be greater than 0");
        vestingPeriod = _newVestigTime;
   }
// вернуть tokenURI по Id токена 
function getTokenURIFromERC721Contract(  
        uint _selectId
    )   
        external
        view
        returns (string memory _uri)
    {   
         for (uint i = 0; i < marketPlaceItems[msg.sender].length;) {
            if (_selectId == marketPlaceItems[msg.sender][i]){
               (_uri) = simpleERC721.tokenURI(_selectId);
                return _uri;
                } i++;
            } 
    }

// ДОПОЛНИЕЛЬНЫЕ ФУНКЦИИ маркетплейса без реализации, для ускорения время сдачи задания:   
function listItemOnAuction(uint _selectId, address _nftContract, 
        uint _minPrice, address _erc20Contract) external onlyRole(DEFAULT_ADMIN_ROLE) {} // разместить токен на аукцион
function cancelSale(uint _selectId) external onlyRole(DEFAULT_ADMIN_ROLE) {} // отменить продажу по Id токена 
function cancelAction(uint _selectId) external onlyRole(DEFAULT_ADMIN_ROLE) {} // отменить аукцион раздать пользователям ERC20 токены ставок 
function finishAuction(uint _selectId) external onlyRole(DEFAULT_ADMIN_ROLE) {} // завершить аукцион 
function makeBid(uint _selectId) public {} // сделать ставку по Id токена 
function cancelBid(uint _selectId) external {} // отмена ставки по Id токена 
function distributeTokens() internal {} // автоматич. распределить токены после проведения аукциона или продажи  
function setTokenUri() external onlyRole(DEFAULT_ADMIN_ROLE) {} // смена адреса URI по id токена для внешнего контракт SimpleERC721
                                             // также можно добавить иные функции такие как burn, ....

/** 
 * @dev Описание к методу withdrewToken() 
 *  Описание к методу withdrewToken() 
 * получить свои токены после продажи или по результату розыгрыша аукциона вызваь может только покупатель, по истечении указанного времени. 
 * Пользователь должен самостоятель воспользоватся функцией которая позволит забрать ему свои токены, 
 * для того что бы он мог понять когда он может забрать свой токен в вебинтерфейсе (личном кабинете маркетплейса) после того 
 * как он купить свой токен или выиграет в аукционе, будет активированно время в формате HH.MM.SS которое ему осталось
 * прежде чем он может воспользоватся кнопкой withdrew() - забрать купленный токен. Веб интерфейс должен уведомит о том что произошла 
 * смена пользователя событием someEvent(_selectId, block.timstaps, newOwnerAddres...) о том что права на владением 
 * токена перешли к новому пользователю и активированно время вестинга в течении которого токен будет находится на адресе маркетплейса 
 * к примеру это может быть не время в секундах а определенное количество смайненны блоков в блокчейне block.blockNumber
 * Когда время время вестинга выйдет пользователь получит уведомление (в личный кабинет иным способом...) войдет в свой акаунт 
 * на маркет плейсе увидит что период вестина пройден и нажмет кнопку "Забрать Токен", web3 реализация в веб приложении пойдет 
 * в блокчейн по адресу маркетплейс инициировав смену собственника с адреса маркетплейса address(this) и передачу токена методом 
 * базовым методом safeTransferFrom() на адресс пользователя, перед передачей соот-но необходимо будет окончаельно убедиться 
 * что новый пользователь в массиве покупателей, также что он купил данный токен и все суммы ранее были уплачены, 
 * дополнительно момжно сделать: сверку по датам, также можно подписать момент заключения сделки криптографич методом 
 * используя библиотеку ECDSA.sol и уже при передачи токена встроенной функции ecrecover убедиться что именно этот адресс 
 * пользователя купил и может забрать свой токен, другие доп проверки там где они уместны.... 
 * Также можно сделать чуть по сложнее и инициировать передачe токена пользователю автоматически после истечении периода 
 * вестинга что бы пользователю автоматически падали на адрес его ранее купленные токен(ы), для этого я полагаю 
 * в вебинтерсфейс маркетплейса может просто получать уведомления (Event) обовсе сделках из метода buyItem(), 
 * и автоматически запускать таймер до того момента когда передача токена буде возможна, после исечения периода вестинга 
 * вебинтерфейс маркетплейса автомаич пойдет в блокчейн вызовет метод withdraw() передачи токена новому владельцу 
 * и после всех проверок вызывать в контракте функцию withdraw() с передачей токена на адрес нового владельца, 
 * таким образом пользователь не будет заморачиваться ожидая период окончание периода вестинга - токен просто упадет 
 * на его адрес. Также можно подумать в сторону написания оракула данных который off-chain уведомит смарт контракт маркетплейса 
 * о том что истек период вестинга и самостоятельно иницирует передачу токена пользователю из смарт контракт. 
 * Об оракула и почему они не безопасны: https://habr.com/ru/company/solarsecurity/blog/418791/
 * пример как создать собственные оракул: https://cryptozombies.io/ru/lesson/14 How to Build an Oracle
 * Chainlink узлы поставщиков данныx: https://market.link/
 * Chainlink Doc: https://docs.chain.link/docs/architecture-overview/
 * пример как использовать Chainlink https://cryptozombies.io/ru/lesson/19 
 */
}
