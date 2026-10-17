// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseVestingCalculator {

    struct Schedule {
        address creator;
        address beneficiary;
        uint256 totalUnits;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 duration;
        uint256 createdAt;
    }

    mapping(uint256 => Schedule) private schedules;

    uint256 public scheduleCount;

    event ScheduleCreated(
        uint256 indexed scheduleId,
        address indexed creator,
        address indexed beneficiary,
        uint256 totalUnits,
        uint256 startTime,
        uint256 duration
    );

    function createSchedule(
        address beneficiary,
        uint256 totalUnits,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 duration
    ) external returns (uint256) {
        require(beneficiary != address(0), "Invalid beneficiary");
        require(totalUnits > 0, "Invalid units");

        require(
            totalUnits <= type(uint128).max,
            "Too many units"
        );

        require(duration > 0, "Invalid duration");

        require(
            duration <= 100 * 365 days,
            "Duration too long"
        );

        require(
            cliffDuration <= duration,
            "Cliff exceeds duration"
        );

        require(
            startTime <= type(uint256).max - duration,
            "Invalid start time"
        );

        uint256 id = scheduleCount;

        schedules[id] = Schedule({
            creator: msg.sender,
            beneficiary: beneficiary,
            totalUnits: totalUnits,
            startTime: startTime,
            cliffDuration: cliffDuration,
            duration: duration,
            createdAt: block.timestamp
        });

        scheduleCount++;

        emit ScheduleCreated(
            id,
            msg.sender,
            beneficiary,
            totalUnits,
            startTime,
            duration
        );

        return id;
    }

    function vestedUnits(
        uint256 scheduleId
    ) public view returns (uint256) {
        require(scheduleId < scheduleCount, "Invalid schedule");

        Schedule memory schedule = schedules[scheduleId];

        if (
            block.timestamp <
            schedule.startTime + schedule.cliffDuration
        ) {
            return 0;
        }

        if (
            block.timestamp >=
            schedule.startTime + schedule.duration
        ) {
            return schedule.totalUnits;
        }

        uint256 elapsed = block.timestamp - schedule.startTime;

        return (schedule.totalUnits * elapsed) / schedule.duration;
    }

    function unvestedUnits(
        uint256 scheduleId
    ) external view returns (uint256) {
        require(scheduleId < scheduleCount, "Invalid schedule");

        Schedule memory schedule = schedules[scheduleId];

        return schedule.totalUnits - vestedUnits(scheduleId);
    }

    function getSchedule(
        uint256 scheduleId
    )
        external
        view
        returns (
            address creator,
            address beneficiary,
            uint256 totalUnits,
            uint256 startTime,
            uint256 cliffDuration,
            uint256 duration,
            uint256 createdAt
        )
    {
        require(scheduleId < scheduleCount, "Invalid schedule");

        Schedule memory schedule = schedules[scheduleId];

        return (
            schedule.creator,
            schedule.beneficiary,
            schedule.totalUnits,
            schedule.startTime,
            schedule.cliffDuration,
            schedule.duration,
            schedule.createdAt
        );
    }
}
