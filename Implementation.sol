// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Implementation
 * @dev Sample implementation contract for use with the transparent proxy.
 * Note the absence of a constructor and the use of an initializer function instead.
 */
contract Implementation {
    // State variables
    uint256 public value;
    address public owner;
    bool private initialized;
    
    // Events
    event ValueChanged(uint256 newValue);
    
    /**
     * @dev Modifier to prevent reinitialization
     */
    modifier initializer() {
        require(!initialized, "Contract already initialized");
        _;
        initialized = true;
    }
    
    /**
     * @dev Modifier to restrict function access to owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    /**
     * @dev Initializer function to replace constructor
     * This must be called after deployment
     */
    function initialize(uint256 initialValue) public initializer {
        value = initialValue;
        owner = msg.sender;
    }
    
    /**
     * @dev Function to update the stored value
     */
    function setValue(uint256 newValue) public onlyOwner {
        value = newValue;
        emit ValueChanged(newValue);
    }
    
    /**
     * @dev Function to increment the stored value
     */
    function increment() public onlyOwner {
        value += 1;
        emit ValueChanged(value);
    }
    
    /**
     * @dev Function to get version of the implementation
     */
    function getVersion() public pure returns (string memory) {
        return "V1";
    }
}
