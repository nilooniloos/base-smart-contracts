// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseConsent {

    struct Consent {
        bool granted;
        uint256 updatedAt;
    }

    mapping(address => mapping(uint256 => Consent)) public consents;

    event ConsentGranted(
        address indexed user,
        uint256 indexed serviceId,
        uint256 timestamp
    );

    event ConsentRevoked(
        address indexed user,
        uint256 indexed serviceId,
        uint256 timestamp
    );

    function grantConsent(uint256 serviceId) external {
        consents[msg.sender][serviceId] = Consent({
            granted: true,
            updatedAt: block.timestamp
        });

        emit ConsentGranted(
            msg.sender,
            serviceId,
            block.timestamp
        );
    }

    function revokeConsent(uint256 serviceId) external {
        consents[msg.sender][serviceId] = Consent({
            granted: false,
            updatedAt: block.timestamp
        });

        emit ConsentRevoked(
            msg.sender,
            serviceId,
            block.timestamp
        );
    }

    function hasConsent(
        address user,
        uint256 serviceId
    ) external view returns (bool) {
        return consents[user][serviceId].granted;
    }

    function consentTime(
        address user,
        uint256 serviceId
    ) external view returns (uint256) {
        return consents[user][serviceId].updatedAt;
    }
}
