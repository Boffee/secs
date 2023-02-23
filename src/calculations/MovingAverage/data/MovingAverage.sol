// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solecs/LibTypes.sol";

struct MovingAverage {
    uint128 value;
    uint40 window;
    uint40 lastUpdateTimestamp;
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
