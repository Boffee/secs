// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs-std/components/StringComponent.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant SymbolComponentID = uint256(keccak256("component.Symbol"));

contract SymbolComponent is StringComponent {
    constructor(address world) StringComponent(world, SymbolComponentID) {}
}

function symbolComponent(IUint256Component components)
    view
    returns (SymbolComponent)
{
    return SymbolComponent(getAddressById(components, SymbolComponentID));
}
