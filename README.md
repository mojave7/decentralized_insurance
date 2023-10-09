# Assurance Smart Contract

Assurance is a decentralized insurance platform implemented as an Ethereum smart contract. It allows users to create and subscribe to events with associated insurance, enabling the issuance of Event NFTs and handling refunds. This README provides an overview of the Assurance smart contract and its functionalities.

## Table of Contents

- [Smart Contract Overview](#smart-contract-overview)
- [Key Features](#key-features)
- [Usage](#usage)
- [Token URI](#token-uri)
- [Owner Functions](#owner-functions)
- [License](#license)

## Smart Contract Overview

- **Name:** Event NFTS
- **Symbol:** ENFT

Assurance is implemented as an Ethereum smart contract using the Solidity programming language. It inherits several contracts from the OpenZeppelin library, including ERC721, Ownable, Pausable, and more, to provide robust functionality.

## Key Features

1. **Event Creation**: Owners can create events by specifying the maximum number of subscribers, a time limit, insurance price, event price, and an optional link.

2. **Event Subscription**: Users can subscribe to events by paying the insurance price, creating an Event NFT, and being added to the list of subscribers.

3. **Event Refunds**: In certain conditions, subscribers can request refunds for their event subscriptions. Owners can approve or reject these refund requests.

4. **TokenURI**: Each Event NFT has a customizable metadata URI that contains details about the associated event, insurance, and subscription.

5. **Pausing and Unpausing**: The contract owner can pause and unpause contract operations.

6. **Withdraw and Add Liquidity**: The owner can withdraw funds from the contract, withdraw specific amounts, and add liquidity to the contract.

## Usage

1. **Create an Event**:
   - Call the `creatEvent` function with the required parameters to create a new event.

2. **Subscribe to an Event**:
   - Call the `subscribe` function with the event ID to subscribe to an event by paying the insurance price.

3. **Request a Refund**:
   - Subscribers can request refunds using the `claimRefund` function if the event conditions allow it.

4. **Approve Refunds**:
   - Owners can approve or reject refund requests using the `approuveRefund` function.

5. **Retrieve Event Information**:
   - Use the provided getter functions to retrieve information about events, subscribers, and Event NFTs.

## Token URI

Each Event NFT has a JSON-formatted metadata URI that provides detailed information about the associated event, insurance, and subscription. The `tokenURI` function generates this URI for each Event NFT.

## Owner Functions

Owners of the Assurance smart contract have special privileges, including pausing/unpausing the contract, withdrawing funds, and adding liquidity. These functions should be used responsibly.


## License

This smart contract is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
