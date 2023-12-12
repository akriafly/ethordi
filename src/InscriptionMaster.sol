// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import {ETHInscription} from './ETHInscription.sol';

contract InscriptionMaster is ERC721 {
    string public baseURI;
    ETHInscription public immutable ethInscription;

    // Merkle root for Merkle Proof verification, used for minting validation
    bytes32 public immutable root;

    // Tracks the total number of tokens minted
    uint256 public totalSupply;

    // Mapping to track whether a specific token has been minted
    mapping(uint256 => uint256) public minted;

    // Constructor to initialize the NFT contract with necessary details
    constructor(string memory name, string memory symbol, string memory uri, bytes32 _root, address _ethInscription) ERC721(name, symbol) {
        require(bytes(baseURI).length > 0, "EMPTY_URI");
        require(_root != bytes32(0), "EMPTY_ROOT");
        require(_ethInscription != address(0), "EMPTY_ETHINSCRIPTION_ADDRESS");
        baseURI = uri;
        root = _root;
        ethInscription = ETHInscription(_ethInscription);
    }

    // Override the _baseURI function to set the base URI for the token metadata
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // Mint function to create new tokens
    function mint(bytes calldata data, bytes32[] calldata proof, address to) external {
        (uint256 inscriptionId, bytes32 inscriptionHash) = ethInscription.inscribe(data);
        require(MerkleProof.verify(proof, inscriptionHash, root), "INVALID_PROOF");
        totalSupply += 1;
        _mint(to, inscriptionId);
    }
}
