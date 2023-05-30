// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSigWallet {

    event Deposit(address indexed sender, uint amount);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    address[] public owners;
    uint public numConfirmationsRequired; //no of confirmations required to approve a transaction

    event Revoke(address indexed owner, uint indexed txIndex); //revoke transaction if a owner changes his mind and dont want to sign it
    event Submit( address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data); //submit the transaction and wait for other owners to approve
    event Approve(address indexed owner, uint indexed txIndex); // get approval from owners to sign a transaction
    event Execute(address indexed owner, uint indexed txIndex); // execute a transaction after all owners approve

    mapping(address => bool) public isOwner; //if the address is msg.sender , the bool will be true otherwise false.

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    Transaction[] public transactions;

    mapping(uint => mapping(address => bool)) public isConfirmed;        //uint is the index of the owner array, ex: if owner 2 wants to send a transaction, uint will be 1;

    constructor(address[] memory _owners, uint _numConfirmationsRequired){
        require(_owners.length > 0, "owners required");  //checking if the array is not 0
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length);  //cheking if the num of confirmations are more than 0

        // loop for adding owners to the wallet
        for (uint i; i < _owners.length ; i++){
            address owner = _owners[i];  //assigning owner to the added _owners from the loop

            require(owner != address(0), "invalid owner");  // checking if the address of the owner is not 0
            require(!isOwner[owner], "owner already present"); // checking if the owner is already present in the isOwner mapping

            //pushing the owner in the isOwner mapping
            isOwner[owner] = true;
            owners.push(owner);
        }

        _numConfirmationsRequired = numConfirmationsRequired;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not an owner");
        _;
    }

    // using calldata bc it is an external function and calldata is more gas effecient than memory
    function submit(address _to, uint _value, bytes calldata _data ) external onlyOwner{
        //index where a transaction is stored
        uint txIndex = transactions.length;
        // pushing all these parameters into a transactions array and initializing the struct Transactions
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed : false,
            numConfirmations: 0
        }));
        emit Submit(msg.sender, txIndex, _to, _value, _data);
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    //modifier to check if the transaction is not yet approved by the msg.sender
    modifier notApproved(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    function approve(uint _txIndex) external onlyOwner txExists(_txIndex) notApproved(_txIndex) notExecuted(_txIndex) {
        // one method is this, to increase count of confirmations
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
             /// **********  //////
        isConfirmed[_txIndex][msg.sender] = true;
        emit Approve(msg.sender, _txIndex);
    }

    // other method is this
    // function to get that approval counts are in majority before executing transaction 
    // function _getApprovalCount(uint _txIndex) private view returns (uint count) {
    //     for(uint i; i < owners.length; i++){
    //         if(isConfirmed[_txIndex][owners[i]]){
    //             count ++;
    //         }
    //     }
    // }

    function execute(uint _txIndex) external onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(success, "tx failed");

        emit Execute(msg.sender, _txIndex);
    }

    function revokeConfirmation(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        //for an owner to revoke a transaction, he must first approved it, so we are checking if its approved or not
        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit Revoke(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(
        uint _txIndex
    )
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}