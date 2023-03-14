// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";
import "secs/components/Bytes32BareComponent.sol";
import "../data/MovingAverageData.sol";

uint256 constant MovingAverageComponentID =
    uint256(keccak256("component.MovingAverage"));

contract MovingAverageComponent is Bytes32BareComponent {
    constructor(address world)
        Bytes32BareComponent(world, MovingAverageComponentID)
    {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        return MovingAverageDataLib.schema();
    }

    function set(uint256 entity, MovingAverageData memory movingAverage)
        public
        virtual
    {
        set(entity, MovingAverageDataLib.serialize(movingAverage));
    }

    function getValue(uint256 entity)
        public
        view
        virtual
        returns (MovingAverageData memory)
    {
        return MovingAverageDataLib.deserialize(getRawValue(entity));
    }
}

function getMovingAverageComponent(IUint256Component components)
    view
    returns (MovingAverageComponent)
{
    return MovingAverageComponent(
        getAddressById(components, MovingAverageComponentID)
    );
}
