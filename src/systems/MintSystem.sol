// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "./System.sol";
import "../components/OwnerComponent.sol";
import "../libraries/ComponentGetter.sol";
import "../libraries/Permission.sol";

uint256 constant MintSystemID = uint256(keccak256("system.Mint"));

abstract contract MintSystem is System {
    using ComponentGetter for IUint256Component;
    using Permission for IUint256Component;

    function _mint(uint256 to, uint256 entity) internal virtual {
        require(to != 0, "Mint to zero entity");
        require(COMPONENTS.ownerOf(entity) == 0, "Entity already minted");

        // Increment balance
        COMPONENTS.balanceComponent().increment(
            hashEntities(getEntityToken(entity), to), 1
        );

        // Set owner
        COMPONENTS.ownerComponent().set(entity, to);
    }
}
