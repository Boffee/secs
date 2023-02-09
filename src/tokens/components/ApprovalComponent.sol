// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/Uint256BareComponent.sol";

uint256 constant ApprovalComponentID = uint256(keccak256("component.Approval"));

contract ApprovalComponent is Uint256BareComponent {
    constructor(address world)
        Uint256BareComponent(world, ApprovalComponentID)
    {}
}
