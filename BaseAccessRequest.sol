// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseAccessRequest {
    enum Status {
        None,
        Pending,
        Approved,
        Rejected
    }

    mapping(address => mapping(uint256 => Status)) public requests;

    function requestAccess(uint256 resourceId) external {
        requests[msg.sender][resourceId] = Status.Pending;
    }

    function approve(address user, uint256 resourceId) external {
        requests[user][resourceId] = Status.Approved;
    }

    function reject(address user, uint256 resourceId) external {
        requests[user][resourceId] = Status.Rejected;
    }

    function getStatus(address user, uint256 resourceId)
        external
        view
        returns (Status)
    {
        return requests[user][resourceId];
    }
}
