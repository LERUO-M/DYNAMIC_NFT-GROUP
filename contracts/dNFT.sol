// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC4906.sol";


contract LeftyNFT is Initializable, ERC721Upgradeable, 
    OwnableUpgradeable, ReentrancyGuardUpgradeable, 
    UUPSUpgradeable, IERC4906 {

    uint256 public nextTokenId;
    string public _baseURI; // Using Pinata for hosting metadata and images
    uint256 public constant MAX_POINTS = 20;



    // Mapping
    mapping (address => uint256) TokenOwnership; // Maps an address to the token ID of the NFT they own
    mapping (uint256 => uint256) public tokenPoints;

    // Reserve slot gap
    uint256[50] private __gap;

    // Events
    event MintedNFT(uint256 tokenId, address owner);
    event UpdatedMetadata(uint256 tokenId);
    event PointsUpdated(uint256 tokenId, uint256 points);

    ///@custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, string memory baseURI_)  public initializer{
        _baseURI = baseURI_;
        __ERC721_init("G1 dNFT", "THLFT");
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
    }

    function mint (address to) public onlyOwner {
        require(balanceOf(to) == 0, "You are only allowed to mint one NFT and have already minted one");
        _safeMint(to , nextTokenId);
        nextTokenId++;

        emit MintedNFT(nextTokenId - 1, to);
    }

    function updatePoints(uint256 tokenId, uint256 points) public onlyOwner {
        require(tokenPoints[tokenId] + points <= MAX_POINTS, "Points exceed maximum");
        tokenPoints[tokenId] = tokenPoints[tokenId] + points;
        emit PointsUpdated(tokenId, tokenPoints[tokenId]);
        emit UpdatedMetadata(tokenId);
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }



    function _authorizeUpgrade(address newImpl) internal override  onlyOwner {}
}