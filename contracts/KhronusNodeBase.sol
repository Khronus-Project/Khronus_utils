// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/KhronusCoordinatorInterface.sol";

abstract contract KhronusNode {
    event RequestReceived(
        address indexed sender,
        uint256 value,
        bytes data
        );
    
    event RequestServed(
        uint256 totalGas
        );

    KhronusCoordinatorInterface private KhronusCoordinator;
    address owner;

    constructor (address _khronusCoordinator) {
        KhronusCoordinator = KhronusCoordinatorInterface(_khronusCoordinator);
        owner = msg.sender;
    }

    function fulfillAlert(bytes32 _alertID) external {
        uint _gasCost  = gasleft();
        KhronusCoordinator.serveKhronAlert(_alertID);
        _gasCost -= gasleft();
        emit RequestServed(_gasCost);
    }
    
    function testing() external view returns (address){
        return owner;
    }

    function onTokenTransfer(
        address _sender, 
        uint256 _value, 
        bytes memory _data
        ) 
        external {
            emit RequestReceived(_sender,_value,_data);
        }
}