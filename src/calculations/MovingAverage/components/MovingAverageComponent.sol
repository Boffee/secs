// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";
import "secs/components/Bytes32BareComponent.sol";

uint256 constant MovingAverageComponentID =
    uint256(keccak256("component.MovingAverage"));

struct MovingAverage {
    uint128 value;
    uint40 window;
    uint40 lastUpdateTimestamp;
}

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
        return MovingAverageLib.schema();
    }

    function set(uint256 entity, MovingAverage memory movingAverage)
        public
        virtual
    {
        set(entity, MovingAverageLib.serialize(movingAverage));
    }

    function getValue(uint256 entity)
        public
        view
        virtual
        returns (MovingAverage memory)
    {
        return MovingAverageLib.deserialize(getRawValue(entity));
    }
}

library MovingAverageLib {
    function schema()
        internal
        pure
        returns (string[] memory, LibTypes.SchemaValue[] memory)
    {
        string[] memory keys = new string[](3);
        LibTypes.SchemaValue[] memory values = new LibTypes.SchemaValue[](3);

        keys[0] = "value";
        values[0] = LibTypes.SchemaValue.UINT128;

        keys[1] = "window";
        values[1] = LibTypes.SchemaValue.UINT64;

        keys[2] = "lastUpdateTimestamp";
        values[2] = LibTypes.SchemaValue.UINT64;

        return (keys, values);
    }

    function serialize(MovingAverage memory ma)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(ma.value, ma.window, ma.lastUpdateTimestamp);
    }

    function deserialize(bytes memory data)
        internal
        pure
        returns (MovingAverage memory ma)
    {
        ma = MovingAverage(0, 0, 0);

        if (data.length > 0) {
            assembly {
                mstore(ma, shr(128, mload(add(data, 0x20))))
                mstore(add(ma, 0x20), shr(216, mload(add(data, 0x30))))
                mstore(add(ma, 0x40), shr(216, mload(add(data, 0x35))))
            }
        }
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
