// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.8 <0.9.0;

 import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * This contract creates new tickets for users
 */

contract NftTicketGenerator is ERC721 {
    event TicketBought(address indexed buyer, uint timestamp);
    event TicketMinted(address indexed buyer, uint timestamp);

    address public ticketSeller; // ticket seller
    address public buyers; // address of buyers

    uint public constant TICKET_PRICE = 10 * 1e4; // ticket amount
    uint public minAmountToPay = 10 * 1e2;

    uint public constant MAX_NUM_OF_TICKETS = 100; // only 100 tickets can be minted
    uint public numOfTicketsMinted = 0;
    uint private tokenCounter;

    mapping(address => bool) public buyer;
    mapping(address => bool) public hasPaid;
    mapping(address => uint) public amountPaid;
    mapping(address => bool) public hasBoughtTicket;

    constructor() ERC721("TicketToken", "TKN") {
        ticketSeller = msg.sender;
    }

    function buyTicket(uint amount) external payable {
        require(amount >= minAmountToPay, "error: not enough to pay for ticket");
        require(hasBoughtTicket[msg.sender] != true, "error: one ticket per wallet");
        hasPaid[msg.sender] = true;
        amountPaid[msg.sender] += msg.value;
        if(amountPaid[msg.sender] >= TICKET_PRICE && numOfTicketsMinted <= MAX_NUM_OF_TICKETS) {
            _safeMint(msg.sender, tokenCounter);
            tokenCounter += 1;
            numOfTicketsMinted += 1;
            hasBoughtTicket[msg.sender] = true;
            uint ticketFullyPaid = amountPaid[msg.sender];
            payable(ticketSeller).transfer(ticketFullyPaid);
        }
    }

    function buyTicketAtOnce() external payable {

    }

}
