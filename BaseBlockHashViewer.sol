// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseBlockHashViewer {
    function getBlockHash(
        uint256 blockNumber
    ) external view returns (bytes32) {
        return blockhash(blockNumber);
    }

    function isAvailable(
        uint256 blockNumber
    ) external view returns (bool) {
        if (blockNumber >= block.number) {
            return false;
        }

        return block.number - blockNumber <= 256;
    }

    function currentBlock()
        external
        view
        returns (uint256)
    {
        return block.number;
    }
}
