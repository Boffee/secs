// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLib.sol";
import "secs/systems/System.sol";

uint256 constant ApproveSystemID = uint256(keccak256("system.ERC721.Approve"));

contract ApproveSystem is System {
    using ERC721ECSLib for IUint256Component;

    constructor(IWorld world) System(world, ApproveSystemID) {}

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

function getApproveSystem(IUint256Component systems)
    view
    returns (ApproveSystem)
{
    return ApproveSystem(getAddressById(systems, ApproveSystemID));
}
