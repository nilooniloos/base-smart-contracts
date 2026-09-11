// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseInventory {
    mapping(uint256 => uint256) public stock;

    function addStock(uint256 itemId, uint256 amount) external {
        stock[itemId] += amount;
    }

    function removeStock(uint256 itemId, uint256 amount) external {
        require(stock[itemId] >= amount, "Not enough stock");
        stock[itemId] -= amount;
    }

    function getStock(uint256 itemId)
        external
        view
        returns (uint256)
    {
        return stock[itemId];
    }
}
