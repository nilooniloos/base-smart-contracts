// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseReaction {

    mapping(uint256 => mapping(address => uint8)) public userReaction;
    mapping(uint256 => mapping(uint8 => uint256)) public reactionCount;

    event ReactionSet(
        address indexed user,
        uint256 indexed itemId,
        uint8 reaction
    );

    event ReactionRemoved(
        address indexed user,
        uint256 indexed itemId,
        uint8 reaction
    );

    function setReaction(
        uint256 itemId,
        uint8 reaction
    ) external {
        require(
            reaction >= 1 && reaction <= 5,
            "Reaction must be 1-5"
        );

        uint8 previous = userReaction[itemId][msg.sender];

        if (previous != 0) {
            reactionCount[itemId][previous]--;
        }

        userReaction[itemId][msg.sender] = reaction;
        reactionCount[itemId][reaction]++;

        emit ReactionSet(
            msg.sender,
            itemId,
            reaction
        );
    }

    function removeReaction(
        uint256 itemId
    ) external {
        uint8 previous = userReaction[itemId][msg.sender];

        require(
            previous != 0,
            "No reaction"
        );

        reactionCount[itemId][previous]--;
        delete userReaction[itemId][msg.sender];

        emit ReactionRemoved(
            msg.sender,
            itemId,
            previous
        );
    }

    function getMyReaction(
        uint256 itemId
    ) external view returns (uint8) {
        return userReaction[itemId][msg.sender];
    }

    function getReactionCount(
        uint256 itemId,
        uint8 reaction
    ) external view returns (uint256) {
        require(
            reaction >= 1 && reaction <= 5,
            "Reaction must be 1-5"
        );

        return reactionCount[itemId][reaction];
    }
}
