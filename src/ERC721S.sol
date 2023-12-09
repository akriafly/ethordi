// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract ERC721S is ERC721 {
    string public baseURI;

    // Merkle root for Merkle Proof verification, used for minting validation
    bytes32 public root;

    // Tracks the total number of tokens minted
    uint256 public totalSupply;

    // Mapping to track whether a specific token has been minted
    mapping(bytes32 => bool) public minted;

    // Event emitted when a new token is inscribed
    event InscriptionIndex(uint256 indexed tokenId, address indexed to);

    // Constructor to initialize the NFT contract with necessary details
    constructor(string memory name, string memory symbol, string memory uri, bytes32 _root) ERC721(name, symbol) {
        require(bytes(baseURI).length > 0, "EMPTY_URI");
        require(_root != bytes32(0), "EMPTY_ROOT");
        baseURI = uri;
        root = _root;
    }

    // Override the _baseURI function to set the base URI for the token metadata
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // Inscribe function to create new tokens
    function inscribe(bytes calldata data, bytes32[] calldata proof, address to) external {
        // Create a unique identifier for the data to prevent duplicate minting
        bytes32 leaf = _inscribe(data);

        // Verify the provided proof against the Merkle root
        require(MerkleProof.verify(proof, root, leaf), "INVALID_PROOF");

        // Increment the total supply and mint the token
        totalSupply += 1;
        _mint(to, totalSupply);
        emit InscriptionIndex(totalSupply, to);
    }

    function _inscribe(bytes calldata data) internal returns (bytes32) {
        // Create a unique identifier for the data to prevent duplicate minting
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(data))));
        require(!minted[leaf], "MINTED");

        // Validate the data format
        require(_validate(data), "INVALID_ORD_FORMAT");
        minted[leaf] = true;
        return leaf;
    }

    // Function to validate the data format
    function _validate(bytes calldata data) internal pure returns (bool) {
        uint256 len = data.length;
        // Check for specific byte values at certain positions to validate data format
        return (
            data[0] == 0 && data[1] == 0x63 && data[2] == 0x03 && data[4] == 0x6f && data[5] == 0x72 && data[6] == 0x64
                && data[7] == 0x01 && data[8] == 0x01 && data[len - 1] == 0x68
        );
    }
}
