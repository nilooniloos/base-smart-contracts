// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseSupplyChainTrace {

    struct Product {
        address currentCustodian;
        bytes32 productHash;
        string description;
        uint256 registeredAt;
        bool exists;
    }

    struct Checkpoint {
        address recordedBy;
        bytes32 locationHash;
        string note;
        uint256 timestamp;
    }

    mapping(uint256 => Product) public products;

    mapping(uint256 => Checkpoint[]) private checkpoints;

    mapping(bytes32 => bool) public productHashUsed;

    uint256 public productCount;

    event ProductRegistered(
        uint256 indexed productId,
        address indexed custodian,
        bytes32 productHash
    );

    event CustodyTransferred(
        uint256 indexed productId,
        address indexed previousCustodian,
        address indexed newCustodian
    );

    event CheckpointAdded(
        uint256 indexed productId,
        address indexed recordedBy,
        bytes32 locationHash,
        string note
    );

    function registerProduct(
        bytes32 productHash,
        string calldata description
    ) external returns (uint256) {
        require(productHash != bytes32(0), "Invalid product hash");
        require(!productHashUsed[productHash], "Hash already registered");
        require(bytes(description).length > 0, "Empty description");

        uint256 id = productCount;

        products[id] = Product({
            currentCustodian: msg.sender,
            productHash: productHash,
            description: description,
            registeredAt: block.timestamp,
            exists: true
        });

        productHashUsed[productHash] = true;
        productCount++;

        emit ProductRegistered(
            id,
            msg.sender,
            productHash
        );

        return id;
    }

    function transferCustody(
        uint256 productId,
        address newCustodian
    ) external {
        require(productId < productCount, "Invalid product");
        require(newCustodian != address(0), "Invalid custodian");

        Product storage product = products[productId];

        require(
            product.currentCustodian == msg.sender,
            "Not current custodian"
        );

        require(
            newCustodian != msg.sender,
            "Already custodian"
        );

        address previousCustodian = product.currentCustodian;
        product.currentCustodian = newCustodian;

        emit CustodyTransferred(
            productId,
            previousCustodian,
            newCustodian
        );
    }

    function addCheckpoint(
        uint256 productId,
        bytes32 locationHash,
        string calldata note
    ) external {
        require(productId < productCount, "Invalid product");

        Product storage product = products[productId];

        require(
            product.currentCustodian == msg.sender,
            "Not current custodian"
        );

        require(bytes(note).length > 0, "Empty note");

        checkpoints[productId].push(
            Checkpoint({
                recordedBy: msg.sender,
                locationHash: locationHash,
                note: note,
                timestamp: block.timestamp
            })
        );

        emit CheckpointAdded(
            productId,
            msg.sender,
            locationHash,
            note
        );
    }

    function getCheckpointCount(
        uint256 productId
    ) external view returns (uint256) {
        require(productId < productCount, "Invalid product");
        return checkpoints[productId].length;
    }

    function getCheckpoint(
        uint256 productId,
        uint256 checkpointId
    )
        external
        view
        returns (
            address recordedBy,
            bytes32 locationHash,
            string memory note,
            uint256 timestamp
        )
    {
        require(productId < productCount, "Invalid product");
        require(
            checkpointId < checkpoints[productId].length,
            "Invalid checkpoint"
        );

        Checkpoint memory cp = checkpoints[productId][checkpointId];

        return (
            cp.recordedBy,
            cp.locationHash,
            cp.note,
            cp.timestamp
        );
    }
}
