// SPDX-License-Identifier: Apache-2.0

/**
 * Authors: Moonstream Engineering (engineering@moonstream.to)
 * GitHub: https://github.com/bugout-dev/engine
 */

pragma solidity ^0.8.0;

import "@openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";
import {TerminusPermissions} from "@moonstream/contracts/terminus/TerminusPermissions.sol";
import "../../diamond/libraries/LibDiamond.sol";

library LibGOFP {
    bytes32 constant STORAGE_POSITION =
        keccak256("moonstreamdao.eth.storage.mechanics.GardenOfForkingPaths");

    struct GOFPStorage {
        address AdminTerminusAddress;
        uint256 AdminTerminusPoolID;
        uint256 NumSessions;
        mapping(uint256 => address) SessionPlayerTokenAddress;
        mapping(uint256 => address) SessionPaymentTokenAddress;
        mapping(uint256 => uint256) SessionPaymentAmount;
        mapping(uint256 => bool) SessionIsActive;
        mapping(uint256 => string) SessionURI;
        mapping(uint256 => uint256[]) SessionStages;
        // session -> stage -> correct path index
        mapping(uint256 => mapping(uint256 => uint256)) SessionPath;
    }

    function gofpStorage() internal pure returns (GOFPStorage storage gs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            gs.slot := position
        }
    }
}

contract GOFPFacet is ERC1155Holder, ERC721Holder, TerminusPermissions {
    modifier onlyGameMaster() {
        LibGOFP.GOFPStorage storage gs = LibGOFP.gofpStorage();
        require(
            _holdsPoolToken(gs.AdminTerminusAddress, gs.AdminTerminusPoolID, 1),
            "GOFPFacet.onlyGameMaster: The address is not an authorized game master"
        );
        _;
    }

    event SessionCreated(
        uint256 indexed sessionID,
        address indexed playerTokenAddress,
        address indexed paymentTokenAddress,
        uint256 paymentAmount,
        string uri
    );

    // When session is activated, this fires:
    // SessionActivated(<id>, true)
    // When session is deactivated, this fires:
    // SessionActivated(<id>, false)
    event SessionActivated(uint256 indexed sessionID, bool active);

    function init(address adminTerminusAddress, uint256 adminTerminusPoolID)
        external
    {
        LibDiamond.enforceIsContractOwner();
        LibGOFP.GOFPStorage storage gs = LibGOFP.gofpStorage();
        gs.AdminTerminusAddress = adminTerminusAddress;
        gs.AdminTerminusPoolID = adminTerminusPoolID;
    }

    function getSession(uint256 sessionID)
        external
        view
        returns (
            address playerTokenAddress,
            address paymentTokenAddress,
            uint256 paymentamount,
            bool isActive,
            string memory uri,
            uint256[] memory stages,
            uint256[] memory correctPath
        )
    {
        LibGOFP.GOFPStorage storage gs = LibGOFP.gofpStorage();
        playerTokenAddress = gs.SessionPlayerTokenAddress[sessionID];
        paymentTokenAddress = gs.SessionPaymentTokenAddress[sessionID];
        paymentamount = gs.SessionPaymentAmount[sessionID];
        isActive = gs.SessionIsActive[sessionID];
        uri = gs.SessionURI[sessionID];
        stages = gs.SessionStages[sessionID];
        correctPath = new uint256[](stages.length);
        for (uint256 i = 0; i < stages.length; i++) {
            correctPath[i] = gs.SessionPath[sessionID][i];
        }
    }

    function adminTerminusInfo() external view returns (address, uint256) {
        LibGOFP.GOFPStorage storage gs = LibGOFP.gofpStorage();
        return (gs.AdminTerminusAddress, gs.AdminTerminusPoolID);
    }

    function numSessions() external view returns (uint256) {
        return LibGOFP.gofpStorage().NumSessions;
    }

    function createSession(
        address playerTokenAddress,
        address paymentTokenAddress,
        uint256 paymentAmount,
        string memory uri,
        uint256[] memory stages,
        bool active
    ) external onlyGameMaster {
        LibGOFP.GOFPStorage storage gs = LibGOFP.gofpStorage();
        gs.NumSessions++;
        require(
            gs.SessionPlayerTokenAddress[gs.NumSessions] == address(0),
            "Session already registered"
        );
        gs.SessionPlayerTokenAddress[gs.NumSessions] = playerTokenAddress;
        gs.SessionPaymentTokenAddress[gs.NumSessions] = paymentTokenAddress;
        gs.SessionPaymentAmount[gs.NumSessions] = paymentAmount;
        gs.SessionURI[gs.NumSessions] = uri;
        gs.SessionStages[gs.NumSessions] = stages;
        gs.SessionIsActive[gs.NumSessions] = active;

        emit SessionCreated(
            gs.NumSessions,
            playerTokenAddress,
            paymentTokenAddress,
            paymentAmount,
            uri
        );
    }

    function setSessionActive(uint256 sessionID, bool active)
        external
        onlyGameMaster
    {
        LibGOFP.GOFPStorage storage gs = LibGOFP.gofpStorage();
        require(sessionID <= gs.NumSessions, "Invalid session ID");
        gs.SessionIsActive[sessionID] = active;
        emit SessionActivated(sessionID, active);
    }
}
