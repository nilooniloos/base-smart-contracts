// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseBadge {
    mapping(address => mapping(uint256 => bool)) public hasBadge;

    uint256 public totalBadges;

    function claimBadge(uint256 badgeId) external {
        require(badgeId > 0, "Invalid badge");
        require(!hasBadge[msg.sender][badgeId], "Badge already claimed");

        hasBadge[msg.sender][badgeId] = true;
        totalBadges++;
    }

    function checkBadge(
        address user,
        uint256 badgeId
    ) external view returns (bool) {
        return hasBadge[user][badgeId];
    }
}
