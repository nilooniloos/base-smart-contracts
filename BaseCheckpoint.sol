// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCheckpoint {

    struct Checkpoint {
        uint256 value;
        string note;
        uint256 timestamp;
    }

    mapping(address => Checkpoint[]) public checkpoints;

    event CheckpointCreated(
        address indexed user,
        uint256 indexed checkpointId,
        uint256 value,
        string note,
        uint256 timestamp
    );

    function createCheckpoint(
        uint256 value,
        string calldata note
    ) external {
        require(bytes(note).length > 0, "Empty note");

        uint256 checkpointId = checkpoints[msg.sender].length;

        checkpoints[msg.sender].push(
            Checkpoint({
                value: value,
                note: note,
                timestamp: block.timestamp
            })
        );

        emit CheckpointCreated(
            msg.sender,
            checkpointId,
            value,
            note,
            block.timestamp
        );
    }

    function getCheckpointCount(address user)
        external
        view
        returns (uint256)
    {
        return checkpoints[user].length;
    }

    function getCheckpoint(
        address user,
        uint256 checkpointId
    )
        external
        view
        returns (
            uint256 value,
            string memory note,
            uint256 timestamp
        )
    {
        require(
            checkpointId < checkpoints[user].length,
            "Invalid checkpoint"
        );

        Checkpoint memory cp = checkpoints[user][checkpointId];

        return (
            cp.value,
            cp.note,
            cp.timestamp
        );
    }

    function getLatestCheckpoint(address user)
        external
        view
        returns (
            uint256 value,
            string memory note,
            uint256 timestamp
        )
    {
        require(
            checkpoints[user].length > 0,
            "No checkpoints"
        );

        Checkpoint memory cp =
            checkpoints[user][checkpoints[user].length - 1];

        return (
            cp.value,
            cp.note,
            cp.timestamp
        );
    }
}
