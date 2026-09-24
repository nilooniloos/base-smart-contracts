// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BasePoll {

    string public optionA;
    string public optionB;

    uint256 public votesA;
    uint256 public votesB;

    mapping(address => bool) public hasVoted;

    event Voted(
        address indexed voter,
        uint8 option
    );

    constructor(
        string memory _optionA,
        string memory _optionB
    ) {
        optionA = _optionA;
        optionB = _optionB;
    }

    function voteA() external {
        require(!hasVoted[msg.sender], "Already voted");

        hasVoted[msg.sender] = true;
        votesA++;

        emit Voted(msg.sender, 1);
    }

    function voteB() external {
        require(!hasVoted[msg.sender], "Already voted");

        hasVoted[msg.sender] = true;
        votesB++;

        emit Voted(msg.sender, 2);
    }

    function getResults()
        external
        view
        returns (uint256, uint256)
    {
        return (votesA, votesB);
    }
}
