pragma solidity ^0.4.11;

import './StandardToken.sol';

contract EmalToken is StandardToken {
  
  string public constant symbol = "EMAL";
  string public constant name = "E-Mal Token";
  uint8 public constant decimals = 18;
  
  uint256 public constant supply = 10000000 * 1 ether;

  constructor() public {
       balances[msg.sender] = supply;
       _totalSupply = supply;
  }
}