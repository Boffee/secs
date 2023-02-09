// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/Uint256BareComponent.sol";

uint256 constant OwnerComponentID = uint256(keccak256("component.Owner"));

contract OwnerComponent is Uint256BareComponent {
    constructor(address world) Uint256BareComponent(world, OwnerComponentID) {}
}
