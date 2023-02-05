// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "./System.sol";
import "../components/OwnerComponent.sol";
import "../libraries/ComponentGetter.sol";
import "../libraries/Permission.sol";

uint256 constant MintSystemID = uint256(keccak256("system.Mint"));

contract MintSystem is System {
    using ComponentGetter for IUint256Component;
    using Permission for IUint256Component;

    constructor(IWorld world, address components) System(world, components) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 to, uint256 entity) = abi.decode(args, (uint256, uint256));

        executeTyped(to, entity);
    }

    function executeTyped(uint256 to, uint256 entity)
        public
        virtual
        returns (bytes memory)
    {
        _mint(to, entity);
    }

    function _mint(uint256 to, uint256 entity) internal virtual {
        require(to != 0, "Mint to zero entity");
        require(COMPONENTS.ownerOf(entity) == 0, "Entity already minted");

        // Increment balance
        COMPONENTS.balanceComponent().increment(to, 1);

        // Set owner
        COMPONENTS.ownerComponent().set(entity, to);
    }
}
