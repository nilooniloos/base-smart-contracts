// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseApprovalFlow {

    struct Request {
        uint256 id;
        address creator;
        string description;
        uint8 requiredApprovals;
        uint8 approvalCount;
        bool executed;
        bool cancelled;
        uint256 createdAt;
    }

    mapping(uint256 => Request) public requests;
    mapping(uint256 => mapping(address => bool)) public approved;

    uint256 public totalRequests;

    event RequestCreated(
        uint256 indexed id,
        address indexed creator,
        string description,
        uint8 requiredApprovals
    );

    event ApprovalAdded(
        uint256 indexed id,
        address indexed approver,
        uint8 approvalCount
    );

    event RequestExecuted(
        uint256 indexed id
    );

    event RequestCancelled(
        uint256 indexed id
    );

    function createRequest(
        string calldata description,
        uint8 requiredApprovals
    ) external {
        require(
            bytes(description).length > 0,
            "Empty description"
        );

        require(
            requiredApprovals > 0,
            "Invalid approval count"
        );

        uint256 id = totalRequests;

        requests[id] = Request({
            id: id,
            creator: msg.sender,
            description: description,
            requiredApprovals: requiredApprovals,
            approvalCount: 0,
            executed: false,
            cancelled: false,
            createdAt: block.timestamp
        });

        totalRequests++;

        emit RequestCreated(
            id,
            msg.sender,
            description,
            requiredApprovals
        );
    }

    function approve(uint256 id) external {
        require(id < totalRequests, "Invalid request");

        Request storage request = requests[id];

        require(!request.executed, "Already executed");
        require(!request.cancelled, "Request cancelled");
        require(!approved[id][msg.sender], "Already approved");

        approved[id][msg.sender] = true;
        request.approvalCount++;

        emit ApprovalAdded(
            id,
            msg.sender,
            request.approvalCount
        );

        if (
            request.approvalCount >=
            request.requiredApprovals
        ) {
            request.executed = true;

            emit RequestExecuted(id);
        }
    }

    function cancelRequest(uint256 id) external {
        require(id < totalRequests, "Invalid request");

        Request storage request = requests[id];

        require(
            msg.sender == request.creator,
            "Not creator"
        );

        require(!request.executed, "Already executed");
        require(!request.cancelled, "Already cancelled");

        request.cancelled = true;

        emit RequestCancelled(id);
    }

    function hasApproved(
        uint256 id,
        address user
    ) external view returns (bool) {
        return approved[id][user];
    }

    function getRequest(
        uint256 id
    )
        external
        view
        returns (
            uint256 requestId,
            address creator,
            string memory description,
            uint8 requiredApprovals,
            uint8 approvalCount,
            bool executed,
            bool cancelled,
            uint256 createdAt
        )
    {
        require(id < totalRequests, "Invalid request");

        Request memory request = requests[id];

        return (
            request.id,
            request.creator,
            request.description,
            request.requiredApprovals,
            request.approvalCount,
            request.executed,
            request.cancelled,
            request.createdAt
        );
    }
}
