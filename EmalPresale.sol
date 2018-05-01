pragma solidity ^0.4.11;

import './EmalCrowdsale.sol';
import './SafeMath.sol';
import './EmalWhitelist.sol';

/*
* This smart contract builds on top of the crowdsale smart contract for eMal ICO.
* This will collect funds from investors in ETH directly from the investor post which it will emit an event
* The event will then be collected by eMal backend servers and based on the amount of ETH sent and ETH rate 
* in terms of DHS, the tokens to be allocated will be calculated by the backend server and then it will call 
* allocate tokens API for investors address. 
* In case the investment is not done through ETH, and directly through netbanking or on the pre sale platform,
* eMAl backend server will calculate the number of tokens to be allocated and then directly call the allocate 
* tokens API to allocate tokens to the investor.
*/
contract EmalPresale is EmalWhitelist {
    
    using SafeMath for uint256;
    
    // Address of presale investtors
    address[] public investors;
    
    // Total of amount invested for an investor
    // This mapping helps when the pre sale investor directly sends ether to the contract
    mapping(address => uint256) public investedAmounts;
    
    // Count of allocated tokens for each investor
    mapping(address => uint256) public allocatedTokens;
    
    // Count of allocated tokens for each investor that are sent to the crowdsale
    mapping(address => uint256) public allocatedTokensSent;
    
    // switch to turn presale on/off
    bool public presaleActive = false;
    
    // The main crodsale object
    EmalCrowdsale public crowdsale;
    
    // Owner of the contract
    address owner;
    
    // Event fired when tokens are allocated to an investor account
    event etherInvested(address investor, uint256 value);
    
    // Event fired when tokens are allocated to an investor account
    event allocatedTokens(address investor, uint256 tokenCount);
    
    // Event fired when tokens are sent to the main crodsale for an investor
    event sentAllocatedTokens(address investor, uint256 tokenCount);
    
    constructor() public {
        // Set the creator of the smart contract as the owner
        owner = msg.sender;
    }
    
    /*
    * Allocates tokens to an investor
    */
    function allocateTokens(address investorAddr, uint256 tokenCount) public returns (bool success) {
        // Only the owner of the contract can allocate tokens to an address
        // Tokens to be allocated must be more than 0
        require( msg.sender == owner && tokenCount > 0);
        allocatedTokens[investorAddr] = allocatedTokens[investorAddr].add(tokenCount);
        return true;
    }
    
    /*
    * Remove tokens from an investors allocation
    */
    function deductAllocatedTokens(address investorAddr, uint256 tokenCount) public returns (bool success) {
        // Only the owner of the contract can allocate tokens to an address
        // Tokens to be allocated must be more than 0
        // The address must has at least the number of tokens to be deducted
        require( msg.sender == owner && tokenCount > 0 && allocatedTokens[investorAddr] > tokenCount );
        allocatedTokens[investorAddr] = allocatedTokens[investorAddr].sub(tokenCount);
        return true;
    }
    
    /*
    * Allocates tokens to an investor
    */
    function getAllocatedTokens(address investorAddr) public view returns (uint256 tokenCount) {
        return allocatedTokens[investorAddr];
    }
    
    /*
    * Sends investments of the investor to the main crodsale from where the tokens will be transferred
    * to the investors address
    */
    function sendInvestmentsToCrowdsale(address investorAddr) public returns (bool success){
        // Only the owner of the contract can send investments to crowdsale
        // investments of the investor should be greater than 0
        require(msg.sender == owner && allocatedTokens[investorAddr] > 0);
        
        ////////////
        ////////////
        // ToDo: Once the crodsale contract is developed. Write code to participate in the crowdsale
        ////////////
        ////////////
        
        uint256 tokensToSend = allocatedTokens[investorAddr];
        
        // Send all allocated tokens to the crowdsale
        allocatedTokens[investorAddr] = 0;
        allocatedTokensSent[investorAddr] = allocatedTokensSent[investorAddr].add(tokensToSend);
        
        emit sentAllocatedTokens(investorAddr, tokensToSend);
        return true;
    }
    
    /*
    * Adds an investor to whitelist
    */
    function addWhitelistInvstor(address investorAddr) public returns (bool success){
        // Only the owner of the contract can add an address from whitelist
        require(msg.sender == owner);
        addToWhitelist(investorAddr);
        return true;
    }
    
    /*
    * Removes an investor's address from whitelist 
    */
    function removeWhitelistInvstor(address investorAddr) public returns (bool success) {
        // Only the owner of the contract can remove an address from whitelist
        require(msg.sender == owner);
        removeFromWhitelist(investorAddr);
        return true;
    }
    
    /*
    * If the investor directly invests ether to the smart contract
    */
    function() public payable { 
        // Only accept contributions when presale is active
        // Only accept contributions from whitelisted investors;
        require(presaleActive && isWhitelisted(msg.sender));
        
        investedAmounts[msg.sender] = investedAmounts[msg.sender].add(msg.value);
        emit etherInvested(msg.sender, msg.value);
    }
    
    /*
    * Activate the presale
    */
    function activatePresale() public returns (bool success){
        // Only owner of the contract can activate presale
        require(msg.sender == owner);
        presaleActive = true;
        return true;
    }
    
    /*
    * Deactivate the presale
    */
    function deactivatePresale() public returns (bool success){
        // Only owner of the contract can deactivate presale
        require(msg.sender == owner);
        presaleActive = false;
        return true;
    }
    
    /*
    * Set the target crowdsale where we will move presale funds when the crowdsale opens.
    */
    function setCrowdsale(EmalCrowdsale _crowdsale) public returns (bool success){
        require(msg.sender == owner);
        crowdsale = _crowdsale;
        return true;
    }
}