// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseTimedMessage {

    struct Message {
        string text;
        uint256 unlockTime;
        bool exists;
    }

    mapping(address => Message[]) public messages;

    event MessageCreated(
        address indexed user,
        uint256 indexed messageId,
        uint256 unlockTime
    );

    function createMessage(
        string calldata text,
        uint256 unlockTime
    ) external {
        require(
            bytes(text).length > 0,
            "Empty message"
        );

        require(
            unlockTime > block.timestamp,
            "Time must be in future"
        );

        messages[msg.sender].push(
            Message({
                text: text,
                unlockTime: unlockTime,
                exists: true
            })
        );

        emit MessageCreated(
            msg.sender,
            messages[msg.sender].length - 1,
            unlockTime
        );
    }

    function getMessage(
        address user,
        uint256 messageId
    )
        external
        view
        returns (
            string memory text,
            uint256 unlockTime,
            bool unlocked
        )
    {
        require(
            messageId < messages[user].length,
            "Invalid message"
        );

        Message memory m = messages[user][messageId];

        require(
            block.timestamp >= m.unlockTime,
            "Message still locked"
        );

        return (
            m.text,
            m.unlockTime,
            true
        );
    }

    function getMessageCount(
        address user
    ) external view returns (uint256) {
        return messages[user].length;
    }

    function isUnlocked(
        address user,
        uint256 messageId
    ) external view returns (bool) {
        require(
            messageId < messages[user].length,
            "Invalid message"
        );

        return block.timestamp >= messages[user][messageId].unlockTime;
    }
}
