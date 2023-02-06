// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "./System.sol";
import "../components/OwnerComponent.sol";
import "../libraries/ComponentGetter.sol";
import "../libraries/ECS721Lib.sol";

uint256 constant BurnSystemID = uint256(keccak256("system.Burn"));

contract BurnSystem is System {
    using ComponentGetter for IUint256Component;
    using ECS721Lib for IUint256Component;

    constructor(IWorld world, address components) System(world, components) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        uint256 entity = abi.decode(args, (uint256));

        executeTyped(entity);
    }

    function executeTyped(uint256 entity)
        public
        virtual
        returns (bytes memory)
    {
        require(
            COMPONENTS._isApprovedOrOwner(addressToEntity(_msgSender()), entity),
            "Caller is not entity owner or approved"
        );
        COMPONENTS._burn(entity);
    }
}
