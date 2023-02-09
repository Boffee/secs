// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/ERC20/ECS20.sol";

uint256 constant MockECS20ID = uint256(keccak256("system.MockECS20"));

contract MockECS20 is ECS20 {
    constructor(IWorld world) ECS20(world, MockECS20ID) {}

    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
}
