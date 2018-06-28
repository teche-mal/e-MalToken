pragma solidity ^0.4.11;

import './SafeMath.sol';
import './EmalWhitelist.sol';
import './EmalToken.sol';

/*
* This smart contract builds on top of the crowdsale smart contract for eMal ICO.
* This will collect funds from investors in ETH directly from the investor post which it will emit an event
* The event will then be collected by eMal backend servers and based on the amount of ETH sent and ETH rate 
* in terms of DHS, the tokens to be allocated will be calculated by the backend server and then it will call 
* allocate tokens API for investors address. 
* In case the investment is not done through ETH, and directly through netbanking or on the public sale platform,
* eMAl backend server will calculate the number of tokens to be allocated and then directly call the allocate 
* tokens API to allocate tokens to the investor.
*/
contract EmalCrowdsale is EmalWhitelist {
    
    using SafeMath for uint256;
    
    // Total ether invested during the crowdsale    
    uint256 public totalEtherInvested = 0;

    // Total token allocated during the crowdsale
    uint256 public totalTokensAllocated = 0;

    // Total of amount invested for an investor
    // This mapping helps when the pre sale investor directly sends ether to the contract
    mapping(address => uint256) public investedAmounts;
    
    // Count of allocated tokens for each investor
    mapping(address => uint256) public allocatedTokens;
    
    // Count of allocated tokens for each investor that are sent to the crowdsale
    mapping(address => uint256) public allocatedTokensSent;
    
    // switch to turn public sale on/off
    bool public crowdsaleActive = false;
    
    // The main crodsale object
    EmalToken public emalToken;
    
    // Owner of the contract
    address public owner;
    
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
        totalTokensAllocated = totalTokensAllocated.add(tokenCount);
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
        totalTokensAllocated = totalTokensAllocated.sub(tokenCount);
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
        
        uint256 tokensToSend = allocatedTokens[investorAddr];

        emalToken.transfer(investorAddr, tokensToSend);
        
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
        // Only accept contributions when crowdsale is active
        // Only accept contributions from whitelisted investors;
        require(crowdsaleActive && isWhitelisted(msg.sender));
        
        investedAmounts[msg.sender] = investedAmounts[msg.sender].add(msg.value);
        totalEtherInvested = totalEtherInvested.add(msg.value);
        emit etherInvested(msg.sender, msg.value);
    }

    function getInvestedAmount(address investorAddr) public view returns (uint256 investedAmount){
        // returns amount invested as ether by an investor, directly to the crowdsale contract
        return investedAmounts[investorAddr];   
    }
    
    /*
    * Activate the crowdsale
    */
    function activateCrowdsale() public returns (bool success){
        // Only owner of the contract can activate crowdsale
        require(msg.sender == owner);
        crowdsaleActive = true;
        return true;
    }
    
    /*
    * Deactivate the crowdsale
    */
    function deactivateCrowdsale() public returns (bool success){
        // Only owner of the contract can deactivate crowdsale
        require(msg.sender == owner);
        crowdsaleActive = false;
        return true;
    }
    
    /*
    * Set the target token
    */
    function setToken(EmalToken token_addr) public returns (bool success){
        require(msg.sender == owner);
        emalToken = token_addr;
        return true;
    }

    /*
    * Set the owner of the contract
    */
    function setOwner(address new_owner) public returns (bool success){
        require(msg.sender == owner);
        owner = new_owner;
        return true;
    }
}