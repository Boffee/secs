// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./CounterBareComponent.sol";

uint256 constant BalanceComponentID = uint256(keccak256("component.Balance"));

contract BalanceComponent is CounterBareComponent {
    constructor(address world)
        CounterBareComponent(world, BalanceComponentID)
    {}
}
