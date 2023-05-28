// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error Ticket__AlreadyBought();

/**
 * @dev This contract creates new tickets for users
 */
contract NftTicketGeneratorV4 is ERC721 {
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

    uint public ticketPrice; // Ticket Price
    uint public minAmountToPay; // Variable holds minimum amount to pay per ticket

    uint public maxNumOfTickets; // to be set by ticket seller after deployment
    uint public numOfTicketsMinted = 0;
    uint public tokenId;

    mapping(address => bool) public hasBoughtAtOnce;
    mapping(address => bool) public hasPaidInstallment;
    mapping(address => uint) public amountPaid;
    mapping(address => bool) public hasBoughtTicket;

    /*////////////////////////////////////////////////////////
                            MODIFIERS
    ///////////////////////////////////////////////////////*/
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
    /*////////////////////////////////////////////////////////
                        CONSTRUCTOR
    ////////////////////////////////////////////////////////*/
    constructor() ERC721("TicketToken", "TKN") {
        ticketSeller = msg.sender;
    }

    /*////////////////////////////////////////////////////////////////////////
                            USER FACING FUNCTIONS
    ////////////////////////////////////////////////////////////////////////*/
    ///@notice function assigns new owner to contract
    function transferOwnership(address _newTicketSeller)
        public
        onlyTicketSeller
    {
        require(_newTicketSeller != address(0), "error: invalid address");
        ticketSeller = payable(_newTicketSeller);
        // emit event
        emit OwnershipTransferred(_newTicketSeller, block.timestamp);
    }

    ///@dev use function to assign value to variables
    function setTicketPriceMinAmountToPayMaxNumOfTickets(
        uint _installmentPrice
        uint _ticketPrice,
        uint _minAmountToPay,
        uint _maxNumOfTickets
    ) public onlyTicketSeller {
        require(_installmentPrice != 0, "error: price cannot be 0");
        require(_ticketPrice != 0, "error: price cannot be 0");
        require(_minAmountToPay != 0, "error: price cannot be 0");
        require(_maxNumOfTickets != 0, "error: 0 tickets");
        installmentPrice = _installmentPrice;
        ticketPrice = _ticketPrice;
        minAmountToPay = _minAmountToPay;
        maxNumOfTickets = _maxNumOfTickets;
        // emit event
        emit TicketDetailsSaved(block.timestamp);
    }

    function payInstallment(uint amount) public {
        require(amount >= minAmountToPay, "error: not enough eth");
        amountPaid[msg.sender] += amount;
        hasPaidInstallment[msg.sender] = true;
        // emit event
        emit InstallmentPaid(msg.sender, amount, block.timestamp);
    }

    function buyTicket(uint amount) public {
        require(amount >= ticketPrice, "error: not enough eth");
        amountPaid[msg.sender] += amount;
        hasBoughtAtOnce[msg.sender] = true;
    }

    function claimTicket() public {
        require(amountPaid[msg.sender] >= ticketPrice, 
        "error: user not eligible to mint"
        );
        require(!hasBoughtTicket[msg.sender], "error: one ticket per address");
        _safeMint(msg.sender, tokenId);
        tokenId ++;
        numOfTicketsMinted ++;
        hasBoughtTicket[msg.sender] = true;
        // emit event
        emit TicketMinted(msg.sender, block.timestamp);
    }

    ///@notice use function to call refund for installmental payers
    function refund() external {
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

    function withdraw() external onlyTicketSeller {
        
    }
}
