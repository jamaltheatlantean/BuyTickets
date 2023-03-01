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
    
    **STATUS: Failed.

## The TicketToken.sol



 