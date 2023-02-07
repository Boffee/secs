// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/tokens/ECS721.sol";

uint256 constant MockECS721ID = uint256(keccak256("system.MockECS721"));

contract MockECS721 is ECS721 {
    constructor(IWorld world) ECS721(world, MockECS721ID) {}

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
