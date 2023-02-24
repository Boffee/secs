// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLogic.sol";
import "secs/systems/System.sol";

uint256 constant ERC721TransferFromSystemID =
    uint256(keccak256("system.ERC721.TransferFrom"));

contract ERC721TransferFromSystem is System {
    using ERC721ECSLogic for IUint256Component;

    constructor(IWorld world) System(world, ERC721TransferFromSystemID) {}

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

function getERC721TransferFromSystem(IUint256Component systems)
    view
    returns (ERC721TransferFromSystem)
{
    return ERC721TransferFromSystem(
        getAddressById(systems, ERC721TransferFromSystemID)
    );
}

function deployERC721TransferFromSystem(IWorld world) {
    address system = address(new ERC721TransferFromSystem(world));

    IUint256Component components = world.components();
    getApprovalComponent(components).authorizeWriter(system);
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
