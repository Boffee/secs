// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/tokens/ERC721/ERC721ECS.sol";

uint256 constant MockERC721ECSID = uint256(keccak256("system.MockERC721ECS"));

contract MockERC721ECS is ERC721ECS {
    constructor(IWorld world) ERC721ECS(world, MockERC721ECSID) {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) public {
        _safeMint(to, tokenId, data);
    }
}
