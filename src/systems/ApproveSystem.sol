// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "./System.sol";
import "../components/OwnerComponent.sol";
import "../libraries/ComponentGetter.sol";
import "../libraries/ECS721Lib.sol";

uint256 constant ApproveSystemID = uint256(keccak256("system.Approve"));

contract ApproveSystem is System {
    using ComponentGetter for IUint256Component;
    using ECS721Lib for IUint256Component;

    constructor(IWorld world, address components) System(world, components) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 to, uint256 entity) = abi.decode(args, (uint256, uint256));

        executeTyped(to, entity);
    }

    function executeTyped(uint256 to, uint256 entity)
        public
        virtual
        returns (bytes memory)
    {
        uint256 owner = COMPONENTS.ownerOf(entity);
        uint256 sender = addressToEntity(_msgSender());
        uint256 token = getEntityToken(entity);

        require(to != owner, "Approval to current owner");
        require(
            sender == owner
                || COMPONENTS.isApprovedForAll(token, owner, sender),
            "Approve caller is not token owner or approved for all"
        );
        COMPONENTS._approve(to, entity);
    }
}
