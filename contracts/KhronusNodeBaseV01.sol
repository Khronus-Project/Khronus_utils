// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KhronusCoordinatorInterface {
   
   enum timeUnit{
        noUnit,
        unitMinute,
        unitHour,
        unitDay,
        unitMonth
    }
    // Interface Functions
    // Only owner and internal functions are not provided

    //Client related functions
    function registerClient(
        address _clientContract, 
        uint256 _deposit) 
        external;
    
    function fundClient(
        address _clientContract, 
        uint256 _deposit
        ) 
        external 
        returns(bool);

    //Node contract related functions
    function registerNode(
        address _nodeAddress
        ) 
        external 
        returns (bytes32);  

    //KhronTab related functions
    
    //Set khron request
    function requestKhronTab(
        uint256 _timestamp, 
        uint256 _iterations, 
        uint256 _step) 
        external 
        returns(bytes32);
    
    //Serve khron alerts
    function serveKhronAlert(
        bytes32 _alertID
        ) 
        external 
        returns (bool);
    
    //Withdrawal functions
    function getNodeFromIndex(bytes32 _index) external view returns(address);
    
    function getKhronBalanceOf(address _beneficiary) external view returns (uint256);

    function getOperatorMarkup() external view returns (uint256);

    function getRegistrationDeposit() external view returns (uint256);

    function getMinimumKhronClientBalance() external view returns (uint256);

    function getBandOfTolerance() external view returns (uint256);

    function getProtocolGasConstant() external view returns(uint256);
}

abstract contract KhronusNode {
    event RequestReceived(
        address indexed relatedAddress,
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
            emit RequestReceived(_requester,_data);
        }   
}