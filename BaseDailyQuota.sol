// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDailyQuota {

    uint256 public constant MAX_DAILY_UNITS = 100;

    mapping(address => uint256) private usageDay;
    mapping(address => uint256) private usedUnits;

    event UnitsConsumed(
        address indexed user,
        uint256 units,
        uint256 totalUsed,
        uint256 dayIndex
    );

    function consume(uint256 units) external {
        require(units > 0, "Zero units");

        require(
            units <= MAX_DAILY_UNITS,
            "Units exceed daily limit"
        );

        uint256 today = block.timestamp / 1 days;

        if (usageDay[msg.sender] != today) {
            usageDay[msg.sender] = today;
            usedUnits[msg.sender] = 0;
        }

        require(
            usedUnits[msg.sender] <= MAX_DAILY_UNITS - units,
            "Daily quota exceeded"
        );

        usedUnits[msg.sender] += units;

        emit UnitsConsumed(
            msg.sender,
            units,
            usedUnits[msg.sender],
            today
        );
    }

    function getUsage(
        address user
    )
        external
        view
        returns (
            uint256 used,
            uint256 remaining,
            uint256 dayIndex
        )
    {
        uint256 today = block.timestamp / 1 days;

        if (usageDay[user] != today) {
            return (0, MAX_DAILY_UNITS, today);
        }

        used = usedUnits[user];
        remaining = MAX_DAILY_UNITS - used;
        dayIndex = today;
    }

    function canConsume(
        address user,
        uint256 units
    ) external view returns (bool) {
        if (units == 0 || units > MAX_DAILY_UNITS) {
            return false;
        }

        uint256 today = block.timestamp / 1 days;

        uint256 currentUsage = usageDay[user] == today
            ? usedUnits[user]
            : 0;

        return currentUsage <= MAX_DAILY_UNITS - units;
    }
}
