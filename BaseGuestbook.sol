// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseGuestbook {

    struct Entry {
        address user;
        string message;
        uint256 timestamp;
    }

    Entry[] public entries;

    event NewEntry(
        uint256 indexed id,
        address indexed user,
        string message
    );

    function signGuestbook(string calldata message) external {
        require(bytes(message).length > 0, "Empty message");

        entries.push(
            Entry({
                user: msg.sender,
                message: message,
                timestamp: block.timestamp
            })
        );

        emit NewEntry(
            entries.length - 1,
            msg.sender,
            message
        );
    }

    function totalEntries() external view returns (uint256) {
        return entries.length;
    }

    function getEntry(uint256 id)
        external
        view
        returns (
            address user,
            string memory message,
            uint256 timestamp
        )
    {
        require(id < entries.length, "Invalid ID");

        Entry memory entry = entries[id];

        return (
            entry.user,
            entry.message,
            entry.timestamp
        );
    }
}
