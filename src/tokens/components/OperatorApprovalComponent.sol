// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/BoolBareComponent.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant OperatorApprovalComponentID =
    uint256(keccak256("component.OperatorApproval"));

contract OperatorApprovalComponent is BoolBareComponent {
    constructor(address world)
        BoolBareComponent(world, OperatorApprovalComponentID)
    {}
}

function getOperatorApprovalComponent(IUint256Component components)
    view
    returns (OperatorApprovalComponent)
{
    return OperatorApprovalComponent(
        getAddressById(components, OperatorApprovalComponentID)
    );
}
