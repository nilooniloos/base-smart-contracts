// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseUsername {
    mapping(address => string) public username;
    mapping(string => address) public ownerOf;

    function setUsername(string calldata name) external {
        require(bytes(name).length >= 3, "Name too short");
        require(ownerOf[name] == address(0), "Name already taken");

        username[msg.sender] = name;
        ownerOf[name] = msg.sender;
    }

    function getUsername(address user) external view returns (string memory) {
        return username[user];
    }
}
}
