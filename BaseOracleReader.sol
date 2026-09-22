// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IChainlinkFeed {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
}

contract BaseOracleReader {
    function getPrice(
        address feed
    )
        external
        view
        returns (
            int256 price,
            uint256 updatedAt,
            uint8 decimals
        )
    {
        (
            ,
            price,
            ,
            updatedAt,
            
        ) = IChainlinkFeed(feed).latestRoundData();

        decimals = IChainlinkFeed(feed).decimals();
    }

    function getDescription(
        address feed
    ) external view returns (string memory) {
        return IChainlinkFeed(feed).description();
    }
}
