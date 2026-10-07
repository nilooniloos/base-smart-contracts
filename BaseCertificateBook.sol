// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCertificateBook {

    struct Certificate {
        address issuer;
        address recipient;
        string title;
        bytes32 documentHash;
        uint256 issuedAt;
        bool revoked;
    }

    mapping(uint256 => Certificate) public certificates;

    uint256 public totalCertificates;

    event CertificateIssued(
        uint256 indexed certificateId,
        address indexed issuer,
        address indexed recipient,
        string title,
        bytes32 documentHash
    );

    event CertificateRevoked(
        uint256 indexed certificateId,
        address indexed issuer
    );

    function issueCertificate(
        address recipient,
        string calldata title,
        bytes32 documentHash
    ) external {
        require(
            recipient != address(0),
            "Invalid recipient"
        );

        require(
            bytes(title).length > 0,
            "Empty title"
        );

        require(
            documentHash != bytes32(0),
            "Invalid document hash"
        );

        uint256 id = totalCertificates;

        certificates[id] = Certificate({
            issuer: msg.sender,
            recipient: recipient,
            title: title,
            documentHash: documentHash,
            issuedAt: block.timestamp,
            revoked: false
        });

        totalCertificates++;

        emit CertificateIssued(
            id,
            msg.sender,
            recipient,
            title,
            documentHash
        );
    }

    function revokeCertificate(
        uint256 certificateId
    ) external {
        require(
            certificateId < totalCertificates,
            "Invalid certificate"
        );

        Certificate storage certificate =
            certificates[certificateId];

        require(
            certificate.issuer == msg.sender,
            "Not issuer"
        );

        require(
            !certificate.revoked,
            "Already revoked"
        );

        certificate.revoked = true;

        emit CertificateRevoked(
            certificateId,
            msg.sender
        );
    }

    function isValid(
        uint256 certificateId
    ) external view returns (bool) {
        require(
            certificateId < totalCertificates,
            "Invalid certificate"
        );

        return !certificates[certificateId].revoked;
    }

    function getCertificate(
        uint256 certificateId
    )
        external
        view
        returns (
            address issuer,
            address recipient,
            string memory title,
            bytes32 documentHash,
            uint256 issuedAt,
            bool revoked
        )
    {
        require(
            certificateId < totalCertificates,
            "Invalid certificate"
        );

        Certificate memory certificate =
            certificates[certificateId];

        return (
            certificate.issuer,
            certificate.recipient,
            certificate.title,
            certificate.documentHash,
            certificate.issuedAt,
            certificate.revoked
        );
    }
}
