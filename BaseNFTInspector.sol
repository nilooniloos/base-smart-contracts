// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721View {
    function ownerOf(uint256 tokenId) external view returns (address);

    function getApproved(uint256 tokenId)
        external
        view
        returns (address);

    function isApprovedForAll(
        address owner,
        address operator
    ) external
        view
        returns (bool);
}

contract BaseNFTInspector {
    function owner(
        address nft,
        uint256 tokenId
    ) external view returns (address) {
        return IERC721View(nft).ownerOf(tokenId);
    }

    function approved(
        address nft,
        uint256 tokenId
    ) external view returns (address) {
        return IERC721View(nft).getApproved(tokenId);
    }

    function approvedForAll(
        address nft,
        address ownerAddress,
        address operator
    ) external view returns (bool) {
        return IERC721View(nft).isApprovedForAll(
            ownerAddress,
            operator
        );
    }
}
