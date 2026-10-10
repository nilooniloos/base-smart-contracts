// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseTournament {

    struct Tournament {
        address organizer;
        string title;
        uint256 registrationDeadline;
        uint256 maxParticipants;
        uint256 createdAt;
        address winner;
        bool completed;
        bool cancelled;
    }

    mapping(uint256 => Tournament) public tournaments;

    mapping(uint256 => mapping(address => bool))
        public registered;

    mapping(uint256 => address[]) private participants;

    uint256 public tournamentCount;

    event TournamentCreated(
        uint256 indexed tournamentId,
        address indexed organizer,
        string title
    );

    event ParticipantJoined(
        uint256 indexed tournamentId,
        address indexed participant
    );

    event TournamentFinalized(
        uint256 indexed tournamentId,
        address indexed winner
    );

    event TournamentCancelled(
        uint256 indexed tournamentId
    );

    function createTournament(
        string calldata title,
        uint256 registrationDeadline,
        uint256 maxParticipants
    ) external {
        require(bytes(title).length > 0, "Empty title");

        require(
            registrationDeadline > block.timestamp,
            "Deadline must be future"
        );

        require(
            maxParticipants >= 2 && maxParticipants <= 500,
            "Invalid participant limit"
        );

        uint256 id = tournamentCount;

        tournaments[id] = Tournament({
            organizer: msg.sender,
            title: title,
            registrationDeadline: registrationDeadline,
            maxParticipants: maxParticipants,
            createdAt: block.timestamp,
            winner: address(0),
            completed: false,
            cancelled: false
        });

        tournamentCount++;

        emit TournamentCreated(id, msg.sender, title);
    }

    function joinTournament(uint256 tournamentId) external {
        require(
            tournamentId < tournamentCount,
            "Invalid tournament"
        );

        Tournament storage tournament =
            tournaments[tournamentId];

        require(!tournament.cancelled, "Tournament cancelled");
        require(!tournament.completed, "Tournament completed");

        require(
            block.timestamp < tournament.registrationDeadline,
            "Registration closed"
        );

        require(
            !registered[tournamentId][msg.sender],
            "Already registered"
        );

        require(
            participants[tournamentId].length <
                tournament.maxParticipants,
            "Tournament full"
        );

        registered[tournamentId][msg.sender] = true;
        participants[tournamentId].push(msg.sender);

        emit ParticipantJoined(tournamentId, msg.sender);
    }

    function finalizeTournament(
        uint256 tournamentId,
        address winner
    ) external {
        require(
            tournamentId < tournamentCount,
            "Invalid tournament"
        );

        Tournament storage tournament =
            tournaments[tournamentId];

        require(
            tournament.organizer == msg.sender,
            "Not organizer"
        );

        require(!tournament.cancelled, "Tournament cancelled");
        require(!tournament.completed, "Already completed");

        require(
            block.timestamp >= tournament.registrationDeadline,
            "Registration still open"
        );

        require(
            registered[tournamentId][winner],
            "Winner not registered"
        );

        tournament.winner = winner;
        tournament.completed = true;

        emit TournamentFinalized(tournamentId, winner);
    }

    function cancelTournament(uint256 tournamentId) external {
        require(
            tournamentId < tournamentCount,
            "Invalid tournament"
        );

        Tournament storage tournament =
            tournaments[tournamentId];

        require(
            tournament.organizer == msg.sender,
            "Not organizer"
        );

        require(!tournament.completed, "Already completed");
        require(!tournament.cancelled, "Already cancelled");

        tournament.cancelled = true;

        emit TournamentCancelled(tournamentId);
    }

    function getParticipantCount(
        uint256 tournamentId
    ) external view returns (uint256) {
        require(
            tournamentId < tournamentCount,
            "Invalid tournament"
        );

        return participants[tournamentId].length;
    }

    function getParticipant(
        uint256 tournamentId,
        uint256 index
    ) external view returns (address) {
        require(
            tournamentId < tournamentCount,
            "Invalid tournament"
        );

        require(
            index < participants[tournamentId].length,
            "Invalid index"
        );

        return participants[tournamentId][index];
    }
}
