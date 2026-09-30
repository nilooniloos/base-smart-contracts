// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseRSVP {

    mapping(address => mapping(uint256 => bool)) public attending;
    mapping(uint256 => uint256) public attendeeCount;

    event RSVPAdded(
        address indexed user,
        uint256 indexed eventId
    );

    event RSVPRemoved(
        address indexed user,
        uint256 indexed eventId
    );

    function rsvp(uint256 eventId) external {
        require(
            !attending[msg.sender][eventId],
            "Already registered"
        );

        attending[msg.sender][eventId] = true;
        attendeeCount[eventId]++;

        emit RSVPAdded(msg.sender, eventId);
    }

    function cancelRSVP(uint256 eventId) external {
        require(
            attending[msg.sender][eventId],
            "No RSVP found"
        );

        attending[msg.sender][eventId] = false;
        attendeeCount[eventId]--;

        emit RSVPRemoved(msg.sender, eventId);
    }

    function isAttending(
        address user,
        uint256 eventId
    ) external view returns (bool) {
        return attending[user][eventId];
    }

    function getAttendeeCount(
        uint256 eventId
    ) external view returns (uint256) {
        return attendeeCount[eventId];
    }
}
