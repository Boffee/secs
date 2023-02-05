// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";

uint256 constant DescriptionComponentID = uint256(
    keccak256("component.Description")
);

contract DescriptionComponent is StringComponent {
    constructor(address world) StringComponent(world, DescriptionComponentID) {}
}
