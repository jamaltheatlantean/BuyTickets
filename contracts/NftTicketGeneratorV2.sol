// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error Ticket__AlreadyBought();

/**
 * This contract creates new tickets for users
 */
contract NftTicketGeneratorV2 is ERC721 {
    event TicketDetailsSaved(uint indexed timestamp);
    event TicketMinted(address indexed buyer, uint timestamp);
    event BuyerRefunded(address indexed buyer, uint indexed refundBal, uint indexed timestamp);
    event Instlmnt(address indexed buyer, uint indexed amount, uint indexed timestamp);
    event TicketTransfered(address indexed owner, address indexed to, uint indexed timestamp);
    event FeesRetrieved(uint indexed amount);

    address public ticketSeller; // ticket seller

    uint public ticketPrice; // ticket amount
    uint public minAmountToPay;

    uint public maxNumOfTickets; // only 100 tickets can be minted
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

    /*////////////////////////////////////////////////////////////////////////
                            USER FACING FUNCTIONS
    ////////////////////////////////////////////////////////////////////////*/
    ///@dev function pays for tickets installmentally
    function buyTicketInInstallment(uint amount) external payable {
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
            numOfTicketsMinted <= maxNumOfTickets
        ) {
            _safeMint(msg.sender, tokenId);
            //increase number of tickets minted
            numOfTicketsMinted ++;
            // add to token counter after successful mint
            tokenId++;
            hasBoughtTicket[msg.sender] = true;
            // emit event
            emit TicketMinted(msg.sender, block.timestamp);
        }
        // emit event
        emit Instlmnt(msg.sender, amount, block.timestamp);
    }

    ///@dev use function to buy ticket once
    function buyTicketAtOnce(uint amount) external payable {
        require(amount >= ticketPrice, "error: not enough to pay at once");
        require(
            hasBoughtTicket[msg.sender] != true,
            "error: one ticket per wallet"
        );
        require(maxNumOfTickets <= 100, "error: tickets sold out!");
        _safeMint(msg.sender, tokenId);
        hasPaid[msg.sender] = true;
        hasBoughtTicket[msg.sender] = true;
        // increase number of tickets minted
        numOfTicketsMinted ++;
        // add to token counter after successful mint
        tokenId++;
        emit TicketMinted(msg.sender, block.timestamp);
    }

    ///@notice use function to call refund for installmental payers
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

    ///@dev use function to withdraw ticket fees from contract
    function withdraw() external onlyTicketSeller {
        payable(ticketSeller).transfer(address(this).balance);
        // emit event
        emit FeesRetrieved(address(this).balance);
    }

    ///@dev use function to assign value to variables
    function setTicketPriceMinAmountToPayMaxNumOfTickets(
        uint _ticketPrice, 
        uint _minAmountToPay,
        uint _maxNumOfTickets) 
    external onlyTicketSeller {
        require(_ticketPrice != 0, "error: price cannot be 0");
        require(_minAmountToPay != 0, "error: price cannot be 0");
        require(_maxNumOfTickets != 0, "error: 0 tickets");
        ticketPrice = _ticketPrice;
        minAmountToPay = _minAmountToPay;
        maxNumOfTickets = _maxNumOfTickets;
        // emit event
        emit TicketDetailsSaved(block.timestamp);
    }

    ///@dev function uses onlyTicketOwner modifier to verify that caller is owner
    function transferTicket(address to, uint _tokenId) external onlyTicketOwner {
        tokenId = _tokenId;
        safeTransferFrom(msg.sender, to, tokenId);
        // emit event
        emit TicketTransfered(msg.sender, to, block.timestamp);
    }

    function transferOwnership(address _newTicketSeller) internal payable {
        require(_newTicketSeller != address(0), "error: invalid address");
        ticketSeller = payable(_newTicketSeller);
    }

    /*//////////////////////////////////////////////////////////////////
                            GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////////*/
    function getTicketPrice() public view returns (uint, uint, uint) {
        return(minAmountToPay, ticketPrice, maxNumOfTickets);
    }

    function getTicketSeller() public view returns (address) {
        return ticketSeller;
    }

}