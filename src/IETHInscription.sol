// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IETHInscription {
    function inscribe(bytes calldata) external returns (uint256, bytes32);

    function baseURI() external view returns (string memory);
}

interface IETHInscriptionMETA {
    error BadOrdinalsFormat();

    event Inscription(address indexed issuer, uint256 indexed inscriptionId, bytes32 indexed inscriptionHash);
}
