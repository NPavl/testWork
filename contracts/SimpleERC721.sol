// SPDX-License-Identifier: Unlicense
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract SimpleERC721 is ERC721URIStorage, AccessControl, PullPayment {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    bytes32 digest;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address private mpContract;
    Counters.Counter private currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 100_000;
    uint256 public constant MINT_PRICE = 0.001 ether;
    uint256 public totalSales;
    string public baseTokenURI;

    constructor()
        ERC721("NFTForMarketPlace", "NFT01") // Initializes the domain separator and parameter caches. draft-EIP712.sol
    {
        baseTokenURI = "ipfs://";
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function PaidMintTokensForAll(string memory _uri)
        public
        payable
        returns (uint256 _id)
    {
        uint256 tokenId = currentTokenId.current();
        require(tokenId < TOTAL_SUPPLY, "Max supply reached");
        require(
            msg.value == MINT_PRICE,
            "Transaction value did not equal the mint price"
        );

        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, _uri);
        totalSales = totalSales.add(msg.value);
        return newItemId;
    }

    function FreeMintTokenForMarketPlace(string memory _uri)
        public
        onlyRole(MINTER_ROLE)
        returns (uint256 _id)
    {
        uint256 tokenId = currentTokenId.current();
        require(tokenId < TOTAL_SUPPLY, "Max supply reached");
        currentTokenId.increment();
        _id = currentTokenId.current();
        _safeMint(mpContract, _id);
        _setTokenURI(_id, _uri);
        return (_id);
    }

    function setBaseTokenURI(string memory _baseTokenURI)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function withdrawPayments(address payable payee)
        public
        virtual
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        super.withdrawPayments(payee);
        totalSales = 0;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function remainingTokensforMint() public view returns (uint256 res) {
        res = TOTAL_SUPPLY - currentTokenId.current();
        return res;
    }
}
