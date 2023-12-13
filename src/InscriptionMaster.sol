// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import {ETHInscription} from './ETHInscription.sol';

contract InscriptionMaster is ERC721Enumerable {
    string public constant baseURI = "https://ethordi.xyz/";
    ETHInscription public immutable ethInscription;
    uint256 public constant hard = 2;
    // Merkle root for Merkle Proof verification, used for minting validation
    bytes32 public immutable root;

    // Mapping to track whether a specific token has been minted
    mapping(bytes32 => bool) public minted;

    

    // Constructor to initialize the NFT contract with necessary details
    constructor(bytes32 _root, address _ethInscription) ERC721("InscriptionMaster", "INM") {
        require(bytes(baseURI).length > 0, "EMPTY_URI");
        require(_root != bytes32(0), "EMPTY_ROOT");
        require(_ethInscription != address(0), "EMPTY_ETHINSCRIPTION_ADDRESS");
        root = _root;
        ethInscription = ETHInscription(_ethInscription);
    }

    // Override the _baseURI function to set the base URI for the token metadata
    function _baseURI() internal pure override returns (string memory) {
        return baseURI;
    }

    // Mint function to create new tokens
    function mint(bytes calldata data, bytes32[] calldata proof, bytes32 pow, address to) external {
        (uint256 inscriptionId, bytes32 inscriptionHash) = ethInscription.inscribe(data);
        bytes32 r = keccak256(abi.encode(inscriptionHash, pow, msg.sender));
        require(r << (32 - hard) == 0x0, 'POW_FAIL');
        require(MerkleProof.verify(proof, inscriptionHash, root), "INVALID_PROOF");
        // @NOTICE, this method is only for NFT.
        require(minted[inscriptionHash] == false, "ALREADY_MINT");
        minted[inscriptionHash] = true;
        _mint(to, inscriptionId);
    }
}
