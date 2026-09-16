// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseRandomSeed {
    function generate(uint256 salt) external view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.prevrandao,
                    block.timestamp,
                    msg.sender,
                    salt
                )
            )
        );
    }

    function generateRange(
        uint256 salt,
        uint256 maximum
    ) external view returns (uint256) {
        require(maximum > 0, "Invalid maximum");

        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.prevrandao,
                    block.timestamp,
                    msg.sender,
                    salt
                )
            )
        );

        return seed % maximum;
    }
}
