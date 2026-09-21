// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseSnapshot {
    struct Checkpoint {
        uint256 blockNumber;
        uint256 value;
    }

    mapping(address => Checkpoint[]) private checkpoints;

    function record(uint256 value) external {
        checkpoints[msg.sender].push(
            Checkpoint({
                blockNumber: block.number,
                value: value
            })
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
        uint256 index
    )
        external
        view
        returns (uint256 blockNumber, uint256 value)
    {
        Checkpoint memory item = checkpoints[user][index];
        return (item.blockNumber, item.value);
    }
       Checkpoint memory item = checkpoints[user][index];
        return (item.blockNumber, item.value);
    }
}
