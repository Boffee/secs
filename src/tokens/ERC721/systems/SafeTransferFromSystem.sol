// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ECS721Lib.sol";
import "secs/systems/System.sol";

uint256 constant SafeTransferFromSystemID =
    uint256(keccak256("system.ERC721.SafeTransferFrom"));

contract SafeTransferFromSystem is System {
    using ECS721Lib for IUint256Component;

    constructor(IWorld world) System(world, SafeTransferFromSystemID) {}

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

function safeTransferFromSystem(IUint256Component systems)
    view
    returns (SafeTransferFromSystem)
{
    return SafeTransferFromSystem(
        getAddressById(systems, SafeTransferFromSystemID)
    );
}
