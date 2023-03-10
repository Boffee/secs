// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";
import "secs/utils/entity.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant DescriptionComponentID =
    uint256(keccak256("component.Description"));

contract DescriptionComponent is StringComponent {
    constructor(address world) StringComponent(world, DescriptionComponentID) {}
}

function getDescriptionComponent(IUint256Component components)
    view
    returns (DescriptionComponent)
{
    return
        DescriptionComponent(getAddressById(components, DescriptionComponentID));
}

function deployDescriptionComponent(IWorld world) {
    new DescriptionComponent(address(world));
}
