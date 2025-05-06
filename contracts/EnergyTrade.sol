// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract EnergyTrade {
    struct User {
        uint256 energyBalance;
        uint256 moneyBalance;
        bool isRegistered;
    }

    struct Transaction {
        address sender;
        address receiver;
        uint256 energyAmount;
        uint256 moneyAmount;
        uint256 timestamp;
    }

    mapping(address => User) public users;
    address[] public userList;
    Transaction[] public transactions;

    event UserRegistered(address indexed user, uint256 energy, uint256 money);
    event EnergySent(address indexed sender, address indexed receiver, uint256 energyAmount);
    event EnergyReceived(address indexed receiver, address indexed sender, uint256 energyAmount, uint256 payment);

    modifier onlyRegistered() {
        require(users[msg.sender].isRegistered, "You must be registered to perform this action.");
        _;
    }

    // 🟢 Function to register new users
    function registerUser(uint256 _energy, uint256 _money) public {
        require(!users[msg.sender].isRegistered, "User already registered");
        users[msg.sender] = User(_energy, _money, true);
        userList.push(msg.sender);
        emit UserRegistered(msg.sender, _energy, _money);
    }

    // 🟢 Function to send energy as data (stored in block)
    function sendEnergy(address _receiver, uint256 _energyAmount, uint256 _moneyAmount) public onlyRegistered {
        require(users[_receiver].isRegistered, "Recipient is not registered");
        require(users[msg.sender].energyBalance >= _energyAmount, "Not enough energy");

        // Deduct energy from sender's balance
        users[msg.sender].energyBalance -= _energyAmount;

        // Store transaction in blockchain
        transactions.push(Transaction(msg.sender, _receiver, _energyAmount, _moneyAmount, block.timestamp));
        
        //save the transaction to blockchain
        //save the array data to database 
        

        emit EnergySent(msg.sender, _receiver, _energyAmount);
    }

    // 🟢 Function to receive energy and pay the sender
    function receiveEnergy(uint256 _transactionIndex) public payable onlyRegistered {
        require(_transactionIndex < transactions.length, "Invalid transaction index");
        Transaction storage txn = transactions[_transactionIndex];

        require(txn.receiver == msg.sender, "You are not the intended recipient");
        require(users[msg.sender].moneyBalance >= txn.moneyAmount, "Not enough money to complete transaction");

        // Add energy to receiver's balance
        users[msg.sender].energyBalance += txn.energyAmount;

        // Transfer money to sender
        users[msg.sender].moneyBalance -= txn.moneyAmount;
        users[txn.sender].moneyBalance += txn.moneyAmount;

        emit EnergyReceived(msg.sender, txn.sender, txn.energyAmount, txn.moneyAmount);
    }

    // 🟢 Function to get all users and their balances
    function getAllUsers() public view returns (address[] memory, uint256[] memory, uint256[] memory) {
        uint256 length = userList.length;
        address[] memory addresses = new address[](length);
        uint256[] memory energyBalances = new uint256[](length);
        uint256[] memory moneyBalances = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            address user = userList[i];
            addresses[i] = user;
            energyBalances[i] = users[user].energyBalance;
            moneyBalances[i] = users[user].moneyBalance;
        }

        return (addresses, energyBalances, moneyBalances);
    }

    // 🟢 Function to get all transactions stored on the blockchain
    function getTransactions() public view returns (Transaction[] memory) {
        return transactions;
    }
}