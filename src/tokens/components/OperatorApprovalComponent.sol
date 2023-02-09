// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/BoolBareComponent.sol";

uint256 constant OperatorApprovalComponentID =
    uint256(keccak256("component.OperatorApproval"));

contract OperatorApprovalComponent is BoolBareComponent {
    constructor(address world)
        BoolBareComponent(world, OperatorApprovalComponentID)
    {}
}
