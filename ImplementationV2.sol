// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ImplementationV2
 * @dev Upgraded implementation contract for use with the transparent proxy.
 * Shows how to add new functionality while maintaining compatibility with existing state.
 */
contract ImplementationV2 {
    // State variables - must match the storage layout of the original implementation
    uint256 public value;
    address public owner;
    bool private initialized;
    
    // New state variables must be added after the original ones
    string public message;
    
    // Events
    event ValueChanged(uint256 newValue);
    event MessageChanged(string newMessage);
    
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
     * This should NOT be called when upgrading, only for new deployments
     */
    function initialize(uint256 initialValue) public initializer {
        value = initialValue;
        owner = msg.sender;
    }
    
    /**
     * @dev Function to initialize the V2 specific state
     * This should be called after upgrading
     */
    function initializeV2(string memory initialMessage) public onlyOwner {
        require(bytes(message).length == 0, "V2 already initialized");
        message = initialMessage;
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
     * @dev New function that didn't exist in V1
     * Sets a message string
     */
    function setMessage(string memory newMessage) public onlyOwner {
        message = newMessage;
        emit MessageChanged(newMessage);
    }
    
    /**
     * @dev New function that didn't exist in V1
     * Increments by a specific amount
     */
    function incrementBy(uint256 amount) public onlyOwner {
        value += amount;
        emit ValueChanged(value);
    }
    
    /**
     * @dev Function to get version of the implementation
     */
    function getVersion() public pure returns (string memory) {
        return "V2";
    }
}
