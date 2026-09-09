// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDeadline {
    mapping(uint256 => uint256) public deadlines;

    function setDeadline(uint256 itemId, uint256 deadline) external {
        deadlines[itemId] = deadline;
    }

    function isExpired(uint256 itemId) external view returns (bool) {
        return block.timestamp >= deadlines[itemId];
    }

    function getRemainingTime(uint256 itemId) external view returns (uint256) {
        if (block.timestamp >= deadlines[itemId]) {
            return 0;
        }

        return deadlines[itemId] - block.timestamp;
    }
}
