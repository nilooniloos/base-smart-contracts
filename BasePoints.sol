// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BasePoints {
    mapping(address => uint256) public points;

    uint256 public totalPoints;

    function addPoints(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        points[msg.sender] += amount;
        totalPoints += amount;
    }

    function myPoints() external view returns (uint256) {
        return points[msg.sender];
    }
}
