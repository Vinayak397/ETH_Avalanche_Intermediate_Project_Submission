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

    // Mapping to store members by address
    mapping(address => Member) public members;
    address public manager;
    uint256 public societyBalance;

    // Constructor to set the contract deployer as the manager
    constructor() {
        manager = msg.sender;
    }

    // Modifier to restrict certain functions to the manager
    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can perform this action");
        _;
    }

    // Function to add a new member (only by the manager)
    function addMember(address _memberAddress, string memory _name, uint256 _flatNumber) public onlyManager {
        require(!members[_memberAddress].isMember, "Member already exists");
        members[_memberAddress] = Member({
            name: _name,
            flatNumber: _flatNumber,
            duesPaid: 0,
            isMember: true
        });
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

    // Function to get the society's total balance (only accessible by the manager)
    function getSocietyBalance() public view onlyManager returns (uint256) {
        return societyBalance;
    }
}
