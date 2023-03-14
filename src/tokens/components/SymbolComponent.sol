// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";
import "secs/utils/entity.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant SymbolComponentID = uint256(keccak256("component.Symbol"));

contract SymbolComponent is StringComponent {
    constructor(address world) StringComponent(world, SymbolComponentID) {}

    function _set(uint256 entity, bytes memory value)
        internal
        virtual
        override
    {
        require(getEntitiesWithValue(value).length == 0, "Name must be unique");
        super._set(entity, value);
    }
}

function getSymbolComponent(IUint256Component components)
    view
    returns (SymbolComponent)
{
    return SymbolComponent(getAddressById(components, SymbolComponentID));
}

function deploySymbolComponent(IWorld world) {
    new SymbolComponent(address(world));
}

function getEntityBySymbol(IUint256Component components, bytes memory symbol)
    view
    returns (uint256)
{
    return getSymbolComponent(components).getEntitiesWithValue(symbol)[0];
}
