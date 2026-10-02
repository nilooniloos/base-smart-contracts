// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDelegate {

    mapping(address => mapping(uint256 => address)) public delegates;

    event DelegateSet(
        address indexed owner,
        uint256 indexed roleId,
        address indexed delegate
    );

    event DelegateRemoved(
        address indexed owner,
        uint256 indexed roleId
    );

    function setDelegate(
        uint256 roleId,
        address delegate
    ) external {
        require(
            delegate != address(0),
            "Invalid delegate"
        );

        require(
            delegate != msg.sender,
            "Cannot delegate to yourself"
        );

        delegates[msg.sender][roleId] = delegate;

        emit DelegateSet(
            msg.sender,
            roleId,
            delegate
        );
    }

    function removeDelegate(
        uint256 roleId
    ) external {
        require(
            delegates[msg.sender][roleId] != address(0),
            "No delegate"
        );

        delete delegates[msg.sender][roleId];

        emit DelegateRemoved(
            msg.sender,
            roleId
        );
    }

    function getDelegate(
        address owner,
        uint256 roleId
    ) external view returns (address) {
        return delegates[owner][roleId];
    }

    function isDelegate(
        address owner,
        uint256 roleId,
        address account
    ) external view returns (bool) {
        return delegates[owner][roleId] == account;
    }
}
