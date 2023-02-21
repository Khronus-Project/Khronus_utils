// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {KhronusTimeCog} from "@khronus/time-cog@1.0.2/contracts/src/KhronusTimeCog.sol";
import {KhronusCoordinatorInterface}"../interfaces/KhronusCoordinatorInterface.sol";

abstract contract KhronusClient{

event CoordinatorChanged (
        address indexed oldCoordinator, address indexed newCoordinator, uint timestamp
        );
event OwnerTransfered(
        address indexed sender, address indexed newOwner, uint timestamp
        );

KhronusCoordinatorInterface private KhronusCoordinator;
address owner;
address khronusCoordinator;
    
    constructor (address _khronusCoordinator){
        khronusCoordinator = _khronusCoordinator;
        KhronusCoordinator = KhronusCoordinatorInterface(_khronusCoordinator);
        owner = msg.sender;
    }

    function clientRequestKhronTab(uint256 _timestamp, uint256 _iterations, uint256 _step) internal returns (bytes32){
        require(_iterations==1 && _step==0); //in testing version the full cronjob is not available
        require(KhronusTimeCog.isValidTimestamp(_timestamp), "the timestamp is not valid");
        uint256 _processedTimestamp = _processTimeStamp(_timestamp);
        return KhronusCoordinator.requestKhronTab(_processedTimestamp, _iterations, _step);
    }

    function khronProcessAlert(bytes32 _requestID) internal virtual returns (bool) {
    }

    function khronResponse(bytes32 _requestID) external returns (bool){
        require (msg.sender == khronusCoordinator);
        khronProcessAlert(_requestID);
        return true;
    }


    // Administrative Functions
    function changeCoordinator(address _newCoordinator) external {
        require (msg.sender == owner, "only owner function");
        address _oldCoordinator = khronusCoordinator;
        khronusCoordinator = _newCoordinator;
        KhronusCoordinator = KhronusCoordinatorInterface(_newCoordinator);
        emit CoordinatorChanged(_oldCoordinator, _newCoordinator, block.timestamp);
    }

    function transferOwnership(address _newOwner) external {
        require (msg.sender == owner, "Only owner can set new owner");
        owner = _newOwner;
        emit OwnerTransfered(msg.sender, _newOwner, block.timestamp);
    }
    
    //internal logic functions for timestamp transformation
    function _processTimeStamp(uint256 _timestamp) internal view returns (uint256){
        uint256 _currentTimestamp = block.timestamp;
        require (closestMinuteExact(_timestamp) > closestMinuteExact(_currentTimestamp), "alerts are only allowed at least one minute in the future");
        return closestMinuteExact(_timestamp);
    }

    function closestMinuteExact(uint256 _timestamp) internal pure returns (uint256){
        return KhronusTimeCog.nextMinute(_timestamp) - 1 minutes;
    }

    function isValidKhronTimestamp(uint256 _timestamp) internal pure returns (bool){
        if (_timestamp % 60 == 0 && KhronusTimeCog.isValidTimestamp(_timestamp)){
            return true;
        }
        else{
            return false;
        }
    }
}