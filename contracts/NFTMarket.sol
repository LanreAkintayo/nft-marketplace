//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard, IERC721Receiver {
    using Counters for Counters.Counter;

    Counters.Counter private itemsId;
    Counters.Counter private itemsSold;

    address payable owner;
    uint256 public listingPrice;

    constructor(uint256 _listingPrice) {
        listingPrice = _listingPrice;
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    event ERC721Received(
        address indexed operator,
        address indexed from,
        uint256 indexed tokenId
    );

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price should be greater than 0");
        require(msg.value == listingPrice, "Price must equal listing price");
        itemsId.increment();

        uint256 itemId = itemsId.current();

        idMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
    {
        uint256 price = idMarketItem[itemId].price;
        uint256 tokenId = idMarketItem[itemId].tokenId;

        require(msg.value == price, "Amount should equal asking price");

        idMarketItem[itemId].seller.transfer(msg.value);

        IERC721(nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        MarketItem storage marketItem = idMarketItem[itemId];
        marketItem.owner = payable(msg.sender);
        marketItem.sold = true;

        itemsSold.increment();

        payable(owner).transfer(listingPrice);
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemsCount = itemsId.current();
        uint256 unsoldItemCount = itemsCount - itemsSold.current();

        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint256 i = 1; i < (itemsCount + 1); i++) {
            address payable currentOwner = idMarketItem[i].owner;
            if (currentOwner != address(0)) {
                MarketItem storage currentItem = idMarketItem[i];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 itemsCount = itemsId.current();

        uint256 totalBoughtByUser = getTotalContributionAs(
            "owner",
            msg.sender,
            itemsCount
        );

        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](totalBoughtByUser);

        for (uint256 i = 1; i < (itemsCount + 1); i++) {
            if (idMarketItem[i].owner == msg.sender) {
                MarketItem storage currentItem = idMarketItem[i];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchUserMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemsCount = itemsId.current();

        uint256 totalCreatedByUser = getTotalContributionAs(
            "seller",
            msg.sender,
            itemsCount
        );

        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](totalCreatedByUser);

        for (uint256 i = 1; i < (itemsCount + 1); i++) {
            if (idMarketItem[i].owner == msg.sender) {
                MarketItem storage currentItem = idMarketItem[i];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }



    function getTotalContributionAs(
        string memory contribution,
        address sender,
        uint256 totalItem
    ) internal view returns (uint256 totalCount) {
        totalCount = 0;

        for (uint256 i = 1; i < (totalItem + 1); i++) {
            if (isTheSame(contribution, "owner")) {
                if (idMarketItem[i].owner == sender) {
                    totalCount += 1;
                }
            } else if (isTheSame(contribution, "seller")) {
                if (idMarketItem[i].seller == sender) {
                    totalCount += 1;
                }
            }
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit ERC721Received(operator, from, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }

    function isTheSame(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        // Compare string keccak256 hashes to check equality
        if (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b))) {
            return true;
        }
        return false;
    }
}
