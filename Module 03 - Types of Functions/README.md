# Module Types of Functions - ETH + AVAX - Metacrafters 

**Cust_ERC20** is a simple custom ERC20 token smart contract built using Solidity. It allows users to mint, burn, and transfer tokens, including an enhanced transfer function with validation.

## Overview

This contract leverages the OpenZeppelin ERC20 implementation and includes the following functionalities:
- Minting new tokens
- Burning tokens
- Custom transfer with an additional check to prevent transfers to the zero address

## Requirements

- **Remix IDE**: Use the [Remix](https://remix.ethereum.org/) online Solidity editor.
- **OpenZeppelin Library**: No additional setup required in Remix; it automatically fetches imported OpenZeppelin contracts.

## 📋 Contract Explanation

The `Cust_ERC20` contract extends the standard OpenZeppelin ERC20 token contract. Below is a breakdown of its components:

1. **Contract Inheritance**:
   - The contract imports the `ERC20` implementation from OpenZeppelin, which provides the core functionality of an ERC20 token.
   - By inheriting `ERC20`, this contract automatically gains access to standard functions like `transfer`, `balanceOf`, `approve`, and `transferFrom`.

2. **Constructor**:
   ```solidity
   constructor(string memory name, string memory symbol) ERC20(name, symbol) {}
   ```
   - When deploying the contract, the constructor requires two inputs: `name` (the token's name) and `symbol` (the token's symbol).
   - The contract will initialize the token with these values.

3. **Minting Function**:
   ```solidity
   function mint(uint256 amount) public {
       _mint(msg.sender,
   
## How to Deploy and Interact Using Remix

### Step 1: Open Remix IDE
- Visit [Remix](https://remix.ethereum.org/).

### Step 2: Create a New File
- Create a new file named `Cust_ERC20.sol` and paste the following code:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Cust_ERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function customTransfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to the zero address is not allowed");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _transfer(msg.sender, to, amount);
        return true;
    }
}
```

### Step 3: Compile the Contract
- In Remix, navigate to the **Solidity Compiler** tab.
- Set the compiler version to `0.8.26`.
- Click **Compile Cust_ERC20.sol**.

### Step 4: Deploy the Contract
- Switch to the **Deploy & Run Transactions** tab.
- Ensure the **Environment** is set to "Injected Provider" (for MetaMask) or "Remix VM" (for local testing).
- Enter the following parameters:
  - `name`: The token's name (e.g., `"MyToken"`).
  - `symbol`: The token's symbol (e.g., `"MTK"`).
- Click **Deploy**.

### Step 5: Interact with the Contract

1. **Mint Tokens**
   - Use the `mint` function to create new tokens.
   - Enter the amount (e.g., `1000`) and click **Transact**.
   - Tokens will be minted to your wallet address.

2. **Burn Tokens**
   - Use the `burn` function to destroy tokens.
   - Enter the amount (e.g., `500`) and click **Transact**.

3. **Transfer Tokens**
   - Use the `customTransfer` function to send tokens to another address.
   - Enter the recipient's address and the amount.
   - Ensure the recipient address is not the zero address, or the transaction will fail.

### Example Interaction

1. Deploy the contract with:
   - Name: `MyToken`
   - Symbol: `MTK`

2. Mint 1000 tokens to your address:
   - Call `mint(1000)`.

3. Transfer 500 tokens to another address:
   - Call `customTransfer("0xRecipientAddress", 500)`.

4. Burn 200 tokens from your balance:
   - Call `burn(200)`.
