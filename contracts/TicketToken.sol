// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * contract creates the NFT ticket for use.
 */

contract TicketToken is ERC721 {
    uint256 private s_tokenCounter;

    constructor() ERC721("TicketToken", "TKN") {
        s_tokenCounter = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}