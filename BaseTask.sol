// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseTask {

    struct Task {
        string description;
        bool completed;
        uint256 createdAt;
        uint256 completedAt;
    }

    mapping(address => Task[]) public tasks;

    event TaskCreated(
        address indexed user,
        uint256 indexed taskId,
        string description
    );

    event TaskCompleted(
        address indexed user,
        uint256 indexed taskId
    );

    function createTask(
        string calldata description
    ) external {
        require(
            bytes(description).length > 0,
            "Empty description"
        );

        tasks[msg.sender].push(
            Task({
                description: description,
                completed: false,
                createdAt: block.timestamp,
                completedAt: 0
            })
        );

        emit TaskCreated(
            msg.sender,
            tasks[msg.sender].length - 1,
            description
        );
    }

    function completeTask(uint256 taskId) external {
        require(
            taskId < tasks[msg.sender].length,
            "Invalid task"
        );

        require(
            !tasks[msg.sender][taskId].completed,
            "Already completed"
        );

        tasks[msg.sender][taskId].completed = true;
        tasks[msg.sender][taskId].completedAt = block.timestamp;

        emit TaskCompleted(
            msg.sender,
            taskId
        );
    }

    function getTaskCount(address user)
        external
        view
        returns (uint256)
    {
        return tasks[user].length;
    }
}
