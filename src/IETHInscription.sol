// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IETHInscription {
    error BadOrdinalsFormat();
    event Inscription(address indexed issuer, uint256 indexed inscriptionId, bytes32 indexed inscriptionHash);
}
