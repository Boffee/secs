// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLogic.sol";
import "secs/systems/System.sol";

uint256 constant ERC721SafeTransferFromSystemID =
    uint256(keccak256("system.ERC721.SafeTransferFrom"));

contract ERC721SafeTransferFromSystem is System {
    using ERC721ECSLogic for IUint256Component;

    constructor(IWorld world) System(world, ERC721SafeTransferFromSystemID) {}

    function execute(bytes memory args) public returns (bytes memory) {
        (uint256 from, uint256 to, uint256 entity, bytes memory data) =
            abi.decode(args, (uint256, uint256, uint256, bytes));

        executeTyped(from, to, entity, data);
    }

    function executeTyped(
        uint256 from,
        uint256 to,
        uint256 entity,
        bytes memory data
    ) public {
        uint256 sender = addressToEntity(_msgSender());
        require(
            COMPONENTS._isApprovedOrOwner(sender, entity),
            "Caller is not entity owner or approved"
        );
        COMPONENTS._safeTransfer(sender, from, to, entity, data);
    }
}

function getERC721SafeTransferFromSystem(IUint256Component systems)
    view
    returns (ERC721SafeTransferFromSystem)
{
    return ERC721SafeTransferFromSystem(
        getAddressById(systems, ERC721SafeTransferFromSystemID)
    );
}

function deployERC721SafeTransferFromSystem(IWorld world) {
    address system = address(new ERC721SafeTransferFromSystem(world));

    IUint256Component components = world.components();
    getApprovalComponent(components).authorizeWriter(system);
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
