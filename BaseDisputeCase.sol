// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDisputeCase {

    enum CaseStatus {
        Open,
        Resolved,
        Closed
    }

    struct DisputeCase {
        uint256 id;
        address claimant;
        address respondent;
        string subject;
        CaseStatus status;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Evidence {
        bytes32 evidenceHash;
        address submittedBy;
        uint256 submittedAt;
    }

    DisputeCase[] public cases;

    mapping(uint256 => Evidence[]) public evidenceList;

    event CaseCreated(
        uint256 indexed caseId,
        address indexed claimant,
        address indexed respondent,
        string subject
    );

    event EvidenceAdded(
        uint256 indexed caseId,
        bytes32 indexed evidenceHash,
        address indexed submittedBy
    );

    event CaseResolved(
        uint256 indexed caseId,
        address indexed actor
    );

    event CaseClosed(
        uint256 indexed caseId,
        address indexed actor
    );

    function createCase(
        address respondent,
        string calldata subject
    ) external {
        require(
            respondent != address(0),
            "Invalid respondent"
        );

        require(
            respondent != msg.sender,
            "Invalid respondent"
        );

        require(
            bytes(subject).length > 0,
            "Empty subject"
        );

        uint256 caseId = cases.length;

        cases.push(
            DisputeCase({
                id: caseId,
                claimant: msg.sender,
                respondent: respondent,
                subject: subject,
                status: CaseStatus.Open,
                createdAt: block.timestamp,
                updatedAt: block.timestamp
            })
        );

        emit CaseCreated(
            caseId,
            msg.sender,
            respondent,
            subject
        );
    }

    function addEvidence(
        uint256 caseId,
        bytes32 evidenceHash
    ) external {
        require(
            caseId < cases.length,
            "Invalid case"
        );

        DisputeCase storage dispute = cases[caseId];

        require(
            msg.sender == dispute.claimant ||
            msg.sender == dispute.respondent,
            "Not a case party"
        );

        require(
            dispute.status == CaseStatus.Open,
            "Case not open"
        );

        require(
            evidenceHash != bytes32(0),
            "Invalid evidence hash"
        );

        evidenceList[caseId].push(
            Evidence({
                evidenceHash: evidenceHash,
                submittedBy: msg.sender,
                submittedAt: block.timestamp
            })
        );

        dispute.updatedAt = block.timestamp;

        emit EvidenceAdded(
            caseId,
            evidenceHash,
            msg.sender
        );
    }

    function resolveCase(
        uint256 caseId
    ) external {
        require(
            caseId < cases.length,
            "Invalid case"
        );

        DisputeCase storage dispute = cases[caseId];

        require(
            msg.sender == dispute.claimant ||
            msg.sender == dispute.respondent,
            "Not a case party"
        );

        require(
            dispute.status == CaseStatus.Open,
            "Case not open"
        );

        dispute.status = CaseStatus.Resolved;
        dispute.updatedAt = block.timestamp;

        emit CaseResolved(
            caseId,
            msg.sender
        );
    }

    function closeCase(
        uint256 caseId
    ) external {
        require(
            caseId < cases.length,
            "Invalid case"
        );

        DisputeCase storage dispute = cases[caseId];

        require(
            msg.sender == dispute.claimant ||
            msg.sender == dispute.respondent,
            "Not a case party"
        );

        require(
            dispute.status == CaseStatus.Resolved,
            "Case not resolved"
        );

        dispute.status = CaseStatus.Closed;
        dispute.updatedAt = block.timestamp;

        emit CaseClosed(
            caseId,
            msg.sender
        );
    }

    function getCase(
        uint256 caseId
    )
        external
        view
        returns (
            uint256 id,
            address claimant,
            address respondent,
            string memory subject,
            CaseStatus status,
            uint256 createdAt,
            uint256 updatedAt
        )
    {
        require(
            caseId < cases.length,
            "Invalid case"
        );

        DisputeCase memory dispute = cases[caseId];

        return (
            dispute.id,
            dispute.claimant,
            dispute.respondent,
            dispute.subject,
            dispute.status,
            dispute.createdAt,
            dispute.updatedAt
        );
    }

    function getEvidenceCount(
        uint256 caseId
    ) external view returns (uint256) {
        require(
            caseId < cases.length,
            "Invalid case"
        );

        return evidenceList[caseId].length;
    }
}
