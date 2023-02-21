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
        external;
    
    //Withdrawal functions
    function getNodeFromIndex(bytes32 _index) external view returns(address);
    
    function getKhronBalanceOf(address _beneficiary) external view returns (uint256);

    function getOperatorMarkup() external view returns (uint256);

    function getRegistrationDeposit() external view returns (uint256);

    function getMinimumKhronClientBalance() external view returns (uint256);

    function getBandOfTolerance() external view returns (uint256);

    function getProtocolGasConstant() external view returns(uint256);
}