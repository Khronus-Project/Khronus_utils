// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/KhronusCoordinatorInterface.sol";

abstract contract KhronusNode {
    event RequestReceived(
        address indexed relatedAddress,
        uint256 value,
        bytes data
        );
    
    event RequestServed(
        uint256 totalGas
        );
    
    event NodeSet(
        address indexed khronNode, uint timestamp
        );

    event OwnerTransfered(
        address indexed sender, address indexed newOwner, uint timestamp
        );

    KhronusCoordinatorInterface private KhronusCoordinator;
    address khronNode;
    address owner;

    constructor (address _khronusCoordinator) {
        KhronusCoordinator = KhronusCoordinatorInterface(_khronusCoordinator);
        owner = msg.sender;
    }


    function fulfillAlert(bytes32 _alertID) external {
        require (msg.sender == khronNode, "Only Khron Node can fulfill alerts");
        uint _gasCost  = gasleft();
        KhronusCoordinator.serveKhronAlert(_alertID);
        _gasCost -= gasleft();
        emit RequestServed(_gasCost);
    }


    function setKhronNode(address _khronNode) external {
        require (msg.sender == owner, "Only owner can set Node");
        khronNode = _khronNode;
        emit NodeSet(_khronNode, block.timestamp);
    }

    function transferOwnership(address _newOwner) external {
        require (msg.sender == owner, "Only owner can set new owner");
        owner = _newOwner;
        emit OwnerTransfered(msg.sender, _newOwner, block.timestamp);
    }
    
    function getOwner() external view returns (address){
        return owner;
    }

    function getNode() external view returns (address){
        return khronNode;
    }

    function broadcast(
        address _requester,
        bytes memory _data
        ) 
        external {
            require (msg.sender == address(KhronusCoordinator),"Only coordinator contract can broadcast to nodes");
            emit RequestReceived(_requester,0,_data);
        }   
}