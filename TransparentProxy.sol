// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TransparentProxy
 * @dev Implementation of a transparent proxy pattern following EIP-1967.
 * This proxy forwards all calls to an implementation contract while
 * maintaining separate admin functions that won't clash with the implementation.
 */
contract TransparentProxy {
    // Storage slot with the address of the current implementation.
    // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // Storage slot with the admin of the contract.
    // This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1
    bytes32 private constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin changes.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Contract constructor.
     * @param _logic Address of the initial implementation.
     * @param _admin Address of the proxy administrator.
     */
    constructor(address _logic, address _admin) {
        require(_logic != address(0), "Implementation cannot be zero address");
        require(_admin != address(0), "Admin cannot be zero address");
        
        // Store the implementation address
        _setImplementation(_logic);
        
        // Store the admin address
        _setAdmin(_admin);
    }

    /**
     * @dev Modifier to check if caller is admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() external ifAdmin returns (address) {
        return _getImplementation();
    }

    /**
     * @dev Returns the current admin.
     */
    function admin() external ifAdmin returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Changes the admin of the proxy.
     * Only callable by current admin.
     */
    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address");
        address oldAdmin = _getAdmin();
        _setAdmin(newAdmin);
        emit AdminChanged(oldAdmin, newAdmin);
    }

    /**
     * @dev Upgrades the implementation address.
     * Only callable by admin.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        require(newImplementation != address(0), "Implementation cannot be zero address");
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Fallback function that delegates calls to the implementation.
     * Will run if call data is empty or if admin function doesn't match.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Receive function to allow the contract to receive Ether.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @dev Private function that delegates the current call to the implementation.
     */
    function _fallback() private {
        // Get current implementation
        address _impl = _getImplementation();
        
        // Copy msg.data
        bytes memory data = msg.data;
        
        // Delegate call to the implementation
        assembly {
            // Copy calldata to memory
            calldatacopy(0, 0, calldatasize())
            
            // Delegate call to implementation
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            
            // Copy the returned data
            returndatacopy(0, 0, returndatasize())
            
            // Forward the result
            switch result
            // delegatecall returns 0 on error
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() private view returns (address implementation_) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            implementation_ := sload(slot)
        }
    }

    /**
     * @dev Stores a new implementation address.
     */
    function _setImplementation(address newImplementation) private {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    /**
     * @dev Returns the current admin address.
     */
    function _getAdmin() private view returns (address admin_) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            admin_ := sload(slot)
        }
    }

    /**
     * @dev Stores a new admin address.
     */
    function _setAdmin(address newAdmin) private {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, newAdmin)
        }
    }
}
