// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseEnergyMeter {

    struct Meter {
        address owner;
        string label;
        uint256 lastReading;
        uint256 readingCount;
        uint256 lastRecordedAt;
        bool active;
        bool exists;
    }

    struct Reading {
        uint256 cumulativeValue;
        uint256 timestamp;
        bytes32 evidenceHash;
    }

    mapping(uint256 => Meter) private meters;
    mapping(uint256 => Reading[]) private readings;

    uint256 public meterCount;

    event MeterRegistered(
        uint256 indexed meterId,
        address indexed owner,
        string label
    );

    event ReadingRecorded(
        uint256 indexed meterId,
        uint256 cumulativeValue,
        bytes32 evidenceHash,
        uint256 timestamp
    );

    event MeterStatusChanged(
        uint256 indexed meterId,
        bool active
    );

    function registerMeter(
        string calldata label
    ) external returns (uint256) {
        require(bytes(label).length > 0, "Empty label");

        uint256 id = meterCount;

        meters[id] = Meter({
            owner: msg.sender,
            label: label,
            lastReading: 0,
            readingCount: 0,
            lastRecordedAt: 0,
            active: true,
            exists: true
        });

        meterCount++;

        emit MeterRegistered(id, msg.sender, label);

        return id;
    }

    function recordReading(
        uint256 meterId,
        uint256 cumulativeValue,
        bytes32 evidenceHash
    ) external {
        require(meterId < meterCount, "Invalid meter");

        Meter storage meter = meters[meterId];

        require(meter.owner == msg.sender, "Not meter owner");
        require(meter.active, "Meter inactive");

        require(
            cumulativeValue >= meter.lastReading,
            "Reading cannot decrease"
        );

        readings[meterId].push(
            Reading({
                cumulativeValue: cumulativeValue,
                timestamp: block.timestamp,
                evidenceHash: evidenceHash
            })
        );

        meter.lastReading = cumulativeValue;
        meter.readingCount++;
        meter.lastRecordedAt = block.timestamp;

        emit ReadingRecorded(
            meterId,
            cumulativeValue,
            evidenceHash,
            block.timestamp
        );
    }

    function setMeterActive(
        uint256 meterId,
        bool active
    ) external {
        require(meterId < meterCount, "Invalid meter");
        require(
            meters[meterId].owner == msg.sender,
            "Not meter owner"
        );

        meters[meterId].active = active;

        emit MeterStatusChanged(meterId, active);
    }

    function getMeter(
        uint256 meterId
    )
        external
        view
        returns (
            address owner,
            string memory label,
            uint256 lastReading,
            uint256 readingCount,
            uint256 lastRecordedAt,
            bool active
        )
    {
        require(meterId < meterCount, "Invalid meter");

        Meter memory m = meters[meterId];

        return (
            m.owner,
            m.label,
            m.lastReading,
            m.readingCount,
            m.lastRecordedAt,
            m.active
        );
    }

    function getReading(
        uint256 meterId,
        uint256 index
    )
        external
        view
        returns (
            uint256 cumulativeValue,
            uint256 timestamp,
            bytes32 evidenceHash
        )
    {
        require(meterId < meterCount, "Invalid meter");
        require(index < readings[meterId].length, "Invalid index");

        Reading memory r = readings[meterId][index];

        return (
            r.cumulativeValue,
            r.timestamp,
            r.evidenceHash
        );
    }
}
