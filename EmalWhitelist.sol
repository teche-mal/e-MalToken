pragma solidity ^0.4.11;


/**
 * This contract provides support for whitelisting addresses
 */
contract EmalWhitelist {

  mapping(address => bool) public whitelist;

  /**
   * Returns if an address is whitelisted or not
   */
  function isWhitelisted(address investorAddr) public view returns (bool whitelisted) {
    return whitelist[investorAddr];
  }

  /**
   * Adds an address to whitelist
   */
  function addToWhitelist(address investorAddr) public {
    whitelist[investorAddr] = true;
  }

  /**
   * Removes an address from whitelist
   */
  function removeFromWhitelist(address investorAddr) public {
    whitelist[investorAddr] = false;
  }

}