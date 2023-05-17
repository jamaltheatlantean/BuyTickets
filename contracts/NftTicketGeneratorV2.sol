// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error Ticket__AlreadyBought();

/**
 * This contract creates new tickets for users
 */
contract NftTicketGeneratorV2 is ERC721 {
    event TicketMinted(address indexed buyer, uint timestamp);
    event BuyerRefunded(address indexed buyer, uint indexed refundBal, uint indexed timestamp);
    event Instlmnt(address indexed buyer, uint indexed amount, uint indexed timestamp);
    event TicketTransfered(address indexed owner, address indexed to, uint indexed timestamp);
    event FeesRetrieved(uint indexed amount);

    address public ticketSeller; // ticket seller

    uint public ticketPrice; // ticket amount
    uint public minAmountToPay = 10 * 1e2;

    uint public constant MAX_NUM_OF_TICKETS = 100; // only 100 tickets can be minted
    uint public numOfTicketsMinted = 0;
    uint public tokenId;

    mapping(address => bool) public buyer;
    mapping(address => bool) public hasPaid;
    mapping(address => uint) public amountPaid;
    mapping(address => bool) public hasBoughtTicket;

    modifier onlyTicketSeller() {
        require(msg.sender == ticketSeller, "error: not ticketSeller");
        _;
    }
    
    modifier onlyTicketOwner() {
        require(ownerOf(tokenId) == msg.sender, "error: failed to fetch ticket");
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
            amountPaid[msg.sender] >= ticketPrice &&
            numOfTicketsMinted <= MAX_NUM_OF_TICKETS
        ) {
            numOfTicketsMinted += 1;
            hasBoughtTicket[msg.sender] = true;
            _safeMint(msg.sender, tokenId);
            // add to token counter after successful mint
            tokenId++;
            // emit event
            emit TicketMinted(msg.sender, block.timestamp);
        }
        // emit event
        emit Instlmnt(msg.sender, amount, block.timestamp);
    }

    // use function to buy ticket once
    function buyTicketAtOnce(uint amount) external payable {
        require(amount >= ticketPrice, "error: not enough to pay at once");
        require(
            hasBoughtTicket[msg.sender] != true,
            "error: one ticket per wallet"
        );
        require(MAX_NUM_OF_TICKETS <= 100, "error: tickets sold out!");
        hasPaid[msg.sender] = true;
        hasBoughtTicket[msg.sender] = true;
        numOfTicketsMinted += 1;
        _safeMint(msg.sender, tokenId);
        // add to token counter after successful mint
        tokenId++;
        emit TicketMinted(msg.sender, block.timestamp);
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
        // emit event
        emit FeesRetrieved(address(this).balance);
    }

    function setTicketPrices(uint _ticketPrice, uint _minAmountToPay) external onlyTicketSeller {
        require(_ticketPrice != 0, "error: price cannot be 0");
        require(_minAmountToPay != 0, "error: price cannot be 0");
        ticketPrice = _ticketPrice;
        minAmountToPay = _minAmountToPay;
    }

    function transferTicket(address to, uint _tokenId) external onlyTicketOwner {
        tokenId = _tokenId;
        safeTransferFrom(msg.sender, to, tokenId);
        // emit event
        emit TicketTransfered(msg.sender, to, block.timestamp);
    }

}