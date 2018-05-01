pragma solidity ^0.4.11;

import './ERC20Token.sol';
import './SafeMath.sol';

contract StandardToken is ERC20Token {
  
  using SafeMath for uint256;
  
  uint256 public  _totalSupply;
 
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowed;
    
  function totalSupply() public constant returns (uint) {
      return _totalSupply;
  }
  
  function balanceOf(address tokenOwner) public constant returns (uint256 balance){
        return balances[tokenOwner];  
  }
  
  function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining){
      return allowed[tokenOwner][spender];
  }
  
  function transfer(address to, uint256 tokens) public returns (bool success){
      require(to != address(0));
      require(
        balances[msg.sender] >= tokens
        && tokens > 0
      );
      balances[msg.sender] = balances[msg.sender].sub(tokens);
      balances[to] = balances[to].add(tokens);
      emit Transfer(msg.sender, to, tokens);
      return true;
  }
  
  function approve(address spender, uint256 tokens) public returns (bool success){
      allowed[msg.sender][spender] = allowed[msg.sender][spender].add(tokens);
      emit Approval(msg.sender, spender, tokens);
      return true;
  }
  
  function transferFrom(address from, address to, uint256 tokens) public returns (bool success){
      require(
          allowed[from][msg.sender] >= tokens
          && balances[from] >= tokens
          && tokens > 0
      );
      
      balances[from] = balances[from].sub(tokens);
      balances[to] = balances[to].add(tokens);
      allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
      emit Transfer(msg.sender, to, tokens);
       
      return true;
  }

  event Transfer(address indexed from, address indexed to, uint256 tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}