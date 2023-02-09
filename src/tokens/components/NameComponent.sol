// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";

uint256 constant NameComponentID = uint256(keccak256("component.Name"));

contract NameComponent is StringComponent {
    constructor(address world) StringComponent(world, NameComponentID) {}
}
