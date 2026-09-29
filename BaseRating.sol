// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseRating {

    struct RatingData {
        uint8 rating;
        bool exists;
    }

    mapping(address => mapping(uint256 => RatingData)) public ratings;

    mapping(uint256 => uint256) public totalRatings;
    mapping(uint256 => uint256) public totalScore;

    event Rated(
        address indexed user,
        uint256 indexed itemId,
        uint8 rating
    );

    function rate(
        uint256 itemId,
        uint8 rating
    ) external {
        require(rating >= 1 && rating <= 5, "Rating must be 1-5");

        RatingData storage previous = ratings[msg.sender][itemId];

        if (previous.exists) {
            totalScore[itemId] -= previous.rating;
        } else {
            totalRatings[itemId]++;
        }

        previous.rating = rating;
        previous.exists = true;

        totalScore[itemId] += rating;

        emit Rated(msg.sender, itemId, rating);
    }

    function getAverageRating(
        uint256 itemId
    ) external view returns (uint256) {
        if (totalRatings[itemId] == 0) {
            return 0;
        }

        return totalScore[itemId] / totalRatings[itemId];
    }

    function getRating(
        address user,
        uint256 itemId
    ) external view returns (uint8) {
        return ratings[user][itemId].rating;
    }
}
