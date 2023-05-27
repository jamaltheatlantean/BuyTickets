// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error Ticket__AlreadyBought();

/**
 * @dev This contract creates new tickets for users
 */
contract NftTicketGeneratorV2 is ERC721 {
    /*///////////////////////  EVENTS  ///////////////////////////*/
    event OwnershipTransferred(
        address indexed newTicketSeller,
        uint indexed timestamp
    );
    event TicketDetailsSaved(uint indexed timestamp);
    event InstallmentPaid(
        address indexed buyer,
        uint indexed amount,
        uint indexed timestamp
    );
    event BuyerRefunded(
        address indexed buyer,
        uint indexed refundBal,
        uint indexed timestamp
    );
    event TicketMinted(address indexed buyer, uint timestamp);
    event TicketTransfered(
        address indexed buyer,
        address indexed to,
        uint indexed timestamp
    );
    event FeesRetrieved(uint indexed amount);

    address public ticketSeller; // ticket seller

    uint public installmentPrice; // Installment price varies from ticket price
    uint public ticketPrice; // Ticket Price
    uint public minAmountToPay; // Variable holds minimum amount to pay per ticket

    uint public maxNumOfTickets;
    uint public numOfTicketsMinted = 0;
    uint public tokenId;

    mapping(address => bool) public ticketBuyer;
    mapping(address => bool) public hasPaidInstallment;
    mapping(address => uint) public amountPaid;
    mapping(address => bool) public hasBoughtTicket;

    /*////////////////////  MODIFIERS  /////////////////////*/
    modifier onlyTicketSeller() {
        require(msg.sender == ticketSeller, "error: not ticketSeller");
        _;
    }

    modifier onlyTicketOwner() {
        require(
            ownerOf(tokenId) == msg.sender,
            "error: failed to fetch ticket"
        );
        _;
    }

    constructor() ERC721("TicketToken", "TKN") {
        ticketSeller = msg.sender;
    }