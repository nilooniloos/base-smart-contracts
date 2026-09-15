// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseBitFlags {
    mapping(address => uint256) private flags;

    function setFlag(uint8 index, bool value) external {
        require(index < 256, "Invalid index");

        uint256 mask = uint256(1) << index;

        if (value) {
            flags[msg.sender] |= mask;
        } else {
            flags[msg.sender] &= ~mask;
        }
    }

    function getFlag(address user, uint8 index) external view returns (bool) {
        require(index < 256, "Invalid index");

        uint256 mask = uint256(1) << index;
        return (flags[user] & mask) != 0;
    }

    function getFlags(address user) external view returns (uint256) {
        return flags[user];
    }
}
