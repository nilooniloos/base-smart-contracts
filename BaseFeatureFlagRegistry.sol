// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseFeatureFlagRegistry {

    struct FeatureFlag {
        string label;
        bool enabled;
        uint256 version;
        uint256 updatedAt;
        bool exists;
    }

    mapping(address => mapping(bytes32 => FeatureFlag))
        private flags;

    event FeatureFlagUpdated(
        address indexed appOwner,
        bytes32 indexed flagKey,
        string label,
        bool enabled,
        uint256 version
    );

    function setFeatureFlag(
        bytes32 flagKey,
        string calldata label,
        bool enabled
    ) external {
        require(flagKey != bytes32(0), "Invalid key");
        require(bytes(label).length > 0, "Empty label");

        FeatureFlag storage f = flags[msg.sender][flagKey];

        if (f.exists) {
            f.version++;
        } else {
            f.exists = true;
            f.version = 1;
        }

        f.label = label;
        f.enabled = enabled;
        f.updatedAt = block.timestamp;

        emit FeatureFlagUpdated(
            msg.sender,
            flagKey,
            label,
            enabled,
            f.version
        );
    }

    function isEnabled(
        address appOwner,
        bytes32 flagKey
    ) external view returns (bool) {
        return flags[appOwner][flagKey].exists &&
            flags[appOwner][flagKey].enabled;
    }

    function getFeatureFlag(
        address appOwner,
        bytes32 flagKey
    )
        external
        view
        returns (
            string memory label,
            bool enabled,
            uint256 version,
            uint256 updatedAt,
            bool exists
        )
    {
        FeatureFlag memory f = flags[appOwner][flagKey];

        return (
            f.label,
            f.enabled,
            f.version,
            f.updatedAt,
            f.exists
        );
    }
}
