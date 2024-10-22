### PERSONAL NOTES

## Important things to note
-   This is a demo contract.
-   Contract has no reentrancy guard and can be subjected to a hack. To use reentrancy guard however [see here](https://docs.openzeppelin.com/contracts/4.x/api/security)
-   This contract implements the functions of an NFT according to Openzepplelins' ERC721 standard.
-   This contract is experimental and should not be used in production. For use, contact me at [twitter](https://twitter.com/thatatlantean).

## The Evolution of all .sol contracts
The aim of creating this software was to create an apllication that lets users pay in installment for the tickets to their favorite shows/concerts/movies etc, anything that would require the purchase of a ticket

Note: The ticket would have to be an NFT.

The contract helps users save the money for these tickets inside the contract and away from their reach so they don't spend their ticket money.
Gradually, more function ideas came across my mind and i implemented them into the contracts.

##  The IERC721.sol
This contract is an interface of the `ERC721` `transferFrom` and `safeTransferFrom` function. I used this while creating the first contract.
    
## The Tickets.sol
AKA v0, was my first attempt at bringing this project to life. 
It required that the address of friends be fed into the contract at deployment.
This wasn't very practical for me, as i thought about other friends wanting to join and save up for the tickets as well.
My first fix for this was to create an add friend function so more friends could be added to the array of `address payable [] public friends`, but i came up with other reasons why the contract wouldnt be practical enough. 
    "Why would the seller grant access to the contract to sell tickets?"
This v0 contract required the tickets to be loaded into the contract for sale. It was simply impractical, unless the deployer of the contract was the ticket seller and knew the address of the friends who wanted to purchase the tickets.
I could make the process of adding the address of friends easy by implementing an `addFriend()` function, but a better idea came to me.
    
    STATUS: Failed.
    I declared this a failed contract because it required so much work to be done by the ticket seller before it was ready. 

## The TicketToken.sol
This contract is an ERC721. I built it to serve as the tickets to be loaded into the `Tickets.sol` contract. 
I minted 3 of them and loaded them into the `Tickets.sol` contract and minted them to address of friends during testing on Remix.

    STATUS: Success.

## The NftTicketGenerator.sol
Due to the impracticality of the Tickets.sol contract, i created a new type of logic with this NftGenerator. 
The aim of this contract was to smoothen the process for buyers and the ticketr seller.
The contract doesn't need any NFT loaded into it, as it mints new ERC721's (TKN) everytime a buyer sucessfully buys a ticket. 
This solved all the impractical issues of the first `Tickets.sol` contract.
By having the contract mint its own ticket and transfer them to the buyer there was no need to load the tickets into the contract, and still grant the contract access to use the `safeTransferFrom` or `transferFrom` function (which costs gas) and also load the address of the friends as well.
Now any one can buy the tickets and become a buyer.
When a buy is sucessful the contract mints a new ticket and transfers it to the `msg.sender` or `buyer`. With this new logic all the seller has to do is deploy the contract, sit back and wait for buyers to interact with his deployed contract.

I got the logic for this contract by combining the `Tickets.sol` and the `TicketToken.sol` contracts. By borrowing the functionality of creating a new ERC721 with the logic used to buy tickets installmentally and at once in `Tickets.sol`, i implemented a `refund()` function that refunds installmental ticket purchases, should the buyer change their mind on seeing the movie or they were not able to complete the installmental payment before the date of the movie.
With this logic I created the `NftGenerator.sol`. A V1 preceeding the V0 `Tickets.sol`

    STATUS: Failed.
    While this contract was great and included all the logic needed to make it a sucess, i overdid it, which led to declaring it a failed contract in need of iteration. How?
    Well, the contract compiles fine, but there were function overloads that led to a gas estimation error when interacting with the contract.
    I purposely wanted the contract to ease the ticket seller gas wise.
    So i overloaded the function which led to it breaking down whenever a buyer tried to buy an NFT.
    The buyTicket() function not only receives ether, it also mints the ticket to the buyer and lastly sends the ether spent by the buyer to the ticket seller at once.
    This overloads the function and results to the gas estimation error.
    

## The NftTicketGeneratorV2.sol
After carrying out a few iterations on the first `NftTicketGenerator.sol` the end result was a more perfect contract. 
The `NftTicketGeneratorV2.sol` has a new `withdraw()` function that transfers the Eth paid by the buyers for the tickets to the ticketSellers address, removing the load from the `buyTicket()` function.
I tried to simplify this process in V1 of the contract but of course it didn't work.

    STATUS: Success!
    After a successful series of testing this contract on the Remix IDE, all functions responded perfectly.
    UPDATE: Failed!
    Months after, i revisted this contract for presentation in a demo, and found out that the safeMint function doesnt call from the if tag within the buyTicketInInstallment() function. With that discovery I the author of this contract pronounced it a failed attempt.

Authors remark: The NftTicketGeneratorV2.sol is the most efficient smart contract for this project.

## NftTicketGeneratorv3.sol
In an attempt to fix the damage discovered, I created a version 3. The V3 introduced two new functions and was tailored for simplicity, so that i could have the contract ready for display.
I took away the buyTicketInstallment which failed to mint a new NFT, and displayed the contract on a demo for Parallel Score.
I created two new functions;
The `mintTicket()` function which is internally called whenever a user buys a new ticket via the `buyTicket()` function.
And the `transferTicket()` function, that helps the user transfer the ticket bought to a new address.

    STATUS: Success.

Authors remark: Although the NftTicketGeneratorV3.sol was a success, it lacked the true purpose for creating the smart contract, which is to let users pay for tickets in installmental. Without this function the original point of the contract was lost.

## NftTicketGeneratorV4.sol
This was the breakthrough smart contract i needed, that would help users pay in installment, pay at once, and transfer the ticket.
To do this i recreated the function that lets users buy the ticket in installment, but this time the `safeMint()` function isn't called from within the `buyTicket()` or `payInstallment()` function, rather those functions just record the amountPaid of msg.sender (Users).
The user then calls the `claimTicket()` function, a new function i added that requires the amountPaid of msg.sender is greater than or equal to the price of a ticket. Once this require checks out fine, it mints a new ticket of the user by executing the `safeMint()` function.

    STATUS: Success!
    At last users can now call the payInstallment() function to make an installment payment, and once they've paid enough to get the ticket they call the claimTicket() function which mints a new ticket and assigns a unique ID to them.


### ABout the Project

This smart contract was created to feauture a pay by installment function that lets users pay for the price of a ticket gradually but it also supports a pay-at-once option.

### Built With

* [![Solidity][Soliditylang.org]][Solidity-url]

## Features
The contract has the following features:

-   Supports installment as a mode of payment. 
-   Mints new tickets in the form of an ERC721.
-   Users get a refund on incomplete payments.
-   Users can transfer ticket ownership from within the contract.

## Events
This contract makes use of the following events:

-   `event OwnershipTransferred(address indexed _newTicketSeller, uint indexed timestamp)`: emitted when ownership has been transfered to a new account.
-   `event TicketDetailsSaved(uint indexed timestamp)`: emitted when variables have been asigned value.
-   `event TicketMinted(address indexed buyer, uint timestamp)`: Emitted whenever a ticket has been completely purchased.
-   `event BuyerRefunded(address indexed buyer, uint indexed refundBal, uint timestamp)`: Emitted when a user gets a refund.
-   `event Instlmnt(address indexed buyer, uint indexed amount, uint timestamp)`: Emitted when a user pays only installment.
-   `event TicketTransfered(address indexed buyer, address indexed to, uint indexed timestamp)`: emitted when a user transfers his ticket. 
-   `event FeesRetrieved(uint indexed amount)`: Emitted when the ticket seller withdraws the balance from the contract.

## Modifier
The contract has only one modifier to limit access control:
Update: Contract has two modifiers now.

-   `onlyTicketSeller`: Limits access to only owner of contract.
-   `onlyTicketOwner`: Limits access to only owner of ticket.

## Getters
Getters aren't created yet.
Update: Getters have been created.

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This contract is licensed under the MIT License.

## Contact

Jamaltheatlantean [Gabriel Isobara]                               
Connect with me on [@twitter](https://twitter.com/ThatAtlantean)                                                         

Or send me an email to - jamaltheatlantean@gmail.com

