// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLib.sol";
import "secs/systems/System.sol";

uint256 constant ERC721ApproveSystemID =
    uint256(keccak256("system.ERC721.Approve"));

contract ERC721ApproveSystem is System {
    using ERC721ECSLib for IUint256Component;

    constructor(IWorld world) System(world, ERC721ApproveSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 to, uint256 entity) = abi.decode(args, (uint256, uint256));

        executeTyped(to, entity);
    }

    function executeTyped(uint256 to, uint256 entity) public virtual {
        uint256 owner = COMPONENTS.ownerOf(entity);
        uint256 sender = addressToEntity(_msgSender());
        uint256 token = getEntityToken(entity);

        require(to != owner, "Approval to current owner");
        require(
            sender == owner || COMPONENTS.isApprovedForAll(token, owner, sender),
            "Approve caller is not token owner or approved for all"
        );
        COMPONENTS._approve(to, entity);
    }
}

function getERC721ApproveSystem(IUint256Component systems)
    view
    returns (ERC721ApproveSystem)
{
    return ERC721ApproveSystem(getAddressById(systems, ERC721ApproveSystemID));
}

function deployERC721ApproveSystem(IWorld world) {
    address system = address(new ERC721ApproveSystem(world));

    IUint256Component components = world.components();
    getApprovalComponent(components).authorizeWriter(system);
}
