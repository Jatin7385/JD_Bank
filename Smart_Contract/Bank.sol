//Set the compiler level
pragma solidity 0.4.25;

contract Bank
{
    int balance;

    //Creating a constructor
    constructor() public
    {
        balance = 1;
    }

    //Creating functions
    //view means this function is only for fetching value
    function getBalance() view public returns(int)
    {
        return balance;
    }

    function withdraw(int amount) public
    {
        balance = balance - amount;
    }

    function deposit(int amount) public
    {
        balance = balance + amount;
    }
}