// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.8 <0.9.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * This contract creates new tickets for users
 */

contract NftTicketGenerator {
    event TicketBought(address indexed buyer, uint timestamp);
    event TicketMinted(address indexed buyer, uint timestamp);

    address payable public ticketSeller; // ticket seller
    address public buyers; // address of buyers

    uint public constant TICKET_PRICE = 10 * 1e2; // ticket amount


}