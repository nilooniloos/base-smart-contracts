// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDeadline {
    mapping(uint256 => uint256) public deadlines;

    function setDeadline(uint256 id, uint256 deadline) external {
        require(deadline > block.timestamp, "Invalid deadline");
        deadlines[id] = deadline;
    }

    function isExpired(uint256 id) external view returns (bool) {
        return deadlines[id] != 0 && block.timestamp >= deadlines[id];
    }

    function getRemainingTime(uint256 id) external view returns (uint256) {
        if (block.timestamp >= deadlines[id]) {
            return 0;
        }

        return deadlines[id] - block.timestamp;
    }
}
