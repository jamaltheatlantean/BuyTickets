// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
// 0x0A1ca5333e7d2Fac1cD1d81D89BC3797c0d83dd7 friend address
// contract address: 


import "./IERC721.sol";

/**
* This contract is a demo sample for Tomiwa's project
* It uses ERC721 to represent the tickets.
* So yeah, the cinema is so progressive they use ERCs for tickets.
*/
contract Tickets {
    event TicketSold(address indexed friend, uint indexed nftId, uint timestamp);
    event ReceivedGift(address indexed sender, uint timestamp);

    address payable [] public friends; // address array of friends
    address public ticketSeller;

    uint public constant MinimumAmount = 10 * 1e2; // minimum amount a friend can contribute
    uint public constant MaxAmount = 10 * 1e2; // real price of ticket for one time payment

    IERC721 public nft; // interface of NFT
    uint public nftId; // nftId

    mapping(address => bool) public hasPaid; // tracks who has made payment 
    mapping(address => uint) public installmentAmt; // tracks amount paid installmentally

    /** constructor requires address of friends
    *   address of the ticket seller who owns the nft
    *   address of the nft
    *   and lastly the Id of the nft
    */
    constructor(address payable [] memory _friends, address _nft, uint _nftId, address _ticketSeller) {
        for (uint i; i < _friends.length; i++) {
            address friend = _friends[i];
            require(friend != address(0), "error: invalid address");
        }
        friends = _friends;
        nft = IERC721(_nft);
        nftId = _nftId;
        ticketSeller = _ticketSeller;
    }

    receive() external payable {
        // emit event
        emit ReceivedGift(msg.sender, block.timestamp);
    }

    // Use function to make installmental payment
    function payInstlmntl(uint amount) public payable {
        require(amount >= MinimumAmount, "error: more eth -_-");
        hasPaid[msg.sender] = true;
        installmentAmt[msg.sender] += msg.value;
        if(installmentAmt[msg.sender] >= MaxAmount) {
            // transfer ticket to friend
            nft.safeTransferFrom(ticketSeller, msg.sender, nftId);
            // transfer eth to ticket seller
            payable(ticketSeller).transfer(amount);
        }
    }

    // Use function for one time payment
    function PayInFull(uint amount) public payable {
        require(amount >= MaxAmount, "error: not enough ether -_-");
        hasPaid[msg.sender] = true;
        // transfer eth to friend
        nft.safeTransferFrom(ticketSeller, msg.sender, nftId);
        payable(ticketSeller).transfer(amount);
        // emit event
        emit TicketSold(msg.sender, nftId, block.timestamp);
    }
 
}