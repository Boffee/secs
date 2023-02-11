// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/Uint256BareComponent.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant ApprovalComponentID = uint256(keccak256("component.Approval"));

contract ApprovalComponent is Uint256BareComponent {
    constructor(address world)
        Uint256BareComponent(world, ApprovalComponentID)
    {}
}

function approvalComponent(IUint256Component components)
    view
    returns (ApprovalComponent)
{
    return ApprovalComponent(getAddressById(components, ApprovalComponentID));
}
