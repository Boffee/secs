// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Bytes32BareComponent.sol";

contract BoolBareComponent is Bytes32BareComponent {
    constructor(address world, uint256 id) Bytes32BareComponent(world, id) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](1);
        values = new LibTypes.SchemaValue[](1);

        keys[0] = "value";
        values[0] = LibTypes.SchemaValue.BOOL;
    }

    function set(uint256 entity) public virtual {
        set(entity, abi.encode(true));
    }

    function set(uint256 entity, bool value) public virtual {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity)
        public
        view
        virtual
        returns (bool value)
    {
        bytes memory rawValue = getRawValue(entity);

        if (rawValue.length > 0) {
            value = abi.decode(rawValue, (bool));
        }
    }
}
