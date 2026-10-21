// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseResearchReviewHub {

    enum PaperStatus {
        Submitted,
        UnderReview,
        Accepted,
        Rejected,
        Withdrawn
    }

    struct Paper {
        address author;
        string title;
        bytes32 manuscriptHash;
        uint256 submittedAt;
        PaperStatus status;
    }

    struct Review {
        address reviewer;
        uint8 score;
        bytes32 reviewHash;
        uint256 submittedAt;
    }

    mapping(uint256 => Paper) private papers;
    mapping(uint256 => Review[]) private reviews;

    mapping(uint256 => mapping(address => bool))
        public reviewerAssigned;

    mapping(uint256 => mapping(address => bool))
        public hasReviewed;

    uint256 public paperCount;

    event PaperSubmitted(
        uint256 indexed paperId,
        address indexed author,
        bytes32 manuscriptHash
    );

    event ReviewerAssigned(
        uint256 indexed paperId,
        address indexed reviewer
    );

    event ReviewSubmitted(
        uint256 indexed paperId,
        address indexed reviewer,
        uint8 score,
        bytes32 reviewHash
    );

    event PaperFinalized(
        uint256 indexed paperId,
        PaperStatus status
    );

    function submitPaper(
        string calldata title,
        bytes32 manuscriptHash
    ) external returns (uint256) {
        require(bytes(title).length > 0, "Empty title");
        require(manuscriptHash != bytes32(0), "Invalid hash");

        uint256 id = paperCount;

        papers[id] = Paper({
            author: msg.sender,
            title: title,
            manuscriptHash: manuscriptHash,
            submittedAt: block.timestamp,
            status: PaperStatus.Submitted
        });

        paperCount++;

        emit PaperSubmitted(id, msg.sender, manuscriptHash);

        return id;
    }

    function assignReviewer(
        uint256 paperId,
        address reviewer
    ) external {
        require(paperId < paperCount, "Invalid paper");

        Paper storage paper = papers[paperId];

        require(paper.author == msg.sender, "Not author");
        require(reviewer != address(0), "Invalid reviewer");
        require(reviewer != paper.author, "Author cannot review");

        require(
            paper.status == PaperStatus.Submitted ||
            paper.status == PaperStatus.UnderReview,
            "Review unavailable"
        );

        require(
            !reviewerAssigned[paperId][reviewer],
            "Reviewer already assigned"
        );

        reviewerAssigned[paperId][reviewer] = true;
        paper.status = PaperStatus.UnderReview;

        emit ReviewerAssigned(paperId, reviewer);
    }

    function submitReview(
        uint256 paperId,
        uint8 score,
        bytes32 reviewHash
    ) external {
        require(paperId < paperCount, "Invalid paper");

        Paper storage paper = papers[paperId];

        require(
            paper.status == PaperStatus.UnderReview,
            "Not under review"
        );

        require(
            reviewerAssigned[paperId][msg.sender],
            "Not assigned reviewer"
        );

        require(!hasReviewed[paperId][msg.sender], "Already reviewed");
        require(score >= 1 && score <= 5, "Score must be 1-5");
        require(reviewHash != bytes32(0), "Invalid review hash");

        hasReviewed[paperId][msg.sender] = true;

        reviews[paperId].push(
            Review({
                reviewer: msg.sender,
                score: score,
                reviewHash: reviewHash,
                submittedAt: block.timestamp
            })
        );

        emit ReviewSubmitted(
            paperId,
            msg.sender,
            score,
            reviewHash
        );
    }

    function finalizePaper(
        uint256 paperId,
        PaperStatus finalStatus
    ) external {
        require(paperId < paperCount, "Invalid paper");

        Paper storage paper = papers[paperId];

        require(paper.author == msg.sender, "Not author");

        require(
            paper.status == PaperStatus.UnderReview,
            "Not under review"
        );

        require(reviews[paperId].length > 0, "No reviews");

        require(
            finalStatus == PaperStatus.Accepted ||
            finalStatus == PaperStatus.Rejected,
            "Invalid final status"
        );

        paper.status = finalStatus;

        emit PaperFinalized(paperId, finalStatus);
    }

    function getReviewCount(
        uint256 paperId
    ) external view returns (uint256) {
        require(paperId < paperCount, "Invalid paper");
        return reviews[paperId].length;
    }

    function getReview(
        uint256 paperId,
        uint256 reviewId
    )
        external
        view
        returns (
            address reviewer,
            uint8 score,
            bytes32 reviewHash,
            uint256 submittedAt
        )
    {
        require(paperId < paperCount, "Invalid paper");
        require(reviewId < reviews[paperId].length, "Invalid review");

        Review memory review = reviews[paperId][reviewId];

        return (
            review.reviewer,
            review.score,
            review.reviewHash,
            review.submittedAt
        );
    }

    function getPaper(
        uint256 paperId
    )
        external
        view
        returns (
            address author,
            string memory title,
            bytes32 manuscriptHash,
            uint256 submittedAt,
            PaperStatus status
        )
    {
        require(paperId < paperCount, "Invalid paper");

        Paper memory paper = papers[paperId];

        return (
            paper.author,
            paper.title,
            paper.manuscriptHash,
            paper.submittedAt,
            paper.status
        );
    }
}
