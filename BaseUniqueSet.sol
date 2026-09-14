// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseUniqueSet {
    mapping(uint256 => bool) public exists;
    uint256[] private values;

    function add(uint256 value) external {
        require(!exists[value], "Already exists");

        exists[value] = true;
        values.push(value);
    }

    function contains(uint256 value) external view returns (bool) {
        return exists[value];
    }

    function getValue(uint256 index) external view returns (uint256) {
        return values[index];
    }

    function length() external view returns (uint256) {
        return values.length;
    }
}
