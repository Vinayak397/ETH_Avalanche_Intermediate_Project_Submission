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
