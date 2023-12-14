// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IETHInscription} from "./IETHInscription.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ETHInscription is IETHInscription, ERC721 {
    uint256 public inscriptionId;

    constructor() ERC721("ETHORDI", "ETHORDI") {}

    function inscribe(bytes calldata data) external returns (uint256 id, bytes32 hash) {
        if (!validate(data)) {
            revert BadOrdinalsFormat();
        }
        inscriptionId += 1;
        id = inscriptionId;
        hash = keccak256(data);
        emit Inscription(msg.sender, inscriptionId, hash);
        _mint(msg.sender, inscriptionId);
    }

    function validate(bytes calldata data) public pure returns (bool) {
        bytes8 header = bytes8(data);
        return header == 0x0063036f72640101 && data[data.length - 1] == 0x68;
    }
}
