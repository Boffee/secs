// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLib.sol";
import "secs/systems/System.sol";

uint256 constant BurnSystemID = uint256(keccak256("system.ERC721.Burn"));

contract BurnSystem is System {
    using ERC721ECSLib for IUint256Component;

    constructor(IWorld world) System(world, BurnSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        uint256 entity = abi.decode(args, (uint256));

        executeTyped(entity);
    }

    function executeTyped(uint256 entity) public virtual {
        require(
            COMPONENTS._isApprovedOrOwner(addressToEntity(_msgSender()), entity),
            "Caller is not entity owner or approved"
        );
        COMPONENTS._burn(entity);
    }
}

function getBurnSystem(IUint256Component systems) view returns (BurnSystem) {
    return BurnSystem(getAddressById(systems, BurnSystemID));
}

function deployBurnSystem(IWorld world) {
    address system = address(new BurnSystem(world));

    IUint256Component components = world.components();
    getApprovalComponent(components).authorizeWriter(system);
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
