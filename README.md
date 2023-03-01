Creating Tomiwas ticket app. Breakdown of all the .sol contracts coming up

## Important things to note
-   This is a demo contract
-   Contract has no reentrancy guard and can be subjected to a hacki
-   This contrtact implements the functions of an NFT according to Openzepplelins' ERC721 standard.

## The Evolution of all .sol contracts
    The aim of creating this software was to create an apllication that lets users pay installmentally for the tickets to their favorite shows. The contract helps users save the money for these tickets inside the contract and away from their reach so they don't spend their ticket money.
    Gradually, more function ideas came across my mind and i implemented them into the contracts.

##  The IERC721.sol
    This contract is an interface of the `ERC721` `transferFrom` and `safeTransferFrom` function. I used this while creating the first contract.
    
## The Tickets.sol
    AKA v0, was my first attempt at bringing this project to life. 
    It required that the address of friends be fed into the contract at deployment.
    This wasn't very practical for me, as i thought about other friends wanting to join and save up for the tickets as well.
    My first fix for this was to create an add friend function so more friends could be added to the array of `address payable [] public friends`, but i came up with other reasons why the contract wouldnt be practical enough. 
    "Why would the seller grant access to the contract to sell tickets?"
    This v0 contract required the tickets to be loaded into the ncontract for sale. It was simply impractical, unless the deployer of the contract was the ticket seller and knew the address of the friends who wanted to purchase the tickets.
    I could make the process of adding the address of friends easy by implementing an addFriend() function, but a better came to me.
    
    **STATUS: Failed.
    I declared this a failed contract because it required so much work to be done by the ticket seller before it was ready. 

## The TicketToken.sol
    This contract is an ERC721. I built it to serve as the tickets to be loaded into the `Tickets.sol` contract. 
    I minted 3 of them and loaded them into the `Tickets.sol` contract and minted them to address of friends during testing on Remix.

    **STATUS: Success.

## The NftGenerator.sol
    Due to the impracticality of the Tickets.sol contract, i created a new type of logic with this NftGenerator. 
    The aim of this contract was to smoothen the process of buyers and the ticketr seller.
    The contract doesn't need any NFT loaded into it, as it mints new ERC721's (TKN) everytime a buyer sucessfully buys a ticket. 
    This solved all the impractical issues of the first `Tickets.sol` contract.
    By having the contract mint its own ticket and transfer them to the buyer there was no need to load the tickets into the contract, and still grant the contract access to use the `safeTransferFrom` or `transferFrom` function (which costs gas) and also load the address of the friends as well.
    Now any one can buy the tickets and become a buyer.
    When a buy is sucessful the contract mints a new ticket and transfers it to the `msg.sender` or `buyer`. With this new logic all the seller has to do is deploy the contract, sit back and wait for buyers to 



 