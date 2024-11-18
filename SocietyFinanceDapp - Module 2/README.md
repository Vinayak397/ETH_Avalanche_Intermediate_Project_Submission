# Society Management DApp

The **Society Management DApp** is a decentralized application built on the Ethereum blockchain that helps a housing society manage its members and their payments efficiently. This DApp allows the manager to add new members, track member details, and collect dues securely using smart contracts. Members can connect their MetaMask wallets to interact with the DApp for making payments and checking their dues.

## Features

- **Manager Role**: Only the manager (contract deployer) can add new members.
- **Member Registration**: The manager can register new members by providing their address, name, and flat number.
- **Payments**: Registered members can pay their dues using Ether.
- **Member Details**: Members can check their payment status and other details.
- **Society Balance**: The manager can view the total balance of the society's funds.

## Tech Stack

- **Frontend**: React.js
- **Backend**: Solidity (Smart Contract)
- **Blockchain Interaction**: Ethers.js
- **Wallet**: MetaMask

## Smart Contract

### Contract: `SocietyManagement.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocietyManagement {
    // Structure to store member information
    struct Member {
        string name;
        uint256 flatNumber;
        uint256 duesPaid;
        bool isMember;
    }

    mapping(address => Member) public members;
    address public manager;
    uint256 public societyBalance;

    // Constructor sets the contract deployer as the manager
    constructor() {
        manager = msg.sender;
    }

    // Modifier to restrict access to the manager
    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can perform this action");
        _;
    }

    // Function to add a new member (only by the manager)
    function addMember(address _memberAddress, string memory _name, uint256 _flatNumber) public onlyManager {
        require(!members[_memberAddress].isMember, "Member already exists");
        members[_memberAddress] = Member(_name, _flatNumber, 0, true);
    }

    // Function for members to make a payment
    function makePayment() public payable {
        require(members[msg.sender].isMember, "You are not a registered member");
        require(msg.value > 0, "Payment amount must be greater than zero");
        members[msg.sender].duesPaid += msg.value;
        societyBalance += msg.value;
    }

    // Function to get details of a member
    function getMemberDetails(address _memberAddress) public view returns (string memory, uint256, uint256) {
        require(members[_memberAddress].isMember, "No such member found");
        Member memory member = members[_memberAddress];
        return (member.name, member.flatNumber, member.duesPaid);
    }

    // Function to get the society's total balance (only for the manager)
    function getSocietyBalance() public view onlyManager returns (uint256) {
        return societyBalance;
    }
}
```

## Frontend

The frontend is built using **React** and **Ethers.js** to interact with the Ethereum blockchain and the smart contract.

### Installation

Make sure you have **Node.js** installed, then follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/society-management-dapp.git
   cd society-management-dapp
   ```

2. Install the dependencies:
   ```bash
   npm install
   ```

3. Update the contract address in `SocietyManagementApp.js`:
   ```js
   const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
   ```

4. Run the application:
   ```bash
   npm start
   ```

### Frontend Code (React Component)
Below is an overview of the main component in `SocietyManagementApp.js`:

```jsx
import { useState, useEffect } from "react";
import { ethers } from "ethers";
import societyABI from "../artifacts/contracts/SocietyManagement.sol/SocietyManagement.json";

export default function SocietyManagementApp() {
  const [ethWallet, setEthWallet] = useState(undefined);
  const [account, setAccount] = useState(undefined);
  const [contract, setContract] = useState(undefined);
  const [balance, setBalance] = useState(undefined);
  const [memberDetails, setMemberDetails] = useState({});
  const [newMemberName, setNewMemberName] = useState("");
  const [newMemberFlat, setNewMemberFlat] = useState("");
  const [paymentAmount, setPaymentAmount] = useState("");

  const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
  const abi = societyABI.abi;

  // Connect MetaMask Wallet
  const connectAccount = async () => {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);
    }
  };

  // Get contract instance
  const getContract = () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const societyContract = new ethers.Contract(contractAddress, abi, signer);
    setContract(societyContract);
  };

  // Add a new member
  const addMember = async () => {
    if (contract) {
      const tx = await contract.addMember(account, newMemberName, parseInt(newMemberFlat));
      await tx.wait();
      alert("Member added successfully!");
    }
  };

  // Make a payment
  const makePayment = async () => {
    if (contract) {
      const tx = await contract.makePayment({ value: ethers.utils.parseEther(paymentAmount) });
      await tx.wait();
      alert("Payment successful!");
    }
  };

  return (
    <main>
      <h1>Society Management DApp</h1>
      <button onClick={connectAccount}>Connect Wallet</button>
      {account && (
        <div>
          <p>Account: {account}</p>
          <button onClick={addMember}>Add Member</button>
          <button onClick={makePayment}>Make Payment</button>
        </div>
      )}
    </main>
  );
}
```

## Deployment

1. **Compile** the contract using Hardhat:

   ```bash
   npx hardhat compile
   ```

2. **Deploy** the contract:

   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

3. Copy the deployed contract address and update it in the frontend code.

## Usage

1. Connect your MetaMask wallet.
2. Use the manager account to register members.
3. Members can make payments using Ether.
4. The manager can check the total balance of the society.
