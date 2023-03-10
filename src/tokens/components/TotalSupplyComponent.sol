// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/CounterBareComponent.sol";
import "secs/utils/entity.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant TotalSupplyComponentID =
    uint256(keccak256("component.TotalSupply"));

contract TotalSupplyComponent is CounterBareComponent {
    constructor(address world)
        CounterBareComponent(world, TotalSupplyComponentID)
    {}
}

function getTotalSupplyComponent(IUint256Component components)
    view
    returns (TotalSupplyComponent)
{
    return
        TotalSupplyComponent(getAddressById(components, TotalSupplyComponentID));
}

function deployTotalSupplyComponent(IWorld world) {
    new TotalSupplyComponent(address(world));
}
