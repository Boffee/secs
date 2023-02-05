// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "../libraries/ComponentGetter.sol";
import "../libraries/Permission.sol";
import "../utils/entity.sol";
import "./System.sol";

uint256 constant TransferSystemID = uint256(keccak256("system.Transfer"));

contract TransferSystem is System {
    using ComponentGetter for IUint256Component;
    using Permission for IUint256Component;

    constructor(IWorld world, address components) System(world, components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        (uint256 from, uint256 to, uint256 entity) = abi.decode(
            args,
            (uint256, uint256, uint256)
        );

        executeTyped(from, to, entity);
    }

    function executeTyped(
        uint256 from,
        uint256 to,
        uint256 entity
    ) public {
        require(
            COMPONENTS.isApprovedOrOwner(addressToEntity(_msgSender()), entity),
            "Caller is not entity owner or approved"
        );
        _transfer(from, to, entity);
    }

    function _transfer(
        uint256 from,
        uint256 to,
        uint256 entity
    ) internal {
        require(
            COMPONENTS.ownerOf(entity) == from,
            "Transfer from incorrect owner"
        );
        require(to != 0, "Transfer to zero entity");

        // Check that entity was not transferred by `_beforeTransfer` hook
        require(
            COMPONENTS.ownerOf(entity) == from,
            "Transfer from incorrect owner"
        );

        // Clear approvals from the previous owner
        COMPONENTS.approvalComponent().remove(entity);

        // Move balance from old owner to new owner
        BalanceComponent balanceComponent = COMPONENTS.balanceComponent();
        balanceComponent.decrement(from, 1);
        balanceComponent.increment(to, 1);

        // Change owner
        COMPONENTS.ownerComponent().set(entity, addressToEntity(_msgSender()));
    }
}
