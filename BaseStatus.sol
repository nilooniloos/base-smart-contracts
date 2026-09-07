// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseStatus {
    mapping(address => string) public status;
    mapping(address => uint256) public updates;

    uint256 public totalUpdates;

    function setStatus(string calldata newStatus) external {
        require(bytes(newStatus).length > 0, "Empty status");
        require(bytes(newStatus).length <= 160, "Status too long");

        status[msg.sender] = newStatus;
        updates[msg.sender]++;
        totalUpdates++;
    }

    function getStatus(address user)
        external
        view
        returns (string memory)
    {
        return status[user];
    }
