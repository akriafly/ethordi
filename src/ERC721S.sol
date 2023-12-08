// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract ERC721S is ERC721 {
    bytes32 public root;
    uint256 public beginBlockNumber;
    uint256 public endBlockNumber;
    uint256 public totalSupply;

    mapping(bytes32 => bool) public minted;

    event Mint(uint256 indexed tokenId, address indexed to);

    constructor(
        string memory name,
        string memory symbol,
        bytes32 _root,
        uint256 _beginBlockNumber,
        uint256 _endBlockNumber
    ) ERC721(name, symbol) {
        root = _root;
        if (_beginBlockNumber > 0) {
            beginBlockNumber = _beginBlockNumber;
        }

        require(endBlockNumber > 0 && endBlockNumber > block.number, "END_BLOCK_NUMBER_EXPIRE");
        require(endBlockNumber > beginBlockNumber, "END_BLOCK_NUMBER_LESS_THAN_BEGIN");
        endBlockNumber = _endBlockNumber;
    }

    function _baseURI() internal view override returns (string memory) {
        return string.concat("https://127.0.0.1:3000/", Strings.toHexString(address(this)));
    }

    function mint(bytes calldata data, bytes32[] calldata proof, address to) external {
        require(block.number >= beginBlockNumber, "NOT_START");
        require(block.number <= endBlockNumber, "FINISH");
        bytes32 leaf = keccak256(data);
        require(!minted[leaf], "MINTED");
        require(validate(data), "INVALID_ORD_FORMAT");

        if (root != bytes32(0)) {
            require(MerkleProof.verify(proof, root, leaf), "INVALID_PROOF");
        }

        totalSupply += 1;
        _mint(to, totalSupply);
        emit Mint(totalSupply, to);
    }

    function validate(bytes calldata data) internal pure returns (bool) {
        uint256 len = data.length;
        return (
            data[0] == 0 && data[1] == 0x63 && data[2] == 0x03 && data[4] == 0x6f && data[5] == 0x72 && data[6] == 0x64
                && data[7] == 0x01 && data[8] == 0x01 && data[len - 1] == 0x68
        );
    }
}
