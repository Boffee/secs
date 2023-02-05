// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/Uint256BareComponent.sol";

contract CounterBareComponent is Uint256BareComponent {
    constructor(address world, uint256 id) Uint256BareComponent(world, id) {}

    function increment(uint256 entity, uint256 amount) public {
        set(entity, getValue(entity) + amount);
    }

    function decrement(uint256 entity, uint256 amount) public {
        set(entity, getValue(entity) - amount);
    }
}
