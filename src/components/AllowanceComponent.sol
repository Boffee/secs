// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./CounterBareComponent.sol";

uint256 constant AllowanceComponentID =
    uint256(keccak256("component.Allowance"));

contract AllowanceComponent is CounterBareComponent {
    constructor(address world)
        CounterBareComponent(world, AllowanceComponentID)
    {}
}
