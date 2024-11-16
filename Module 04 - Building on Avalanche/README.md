# Mickel (MKL) Token & Game Clone Contract - Metacrafters Project

## Overview
This project is a Solidity smart contract called **GameClone** that simulates an in-game economy using ERC-20 tokens. The token is named **Mickel** (symbol: **MKL**) and is used to mint, burn, transfer, and redeem items in an in-game store. The contract is implemented using OpenZeppelin's ERC20 library.

The contract allows:
- The **owner** to mint tokens.
- **Users** to burn tokens and purchase items from the game store.
- Redeemed items are tracked per user to prevent multiple redemptions of the same item.

## Contract Details
- **Contract Name**: GameClone
- **Token Name**: Mickel
- **Token Symbol**: MKL
- **Compiler Version**: Solidity `0.8.26`
- **License**: MIT
- **Deployed Network**: Tested using **Remix** on the Ethereum test network.
- **Contract Address**: [0x2ed62ac1ab3ab6ebc18357cb041086a5b74814260c4b998108161b4784e0998a](https://etherscan.io/address/0x2ed62ac1ab3ab6ebc18357cb041086a5b74814260c4b998108161b4784e0998a) (for contract creation)

## Features
1. **Token Management**:
   - The contract allows the owner to mint new Mickel tokens.
   - Users can burn tokens to reduce their balance.

2. **In-Game Store**:
   - The store offers items that can be purchased using Mickel tokens.
   - Items available include vouchers, jackets, and server access.
   - Each item has a unique ID, name, and price (in Mickel tokens).

3. **Redeem Functionality**:
   - Users can redeem items by burning the corresponding amount of tokens.
   - Each user’s redeemed items are tracked to prevent multiple redemptions of the same item.
   - An event is emitted upon successful redemption.

## Smart Contract Code

The contract code is structured as follows:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Degen Gaming
 * @dev A token-based game contract that allows users to mint, burn, transfer tokens, and redeem items.
 */
contract GameClone is ERC20 {
    address public owner;

    // Store item names and prices
    mapping(uint256 => string) public itemName;
    mapping(uint256 => uint256) public itemPrice;

    // Track redeemed items for each user
    mapping(address => mapping(uint256 => bool)) public redeemedItems;
    mapping(address => uint256) public redeemedItemCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() ERC20("Mickel", "MKL") {
        owner = msg.sender;
        defaultItemCreate();
    }

    event Redeem(address indexed user, string itemName);

    function defaultItemCreate() public {
        GameStoreManage(0, "10 Mickel", 500);
        GameStoreManage(1, "Air Mac Voucher", 10000);
        GameStoreManage(2, "Diamond Jacket", 20000);
        GameStoreManage(3, "Classified Servers", 25000);
    }

    function GameStoreManage(uint256 itemId, string memory _itemName, uint256 _itemPrice) internal {
        itemName[itemId] = _itemName;
        itemPrice[itemId] = _itemPrice;
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function redeemItem(uint256 itemId) public returns (string memory) {
        uint256 redemptionAmount = itemPrice[itemId];
        require(balanceOf(msg.sender) >= redemptionAmount, "Not Enough Tokens To Redeem This Item");

        _burn(msg.sender, redemptionAmount);
        redeemedItems[msg.sender][itemId] = true;
        redeemedItemCount[msg.sender]++;
        emit Redeem(msg.sender, itemName[itemId]);

        return itemName[itemId];
    }

    function getRedeemedItemCount(address user) public view returns (uint256) {
        return redeemedItemCount[user];
    }
}
```

## How to Deploy & Interact

### Prerequisites
Ensure you have:
- [Remix IDE](https://remix.ethereum.org/)
- A MetaMask wallet connected to the Ethereum test network (e.g., Goerli)
- Test Ether for deploying and interacting with the contract

### Deployment Steps
1. **Open Remix** and create a new file named `GameClone.sol`.
2. Copy and paste the contract code above.
3. Go to the **Solidity Compiler** tab and select compiler version `0.8.26`.
4. Compile the contract. Ensure there are no errors.
5. Navigate to the **Deploy & Run Transactions** tab.
6. Select the `Injected Provider - MetaMask` environment.
7. Click **Deploy** and confirm the transaction in MetaMask.

### Interacting with the Contract
Once deployed, you can interact with the contract using Remix:

1. **Mint Tokens**: 
   - Use the `mint` function (only the owner can call this).

2. **Burn Tokens**:
   - Users can burn their Mickel tokens by specifying the amount.

3. **Transfer Tokens**:
   - Transfer Mickel tokens to another address using the `transfer` function.

4. **Redeem Items**:
   - Users can redeem items by calling `redeemItem` with the item's ID.

5. **View Redeemed Items**:
   - Use `getRedeemedItemCount` to see how many items a user has redeemed.

## Events
The contract emits the following event:

- `Redeem(address indexed user, string itemName)`: Emitted when a user successfully redeems an item from the store.

## Transaction History
- **Contract Creation**: [0x2ed62ac1ab3ab6ebc18357cb041086a5b74814260c4b998108161b4784e0998a](https://etherscan.io/tx/0x2ed62ac1ab3ab6ebc18357cb041086a5b74814260c4b998108161b4784e0998a)

## License
This project is licensed under the **MIT License**.
