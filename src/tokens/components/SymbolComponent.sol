// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";

uint256 constant SymbolComponentID = uint256(keccak256("component.Symbol"));

contract SymbolComponent is StringComponent {
    constructor(address world) StringComponent(world, SymbolComponentID) {}
}
