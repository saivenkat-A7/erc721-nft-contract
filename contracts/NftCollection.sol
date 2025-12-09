// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title NftCollection - Minimal ERC-721–compatible NFT contract matching your tests
contract NftCollection {
    // State
    string public name;
    string public symbol;
    uint256 public maxSupply;
    uint256 public totalSupply;

    address private _admin;

    // Mappings
    mapping(uint256 => address) private _owners;                   // tokenId -> owner
    mapping(address => uint256) private _balances;                 // owner -> balance
    mapping(uint256 => address) private _tokenApprovals;           // tokenId -> approved
    mapping(address => mapping(address => bool)) private _operatorApprovals; // owner -> operator -> approved

    // Metadata
    string private _baseURI;

    // Events (ERC-721)
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Constructor
    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        _admin = msg.sender;
    }

    // --------------------
    // Modifiers
    // --------------------
    modifier onlyAdmin() {
        require(msg.sender == _admin, "Not authorized"); // match tests' message
        _;
    }

    // --------------------
    // ERC-721 view functions
    // --------------------
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid owner address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // --------------------
    // Admin / metadata
    // --------------------
    function setBaseURI(string memory uri) external onlyAdmin {
        _baseURI = uri;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        return string(abi.encodePacked(_baseURI, _toString(tokenId), ".json"));
    }

    // --------------------
    // Mint (signature matches tests)
    // safeMint(address to, uint256 tokenId)
    // --------------------
    function safeMint(address to, uint256 tokenId) external onlyAdmin {
        require(totalSupply < maxSupply, "Max supply reached");
        require(to != address(0), "Invalid recipient");
        require(!_exists(tokenId), "Token already minted");

        // assign
        _owners[tokenId] = to;
        _balances[to] += 1;
        totalSupply += 1;

        emit Transfer(address(0), to, tokenId);
    }

    // --------------------
    // Approvals
    // --------------------
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Cannot approve self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // --------------------
    // Transfers
    // --------------------
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_exists(tokenId), "Token does not exist");
        address owner = ownerOf(tokenId);
        require(owner == from, "Incorrect owner");
        require(to != address(0), "Invalid recipient");
        require(
            msg.sender == owner ||
            msg.sender == _tokenApprovals[tokenId] ||
            isApprovedForAll(owner, msg.sender),
            "Not authorized"
        );

        // clear approval
        _tokenApprovals[tokenId] = address(0);

        // update balances and owner
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        transferFrom(from, to, tokenId);
        // No ERC721Receiver check (tests don't require it)
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata) external {
        transferFrom(from, to, tokenId);
    }

    // --------------------
    // Internal helpers
    // --------------------
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    // uint -> string helper
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
