// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCheckIn {

    mapping(address => uint256) public lastCheckIn;
    mapping(address => uint256) public checkInCount;

    uint256 public totalCheckIns;

    event CheckedIn(
        address indexed user,
        uint256 timestamp,
        uint256 count
    );

    function checkIn() external {
        uint256 today = block.timestamp / 1 days;

        require(
            lastCheckIn[msg.sender] != today,
            "Already checked in today"
        );

        lastCheckIn[msg.sender] = today;
        checkInCount[msg.sender]++;
        totalCheckIns++;

        emit CheckedIn(
            msg.sender,
            block.timestamp,
            checkInCount[msg.sender]
        );
    }

    function getMyCheckIns()
        external
        view
        returns (uint256)
    {
        return checkInCount[msg.sender];
    }

    function getUserCheckIns(address user)
        external
        view
        returns (uint256)
    {
        return checkInCount[user];
    }
}
