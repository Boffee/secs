// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/Uint256BareComponent.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant OwnerComponentID = uint256(keccak256("component.Owner"));

contract OwnerComponent is Uint256BareComponent {
    constructor(address world) Uint256BareComponent(world, OwnerComponentID) {}
}

function getOwnerComponent(IUint256Component components)
    view
    returns (OwnerComponent)
{
    return OwnerComponent(getAddressById(components, OwnerComponentID));
}

function deployOwnerComponent(IWorld world) {
    if (world.components().getEntitiesWithValue(OwnerComponentID).length == 0) {
        new OwnerComponent(address(world));
    }
}
