// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/CounterBareComponent.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant AllowanceComponentID =
    uint256(keccak256("component.Allowance"));

contract AllowanceComponent is CounterBareComponent {
    constructor(address world)
        CounterBareComponent(world, AllowanceComponentID)
    {}
}

function allowanceComponent(IUint256Component components)
    view
    returns (AllowanceComponent)
{
    return AllowanceComponent(getAddressById(components, AllowanceComponentID));
}
