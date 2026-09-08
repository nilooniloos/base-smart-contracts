// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseContactCard {
    struct Profile {
        string name;
        string website;
        string bio;
    }

    mapping(address => Profile) public profiles;

    function setProfile(
        string calldata name,
        string calldata website,
        string calldata bio
    ) external {
        profiles[msg.sender] = Profile(
            name,
            website,
            bio
        );
    }

    function getProfile(address user)
        external
        view
        returns (
            string memory,
            string memory,
            string memory
        )
    {
        Profile memory p = profiles[user];

        return (
            p.name,
            p.website,
            p.bio
        );
    }
}

