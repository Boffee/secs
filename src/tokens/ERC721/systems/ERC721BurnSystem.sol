// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLogic.sol";
import "secs/systems/System.sol";

uint256 constant ERC721BurnSystemID = uint256(keccak256("system.ERC721.Burn"));

contract ERC721BurnSystem is System {
    using ERC721ECSLogic for IUint256Component;

    constructor(IWorld world) System(world, ERC721BurnSystemID) {}

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

function getERC721BurnSystem(IUint256Component systems)
    view
    returns (ERC721BurnSystem)
{
    return ERC721BurnSystem(getAddressById(systems, ERC721BurnSystemID));
}

function deployERC721BurnSystem(IWorld world) {
    address system = address(new ERC721BurnSystem(world));

    IUint256Component components = world.components();
    getApprovalComponent(components).authorizeWriter(system);
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
