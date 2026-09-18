// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC165Base {
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool);
}

contract BaseInterfaceChecker {
    function checkInterface(
        address target,
        bytes4 interfaceId
    ) external view returns (bool) {
        try IERC165Base(target).supportsInterface(interfaceId) returns (bool result) {
            return result;
        } catch {
            return false;
        }
    }
}
