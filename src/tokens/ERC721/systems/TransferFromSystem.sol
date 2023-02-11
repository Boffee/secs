// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ECS721Lib.sol";
import "secs/systems/System.sol";

uint256 constant TransferFromSystemID =
    uint256(keccak256("system.ERC721.TransferFrom"));

contract TransferFromSystem is System {
    using ECS721Lib for IUint256Component;

    constructor(IWorld world) System(world, TransferFromSystemID) {}

    function execute(bytes memory args) public returns (bytes memory) {
        (uint256 from, uint256 to, uint256 entity) =
            abi.decode(args, (uint256, uint256, uint256));

        executeTyped(from, to, entity);
    }

    function executeTyped(uint256 from, uint256 to, uint256 entity) public {
        require(
            COMPONENTS._isApprovedOrOwner(addressToEntity(_msgSender()), entity),
            "Caller is not entity owner or approved"
        );
        COMPONENTS._transfer(from, to, entity);
    }
}

function getTransferFromSystem(IUint256Component systems)
    view
    returns (TransferFromSystem)
{
    return TransferFromSystem(getAddressById(systems, TransferFromSystemID));
}
