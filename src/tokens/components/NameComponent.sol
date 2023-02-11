// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant NameComponentID = uint256(keccak256("component.Name"));

contract NameComponent is StringComponent {
    constructor(address world) StringComponent(world, NameComponentID) {}
}

function getNameComponent(IUint256Component components)
    view
    returns (NameComponent)
{
    return NameComponent(getAddressById(components, NameComponentID));
}
