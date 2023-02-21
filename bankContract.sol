// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract simpleBankContract {

    // address is use to store owner blockchain address
    // note: every individual have a different address
    address contractOwner;

    // this mapping is use to go through user
    // here it uses address of the user and return a number, which is their balance
    mapping(address => uint) bankBalance;

    // event are use to show or mit logs on the blockchain
    // here we are emitting user deposits and withdrawal details
    event VaultDeposit(address accountHolder, uint deposit, uint newBalance);
    event VaultWithdrawal(address accountHolder, uint withdrawal, uint newBalance);

   // defining a modifier which only the owner and creator of this contract can call
   // modifier from my experience to either restrict users/owner to call specific function
    modifier onlyOwner() {
        // we major use require to check inputs in solidity
        // require acts like if/else statement in solidity
        require(contractOwner == msg.sender, "Only Bank Owner is authorized");
        _; // this under score and semi-column is to end this statement
    }

  // you can also make the constructor public if you want
  // constructor are immutable/can not change when they are deploy on the blockchain
  // but we can reset their owner/values by create a function that will updates it 
    constructor() payable {
        contractOwner = payable(msg.sender);
    }

   // functions are groups of code that perform a specific tasks
   // each task a user or owner wants to perform, such as; deposit and withdraw are all handle by diff. functions
    function deposit() external payable {

        // check the previous user balance plus the amount he/she is greater their their previous balance
        require(bankBalance[msg.sender] + msg.value >= bankBalance[msg.sender], "Addition: Balance Overflow");

        // set the balance of user to the amount he provided
        bankBalance[msg.sender] += msg.value;

        // uint are known as unsign integer
        // it used for store positive numbers, i.e numbers only
        // store the the amount the user wants to deposit to an unsign integar
        uint amount = msg.value;

        // now we are emitting the address of the depositor, amount deposited and their current balance
        emit VaultDeposit(msg.sender, amount, bankBalance[msg.sender]);
    }

    function withdrawal(uint _amount) external returns (bytes memory){
        // checking if the amount of user wants to is less than their account balance
        require(_amount <= bankBalance[msg.sender], "Subtraction: balance underflow");

        // here we say that user account balance minus the amount they want to withdraw
        // we just substracted the account balance, but fund where transferred to the user
        bankBalance[msg.sender] -= _amount;

        // Here is where the fund transfer takes place
        // we use call to send the funds instead of transfer or send method
        (bool success, bytes memory data) = msg.sender.call{value: _amount}("success");

        // check if the transfer was successful
        require(success, "Failed Transaction");

        // show log on the blockchain when funds is withdrawed by its owners
        emit VaultWithdrawal(msg.sender, _amount, bankBalance[msg.sender]);
 
       // just transaction data 
        return data;
    }

    // this checks user balances 
    function getBalance() public view returns(uint) {
        return bankBalance[msg.sender];
    }

    // this function is called by bank owners
    // users are not expected to know total funds in the bank
    function vaultBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }
}
