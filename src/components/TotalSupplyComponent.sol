// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./CounterBareComponent.sol";

uint256 constant TotalSupplyComponentID =
    uint256(keccak256("component.TotalSupply"));

contract TotalSupplyComponent is CounterBareComponent {
    constructor(address world)
        CounterBareComponent(world, TotalSupplyComponentID)
    {}
}
