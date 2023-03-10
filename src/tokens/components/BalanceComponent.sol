// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/components/CounterBareComponent.sol";
import "secs/utils/entity.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";

uint256 constant BalanceComponentID = uint256(keccak256("component.Balance"));

contract BalanceComponent is CounterBareComponent {
    constructor(address world)
        CounterBareComponent(world, BalanceComponentID)
    {}
}

function getBalanceComponent(IUint256Component components)
    view
    returns (BalanceComponent)
{
    return BalanceComponent(getAddressById(components, BalanceComponentID));
}

function deployBalanceComponent(IWorld world) {
    new BalanceComponent(address(world));
}
