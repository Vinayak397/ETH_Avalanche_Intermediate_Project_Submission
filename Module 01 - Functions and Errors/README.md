# PeerToPeerLending Smart Contract - Functions and Errors Module 

## 🔍 Overview

The `PeerToPeerLending` contract enables decentralized peer-to-peer lending directly on the Ethereum blockchain. Here are the key features:

- **Create Loan**: Lenders can create loan offers with specific amounts, interest rates, and durations.
- **Accept Loan**: Borrowers can accept available loan offers by transferring the exact amount required.
- **Repay Loan**: Borrowers can repay the loan with interest.
- **Cancel Loan**: Lenders can cancel their loan offers if they have not yet been accepted by a borrower.
- **Get Loan Details**: Anyone can view the details of a specific loan.

---

## 📄 Contract Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerToPeerLending {
    struct Loan {
        uint id;
        address lender;
        address borrower;
        uint amount;
        uint interestRate;
        uint dueDate;
        bool isActive;
        bool isRepaid;
    }

    uint public loanCount;
    address public admin;
    mapping(uint => Loan) public loans;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier onlyLender(uint _loanId) {
        require(loans[_loanId].lender == msg.sender, "Only the lender can perform this action");
        _;
    }

    modifier onlyBorrower(uint _loanId) {
        require(loans[_loanId].borrower == msg.sender, "Only the borrower can perform this action");
        _;
    }

    // Create a loan offer
    function createLoan(uint _amount, uint _interestRate, uint _duration) public {
        // Using require to validate input parameters
        require(_amount > 0, "Loan amount must be greater than zero");
        require(_interestRate > 0, "Interest rate must be greater than zero");
        require(_duration > 0, "Loan duration must be greater than zero");

        loanCount++;
        loans[loanCount] = Loan(
            loanCount,
            msg.sender,
            address(0),
            _amount,
            _interestRate,
            block.timestamp + _duration,
            true,
            false
        );

        // Using assert to ensure loan was created correctly
        assert(loans[loanCount].id == loanCount);
    }

    // Borrower accepts the loan offer
    function acceptLoan(uint _loanId) public payable {
        Loan storage loan = loans[_loanId];

        // Using require to validate loan ID and status
        require(_loanId > 0 && _loanId <= loanCount, "Invalid loan ID");
        require(loan.isActive, "Loan is no longer active");

        if (loan.borrower != address(0)) {
            // Using revert to handle specific case where loan is already taken
            revert("Loan already taken by someone else");
        }

        // Using require to check the sent amount matches the loan amount
        require(msg.value == loan.amount, "Incorrect amount sent");

        loan.borrower = msg.sender;

        // Transfer funds to the borrower
        payable(loan.borrower).transfer(loan.amount);

        // Using assert to verify that the borrower is set correctly
        assert(loan.borrower == msg.sender);
    }

    // Repay the loan with interest
    function repayLoan(uint _loanId) public payable onlyBorrower(_loanId) {
        Loan storage loan = loans[_loanId];

        // Using require to ensure loan is still active and not already repaid
        require(loan.isActive, "Loan is no longer active");

        if (loan.isRepaid) {
            // Using revert for specific error when loan is already repaid
            revert("Loan is already repaid");
        }

        uint repaymentAmount = loan.amount + (loan.amount * loan.interestRate / 100);
        
        // Using require to validate repayment amount
        require(msg.value == repaymentAmount, "Incorrect repayment amount");

        loan.isRepaid = true;
        loan.isActive = false;

        // Transfer repayment amount to lender
        payable(loan.lender).transfer(repaymentAmount);

        // Using assert to verify repayment status
        assert(loan.isRepaid == true);
    }

    // Cancel the loan offer by the lender
    function cancelLoan(uint _loanId) public onlyLender(_loanId) {
        Loan storage loan = loans[_loanId];

        // Using require to ensure loan is active
        require(loan.isActive, "Loan is already inactive");

        if (loan.borrower != address(0)) {
            // Using revert to handle case where loan cannot be canceled if already accepted
            revert("Cannot cancel, loan has been accepted");
        }

        loan.isActive = false;

        // Using assert to confirm loan is deactivated
        assert(loan.isActive == false);
    }

    // Check loan details
    function getLoanDetails(uint _loanId) public view returns (address lender, address borrower, uint amount, uint interestRate, uint dueDate, bool isActive, bool isRepaid) {
        // Using assert to validate internal contract state
        assert(_loanId > 0 && _loanId <= loanCount);

        Loan memory loan = loans[_loanId];
        return (loan.lender, loan.borrower, loan.amount, loan.interestRate, loan.dueDate, loan.isActive, loan.isRepaid);
    }
} 
```

### Key Components:
- **Loan Struct**: Represents a loan with details such as lender, borrower, amount, interest rate, due date, and status.
- **Modifiers**: 
  - `onlyAdmin`: Restricts certain functions to the contract admin.
  - `onlyLender`: Restricts functions to the lender of a specific loan.
  - `onlyBorrower`: Restricts functions to the borrower of a specific loan.
- **Mappings**: Stores loans using a mapping with loan IDs.

---

## 🚀 How to Use

### Prerequisites
- **Remix IDE**: Access [Remix](https://remix.ethereum.org/) for contract compilation and deployment.
- **MetaMask**: An Ethereum wallet extension for your browser to interact with the blockchain.

### Step 1: Deploying the Contract
1. Open [Remix](https://remix.ethereum.org/).
2. Create a new file named `PeerToPeerLending.sol` and paste the code from `PeerToPeerLending` contract.
3. Compile the contract using the Solidity compiler (`0.8.x` version).
4. Deploy the contract using the **Injected Web3** environment (ensure MetaMask is connected to the desired network).

### Step 2: Interacting with the Contract

After deploying the contract, you can interact with it using the Remix **Deploy & Run Transactions** panel:

1. **Create Loan**
   - Function: `createLoan(uint _amount, uint _interestRate, uint _duration)`
   - Example: Enter `1000`, `5`, and `86400` (for a 24-hour duration) to create a loan.

2. **Accept Loan**
   - Function: `acceptLoan(uint _loanId)`
   - Select a loan ID and send the amount specified by the lender.
   
3. **Repay Loan**
   - Function: `repayLoan(uint _loanId)`
   - Borrower repays the loan with interest.

4. **Cancel Loan**
   - Function: `cancelLoan(uint _loanId)`
   - Only the lender can cancel an active loan if it's not yet accepted.

5. **Get Loan Details**
   - Function: `getLoanDetails(uint _loanId)`
   - View details of a specific loan.

---

## 🛠 Example Walkthrough

1. **Creating a Loan**:
   - Lender creates a loan with `createLoan(1000, 10, 604800)`.
   - This creates a loan of `1000 wei` with a `10%` interest rate and a `7-day` duration.

2. **Accepting a Loan**:
   - Borrower calls `acceptLoan(1)` with `1000 wei`.
   - The contract transfers the loan amount to the borrower.

3. **Repaying the Loan**:
   - Borrower repays with `repayLoan(1)` by sending `1100 wei` (includes 10% interest).
   - The lender receives the repayment amount.

4. **Cancelling a Loan**:
   - Lender can cancel the loan if no borrower has accepted it by calling `cancelLoan(1)`.

---

## 🔐 Security Considerations
- Ensure that only the lender or borrower interacts with their respective functions.
- Validate input parameters to prevent incorrect transactions.
- Revert specific cases where the loan cannot proceed (e.g., already accepted or repaid).

---
