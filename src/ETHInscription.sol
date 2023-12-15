// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IETHInscription, IETHInscriptionMeta} from "./IETHInscription.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ETHInscription is IETHInscription, IETHInscriptionMeta, ERC721 {
    string public constant baseURI = "https://ethins.xyz/";

    uint256 public inscriptionId;

    constructor() ERC721("ETHINS", "ETHINS") {}

    function inscribe(bytes calldata data) external payable returns (uint256 id, bytes32 hash) {
        if (!validate(data)) {
            revert BadOrdinalsFormat();
        }

        inscriptionId += 1;
        id = inscriptionId;
        hash = keccak256(data);
        emit Inscription(inscriptionId);
    }

    function validate(bytes calldata data) public pure returns (bool) {
        bytes8 header = bytes8(data);
        return header == 0x0063036f72640101 && data[data.length - 1] == 0x68;
    }
}
