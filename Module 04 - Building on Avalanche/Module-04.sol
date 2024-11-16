// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Importing OpenZeppelin's ERC20 contract implementation
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Degen Gaming
 * @dev A token-based game contract that allows users to mint, burn, transfer tokens, and redeem items.
 * @notice This contract is designed to manage an in-game store where users can purchase items using tokens.
 */
contract GameClone is ERC20 {

    address public owner;

    mapping(uint256 => string) public itemName;
    mapping(uint256 => uint256) public itemPrice;
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