// SPDX-License-Identifier: MIT

// GO TO LINE 1904 TO SEE WHERE THE BANANA CONTRACT STARTS
 
pragma solidity ^0.8.0;

import "./utils/Context.sol";
import "./introspection/IERC165.sol";
import "./ERC721/IERC721.sol";
import "./ERC721/extensions/IERC721Metadata.sol";
import "./ERC721/extensions/IERC721Enumerable.sol";
import "./ERC721/IERC721Receiver.sol";
import "./introspection/ERC165.sol";
import "./math/SafeMath.sol";
import "./utils/Address.sol";
import "./utils/EnumerableSet.sol";
import "./utils/EnumerableMap.sol";
import "./utils/Strings.sol";
import "./ERC721/ERC721.sol";
import "./access/Ownable.sol";



// Following the recent worldwide pandemic, emerging reports suggest that several banana species have begun exhibiting strange characteristics. Our research team located across the globe has commenced efforts to study and document these unusual phenomena.

// Concerned about parties trying to suppress our research, the team has opted to store our findings on the blockchain to prevent interference. Although this is a costly endeavour, our mission has never been clearer.

// The fate of the world's bananas depends on it.

// from our website (https://boringbananas.co)

// BoringBananasCo is a community-centered enterprise focussed on preserving our research about the emerging reports that several banana species have begun exhibiting strange characteristics following the recent worldwide pandemic. 
// Our research team located across the globe has commenced efforts to study and document these unusual phenomena. 
// Concerned about parties trying to suppress our research, the team has opted to store our findings on the blockchain to prevent interference. 
// Although this is a costly endeavour, our mission has never been clearer. 
// The fate of the world's bananas depends on it.

// BANANA RESEARCH TEAM:

// VEE - @thedigitalvee
// MJDATA - @ChampagneMan
// MADBOOGIE - @MadBoogieArt
// JUI - @mz09art
// BERK - @berkozdemir

pragma solidity ^0.8.0;
pragma abicoder v2;

contract BoringBananasCo is ERC721, Ownable {
    
    using SafeMath for uint256;

    string public BANANA_PROVENANCE = ""; // IPFS URL WILL BE ADDED WHEN BANANAS ARE ALL SOLD OUT
    
    string public LICENSE_TEXT = ""; // IT IS WHAT IT SAYS
    
    bool licenseLocked = false; // TEAM CAN'T EDIT THE LICENSE AFTER THIS GETS TRUE

    uint256 public constant bananaPrice = 25000000000000000; // 0.025 ETH

    uint public constant maxBananaPurchase = 20;

    uint256 public constant MAX_BANANAS = 8888;

    bool public saleIsActive = false;
    
    mapping(uint => string) public bananaNames;
    
    // Reserve 125 Bananas for team - Giveaways/Prizes etc
    uint public bananaReserve = 125;
    
    event bananaNameChange(address _by, uint _tokenId, string _name);
    
    event licenseisLocked(string _licenseText);

    constructor() ERC721("Boring Bananas Co.", "BBC") { }
    
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }
    
    function reserveBananas(address _to, uint256 _reserveAmount) public onlyOwner {        
        uint supply = totalSupply();
        require(_reserveAmount > 0 && _reserveAmount <= bananaReserve, "Not enough reserve left for team");
        for (uint i = 0; i < _reserveAmount; i++) {
            _safeMint(_to, supply + i);
        }
        bananaReserve = bananaReserve.sub(_reserveAmount);
    }


    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        BANANA_PROVENANCE = provenanceHash;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }


    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }
    
    
    function tokensOfOwner(address _owner) external view returns(uint256[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }
    
    // Returns the license for tokens
    function tokenLicense(uint _id) public view returns(string memory) {
        require(_id < totalSupply(), "CHOOSE A BANANA WITHIN RANGE");
        return LICENSE_TEXT;
    }
    
    // Locks the license to prevent further changes 
    function lockLicense() public onlyOwner {
        licenseLocked =  true;
        emit licenseisLocked(LICENSE_TEXT);
    }
    
    // Change the license
    function changeLicense(string memory _license) public onlyOwner {
        require(licenseLocked == false, "License already locked");
        LICENSE_TEXT = _license;
    }
    
    
    function mintBoringBanana(uint numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active to mint Banana");
        require(numberOfTokens > 0 && numberOfTokens <= maxBananaPurchase, "Can only mint 20 tokens at a time");
        require(totalSupply().add(numberOfTokens) <= MAX_BANANAS, "Purchase would exceed max supply of Bananas");
        require(msg.value >= bananaPrice.mul(numberOfTokens), "Ether value sent is not correct");
        
        for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = totalSupply();
            if (totalSupply() < MAX_BANANAS) {
                _safeMint(msg.sender, mintIndex);
            }
        }

    }
     
    function changeBananaName(uint _tokenId, string memory _name) public {
        require(ownerOf(_tokenId) == msg.sender, "Hey, your wallet doesn't own this banana!");
        require(sha256(bytes(_name)) != sha256(bytes(bananaNames[_tokenId])), "New name is same as the current one");
        bananaNames[_tokenId] = _name;
        
        emit bananaNameChange(msg.sender, _tokenId, _name);
        
    }
    
    function viewBananaName(uint _tokenId) public view returns( string memory ){
        require( _tokenId < totalSupply(), "Choose a banana within range" );
        return bananaNames[_tokenId];
    }
    
    
    // GET ALL BANANAS OF A WALLET AS AN ARRAY OF STRINGS. WOULD BE BETTER MAYBE IF IT RETURNED A STRUCT WITH ID-NAME MATCH
    function bananaNamesOfOwner(address _owner) external view returns(string[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new string[](0);
        } else {
            string[] memory result = new string[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = bananaNames[ tokenOfOwnerByIndex(_owner, index) ] ;
            }
            return result;
        }
    }
    
}