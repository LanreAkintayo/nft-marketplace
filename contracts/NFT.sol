//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private tokensId;
    address marketplaceAddress;

    constructor(address _marketplaceAddress) ERC721("LAR Tokens", "LT") {
        marketplaceAddress = _marketplaceAddress;
    }

    function createToken(string memory _tokenURI) public returns(uint){
     tokensId.increment();

     uint newItemId = tokensId.current();

     _mint(msg.sender, newItemId);
     _setTokenURI(newItemId, _tokenURI);
     setApprovalForAll(marketplaceAddress, true);

     return newItemId;

    }
}
