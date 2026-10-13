// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMaintenanceLog {

    struct Asset {
        address owner;
        string label;
        bytes32 serialHash;
        uint256 registeredAt;
        uint256 lastMeterReading;
        uint256 maintenanceCount;
        bool retired;
        bool exists;
    }

    struct MaintenanceRecord {
        string category;
        uint256 meterReading;
        uint256 timestamp;
        bytes32 reportHash;
    }

    mapping(uint256 => Asset) private assets;

    mapping(uint256 => MaintenanceRecord[])
        private maintenanceRecords;

    mapping(bytes32 => bool) public serialHashUsed;

    uint256 public assetCount;

    event AssetRegistered(
        uint256 indexed assetId,
        address indexed owner,
        string label,
        bytes32 serialHash
    );

    event MaintenanceRecorded(
        uint256 indexed assetId,
        uint256 indexed recordId,
        uint256 meterReading,
        bytes32 reportHash
    );

    event AssetRetired(uint256 indexed assetId);

    function registerAsset(
        string calldata label,
        bytes32 serialHash
    ) external returns (uint256) {
        require(bytes(label).length > 0, "Empty label");
        require(serialHash != bytes32(0), "Invalid serial hash");
        require(!serialHashUsed[serialHash], "Serial already registered");

        uint256 id = assetCount;

        assets[id] = Asset({
            owner: msg.sender,
            label: label,
            serialHash: serialHash,
            registeredAt: block.timestamp,
            lastMeterReading: 0,
            maintenanceCount: 0,
            retired: false,
            exists: true
        });

        serialHashUsed[serialHash] = true;
        assetCount++;

        emit AssetRegistered(id, msg.sender, label, serialHash);

        return id;
    }

    function recordMaintenance(
        uint256 assetId,
        string calldata category,
        uint256 meterReading,
        bytes32 reportHash
    ) external {
        require(assetId < assetCount, "Invalid asset");

        Asset storage asset = assets[assetId];

        require(asset.owner == msg.sender, "Not asset owner");
        require(!asset.retired, "Asset retired");
        require(bytes(category).length > 0, "Empty category");
        require(reportHash != bytes32(0), "Invalid report hash");

        require(
            meterReading >= asset.lastMeterReading,
            "Meter reading decreased"
        );

        uint256 recordId = maintenanceRecords[assetId].length;

        maintenanceRecords[assetId].push(
            MaintenanceRecord({
                category: category,
                meterReading: meterReading,
                timestamp: block.timestamp,
                reportHash: reportHash
            })
        );

        asset.lastMeterReading = meterReading;
        asset.maintenanceCount++;

        emit MaintenanceRecorded(
            assetId,
            recordId,
            meterReading,
            reportHash
        );
    }

    function retireAsset(uint256 assetId) external {
        require(assetId < assetCount, "Invalid asset");

        Asset storage asset = assets[assetId];

        require(asset.owner == msg.sender, "Not asset owner");
        require(!asset.retired, "Already retired");

        asset.retired = true;

        emit AssetRetired(assetId);
    }

    function getAsset(
        uint256 assetId
    )
        external
        view
        returns (
            address owner,
            string memory label,
            bytes32 serialHash,
            uint256 registeredAt,
            uint256 lastMeterReading,
            uint256 maintenanceCount,
            bool retired
        )
    {
        require(assetId < assetCount, "Invalid asset");

        Asset memory asset = assets[assetId];

        return (
            asset.owner,
            asset.label,
            asset.serialHash,
            asset.registeredAt,
            asset.lastMeterReading,
            asset.maintenanceCount,
            asset.retired
        );
    }

    function getMaintenanceRecord(
        uint256 assetId,
        uint256 recordId
    )
        external
        view
        returns (
            string memory category,
            uint256 meterReading,
            uint256 timestamp,
            bytes32 reportHash
        )
    {
        require(assetId < assetCount, "Invalid asset");

        require(
            recordId < maintenanceRecords[assetId].length,
            "Invalid record"
        );

        MaintenanceRecord memory record =
            maintenanceRecords[assetId][recordId];

        return (
            record.category,
            record.meterReading,
            record.timestamp,
            record.reportHash
        );
    }
}
