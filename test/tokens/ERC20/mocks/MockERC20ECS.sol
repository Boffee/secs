// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/tokens/ERC20/ERC20ECS.sol";

uint256 constant MockERC20ECSID = uint256(keccak256("system.MockERC20ECS"));

contract MockERC20ECS is ERC20ECS {
    constructor(IWorld world) ERC20ECS(world, MockERC20ECSID) {}

    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
}
