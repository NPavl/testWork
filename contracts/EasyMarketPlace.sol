// SPDX-License-Identifier: Unlicense
pragma solidity >=0.4.22 <0.9.0;

import "./SimpleERC721.sol";
// import "./VRFConsumerBase.sol"; // chainlink random num
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol"; 
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; 
import "@openzeppelin/contracts/access/AccessControl.sol"; 
import "@openzeppelin/contracts/security/PullPayment.sol"; 
import "hardhat/console.sol"; 
// import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol"; // не исп
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; 
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

// import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol"; 

// https://docs.openzeppelin.com/contracts/2.x/crowdsales#postdeliverycrowdsale
// https://www.youtube.com/watch?v=W2k32FrAD1k  Protect Your Users With Smart Contract Timelocks (OZ Defender)

library SetRandomAndSign {
    // use Chainlink (VRFConsumerBaseV2) for random number
    function setRandomNumber(string memory _uri, uint256 _setRandomNum)
        internal
        view
        returns (uint256 _setRandom, bytes32 _digest)
    {
        require(bytes(_uri).length != 0, "empty uri line");
        require(_setRandomNum > 0, "num less then 0");
        uint32 module = 1000;
        _setRandom =
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, _setRandomNum)
                )
            ) %
            module;
        _digest = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encodePacked(msg.sender, _setRandom, _uri))
        ); 
        return (_setRandom, _digest);
    }
}

contract EasyMarketPlace is AccessControl, EIP712, PullPayment {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using SafeMath for uint256; 
    SimpleERC721 private simpleERC721;
    uint256 public totalSales; 
    uint32 public vestingPeriod; 
    address payable private withdrewAddr;
    mapping(address => uint256[]) private marketPlaceItems; 
    mapping(uint256 => bool) internal tokenSaleStatus;
    // mapping(uint => Auction) private _dealerInAuction; 
    mapping(uint256 => Deal) private _dealerInDeal; 
    mapping(address => uint256[]) private byersItems; 
    mapping(address => mapping(uint => bytes32)) private itemsDigest; // buyer => (tokend => hash)

    constructor(uint32 _vestingPeriod, address _simpleERC721)
        EIP712("Vasia", "1.0.0")
    {
        vestingPeriod = _vestingPeriod; // time in seconds
        simpleERC721 = SimpleERC721(_simpleERC721);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        // _grantRole(MINTER_ROLE, _msgSender()); 
        // withdrewAddr = _withdrewAddr;
    }
    
    // enum Step {ListItem, BuyItem}
    
    modifier chekVestingPeriod(uint256 _selectId) {
        require(
            byersItems[msg.sender].length != 0,
            "this buyer did not make a deal to buy this token"
        );
        uint256 _purchaseTime = _dealerInDeal[_selectId].purchaseTime;
        require(
            block.timestamp >= _purchaseTime + vestingPeriod,
            "vesting period has not yet expired"
        );
        _;
    }
    modifier onlyBuyer(address _address) {
        bool exist = isBayer(_address);
        require(exist, "you are not in the list of buyers");
        _;
    }

    event createItemEvent(uint256 _selectId, string _uri);

    event ListItemEvent(
        address indexed _dealer,
        uint256 _selectId,
        uint256 price
    );

    event BuyItemEvent(
        address indexed _dealer,
        address indexed _buyer,
        uint _selectId,
        uint setRandom,
        uint price,
        uint purchaseTime,
        bytes32 digest
    );
    struct Deal {
        address dealer;
        uint256 id;
        uint256 price;
        uint256 purchaseTime;
    }
    
    // struct Auction { }
    function createItemFromERC721Contract(string memory _uri)
        external
        onlyRole(MINTER_ROLE)
        returns (uint256 _id)
    {
        // require(keccak256(bytes(_uri)) != keccak256(bytes("null")), "Invalid Name"); 
        require(bytes(_uri).length != 0, "empty uri line");
        (_id) = simpleERC721.FreeMintTokenForMarketPlace(_uri); 
        marketPlaceItems[address(this)].push(_id);
        tokenSaleStatus[_id] == false;
        emit createItemEvent(_id, _uri);
        return _id;
    }
    function _verify(bytes32 digest, bytes calldata _signature)
        internal
        view
        returns (bool)
    {
        address signer;
        signer = ECDSA.recover(digest, _signature);
        if (signer == msg.sender) {
            return true;
        } else {
            return false;
        }
    }
    function _hash(
        address account,
        uint256 randomNum,
        string memory _uri
    ) internal pure returns (bytes32) {
        return
            ECDSA.toEthSignedMessageHash(
                keccak256(abi.encodePacked(account, randomNum, _uri))
            );
    }
    function listItemOnSale(
        uint256 _selectId, 
        uint256 _price 
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        require(_price > 0, "price less then 0");
        require(
            tokenSaleStatus[_selectId] == false,
            "this token is already on sale"
        );

        for (uint256 i = 0; i < marketPlaceItems[msg.sender].length; ) {
            if (_selectId == marketPlaceItems[msg.sender][i]) {
                _dealerInDeal[_selectId] = Deal({
                    dealer: msg.sender,
                    id: _selectId,
                    price: _price,
                    purchaseTime: 0
                });
                tokenSaleStatus[_selectId] == true;
                emit ListItemEvent(address(this), _selectId, _price);
                return true;
            }
            i++;
        }
        console.log("this contract does not have such IDs: ", _selectId);
        return false;
    }
    
    function buyItem(uint _selectId) external payable returns(uint setRandom, bytes32 _digest) {
        require(
            tokenSaleStatus[_selectId] == true,
            "this token has already been sold"
        );
        require(
            _dealerInDeal[_selectId].price == msg.value,
            "sent amount in ETH not corresponding to the price of the token"
        );
        string memory _uri = simpleERC721.tokenURI(_selectId);
        // simpleERC721.safeTransferFrom( // нужен approve
        //                 address(this),
        //                 msg.sender,
        //                 _selectId
        //             );
        require(bytes(_uri).length != 0, "empty uri line");
        (setRandom, _digest) = SetRandomAndSign.setRandomNumber(_uri, _selectId);
        itemsDigest[msg.sender][_selectId] = _digest;
        byersItems[msg.sender].push(_selectId); 
        _dealerInDeal[_selectId].purchaseTime = block.timestamp;
        tokenSaleStatus[_selectId] == false;
        totalSales = totalSales.add(msg.value);
        emit BuyItemEvent(
            address(this),
            msg.sender,
            _selectId,
            setRandom,
            _dealerInDeal[_selectId].price,
            _dealerInDeal[_selectId].purchaseTime,
            _digest
        );
        return (setRandom, _digest);
    }
    function withdrawToken(
        uint256 _selectId,
        bytes calldata signature
    ) public chekVestingPeriod(_selectId) onlyBuyer(msg.sender) {
        string memory _uri = simpleERC721.tokenURI(_selectId);
        require(bytes(_uri).length != 0, "empty uri line");
        bytes32 _digest = itemsDigest[msg.sender][_selectId];
        require(_verify(_digest, signature), "Invalid signature");
        for (uint256 i = 0; i < byersItems[msg.sender].length; i++) {
            if (_selectId == byersItems[msg.sender][i]) {
                ERC721URIStorage(address(this)).transferFrom(
                    address(this),
                    msg.sender,
                    _selectId
                ); // make approve 
                // ERC721(address(this)).transferFrom(address(this), msg.sender, _selectId); 
            }
        }
    }
    function withdrawPayments(address payable _address)
        public
        virtual
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_address == withdrewAddr, "wrong payment address");
        super.withdrawPayments(_address);
    }
    function partilWithdrawPayments(uint256 _value)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 _balance = address(this).balance;
        require(_value <= _balance, "wrong amount");
        _balance = _balance.sub(_value);
        totalSales = _balance;
        withdrewAddr.transfer(_value);
    }
    function setAddrForWithdrewPayments(address payable _withdrewAddr)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_withdrewAddr != address(0), "wrong new payment address");
        withdrewAddr = _withdrewAddr;
    }
    function isBayer(address _address) public view returns (bool) {
        if (byersItems[_address].length != 0) {
            return true;
        } else {
            return false;
        }
    }
    function changeVestingPeriod(uint32 _newVestigTime)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_newVestigTime > 0, "time in sec must be greater than 0");
        vestingPeriod = _newVestigTime;
    }
    function getTokenURIFromERC721Contract(uint256 _selectId)
        external
        view
        returns (string memory _uri)
    {
        for (uint256 i = 0; i < marketPlaceItems[msg.sender].length; ) {
            if (_selectId == marketPlaceItems[msg.sender][i]) {
                (_uri) = simpleERC721.tokenURI(_selectId);
                return _uri;
            }
            i++;
        }
    }

    // ДОП ФУНКЦИИ маркетплейса без реализации, для ускорения время сдачи задания:
    function listItemOnAuction(
        uint256 _selectId,
        address _nftContract,
        uint256 _minPrice,
        address _erc20Contract
    ) internal onlyRole(DEFAULT_ADMIN_ROLE) {} 

    function cancelSale(uint256 _selectId)
        internal
        onlyRole(DEFAULT_ADMIN_ROLE)
    {} 

    function cancelAction(uint256 _selectId)
        internal
        onlyRole(DEFAULT_ADMIN_ROLE)
    {} 

    function finishAuction(uint256 _selectId)
        internal
        onlyRole(DEFAULT_ADMIN_ROLE)
    {} 

    function makeBid(uint256 _selectId) internal {} 

    function cancelBid(uint256 _selectId) internal {} 

    function distributeTokens() internal onlyRole(DEFAULT_ADMIN_ROLE) {} 
    function setTokenUri() internal onlyRole(DEFAULT_ADMIN_ROLE) {} 
}
