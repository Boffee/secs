// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/tokens/ERC721/ERC721ECS.sol";
import "secs/tokens/ERC721/systems/ERC721MintSystem.sol";
import "secs/tokens/ERC721/systems/ERC721SafeMintSystem.sol";

contract MockERC721ECS is ERC721ECS {
    using SystemDelegateCall for address;

    constructor(IWorld world) ERC721ECS(world) {}

    function mint(address to, uint256 tokenId) public {
        address(getERC721MintSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(to, tokenToEntity(address(this), tokenId))
        );
    }

    function safeMint(address to, uint256 tokenId) public {
        safeMint(to, tokenId, "");
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) public {
        address(getERC721SafeMintSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(to, tokenToEntity(address(this), tokenId), data)
        );
    }
}
