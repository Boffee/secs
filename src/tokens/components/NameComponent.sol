// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";
import "secs/utils/entity.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant NameComponentID = uint256(keccak256("component.Name"));

contract NameComponent is StringComponent {
    constructor(address world) StringComponent(world, NameComponentID) {}

    function _set(uint256 entity, bytes memory value)
        internal
        virtual
        override
    {
        require(getEntitiesWithValue(value).length == 0, "Name must be unique");
        super._set(entity, value);
    }
}

function getNameComponent(IUint256Component components)
    view
    returns (NameComponent)
{
    return NameComponent(getAddressById(components, NameComponentID));
}

function deployNameComponent(IWorld world) {
    new NameComponent(address(world));
}
