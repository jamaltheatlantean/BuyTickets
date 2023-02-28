// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error Ticket__AlreadyBought();

/**
 * This contract creates new tickets for users
 */
contract NftTicketGeneratorV2 is ERC721 {
    event TicketBought(address indexed buyer, uint timestamp);
    event TicketMinted(address indexed buyer, uint timestamp);
    event BuyerRefunded(address indexed buyer, uint indexed refundBal, uint timestamp);
    event Instlmnt(address indexed buyer, uint indexed amount, uint timestamp);

    address public ticketSeller; // ticket seller

    uint public constant TICKET_PRICE = 10 * 1e4; // ticket amount
    uint public minAmountToPay = 10 * 1e2;

    uint public constant MAX_NUM_OF_TICKETS = 100; // only 100 tickets can be minted
    uint public numOfTicketsMinted = 0;
    uint private tokenCounter;

    mapping(address => bool) public buyer;
    mapping(address => bool) public hasPaid;
    mapping(address => uint) public amountPaid;
    mapping(address => bool) public hasBoughtTicket;

    modifier onlyTicketSeller() {
        require(msg.sender == ticketSeller, "error: not ticketSeller");
        _;
    }

    constructor() ERC721("TicketToken", "TKN") {
        ticketSeller = msg.sender;
    }

    // use function to buy ticket installmentally
    function buyTicket(uint amount) external payable {
        require(
            amount >= minAmountToPay,
            "error: not enough to pay for ticket"
        );
        require(
            hasBoughtTicket[msg.sender] != true,
            "error: one ticket per wallet"
        );
        buyer[msg.sender] = true;
        hasPaid[msg.sender] = true;
        amountPaid[msg.sender] += msg.value;
        if (
            amountPaid[msg.sender] >= TICKET_PRICE &&
            numOfTicketsMinted <= MAX_NUM_OF_TICKETS
        ) {
            tokenCounter += 1;
            numOfTicketsMinted += 1;
            hasBoughtTicket[msg.sender] = true;
            _safeMint(msg.sender, tokenCounter);
            // emit event
            TicketBought(msg.sender, block.timestamp);
        }
        // emit event
        emit Instlmnt(msg.sender, amount, block.timestamp);
    }

    // use function to buy ticket once
    function buyTicketAtOnce(uint amount) external payable {
        require(amount >= TICKET_PRICE, "error: not enough to pay at once");
        require(
            hasBoughtTicket[msg.sender] != true,
            "error: one ticket per wallet"
        );
        hasPaid[msg.sender] = true;
        hasBoughtTicket[msg.sender] = true;
        tokenCounter += 1;
        numOfTicketsMinted += 1;
        _safeMint(msg.sender, tokenCounter);
    }

    // use function to get a refund for installmental payers
    function refund() external payable {
        uint refundBal = amountPaid[msg.sender];
        amountPaid[msg.sender] = 0;
        if(hasBoughtTicket[msg.sender] != true) {
            payable(msg.sender).transfer(refundBal);
        } else {
            revert Ticket__AlreadyBought();
        }

        //emit event
        emit BuyerRefunded(msg.sender, refundBal, block.timestamp);
    }

    // use function to withdraw ticket fees
    function withdraw() external onlyTicketSeller {
        payable(ticketSeller).transfer(address(this).balance);
    }

}