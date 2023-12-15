// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IETHInscription {
    function inscribe(bytes calldata) external payable returns (uint256, bytes32);

    function baseURI() external view returns (string memory);
}

interface IETHInscriptionMeta {
    error BadOrdinalsFormat();

    event Inscription(uint256 indexed inscriptionId);
}
