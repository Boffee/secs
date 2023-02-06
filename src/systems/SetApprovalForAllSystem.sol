// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "./System.sol";
import "../components/OwnerComponent.sol";
import "../libraries/ECS721Lib.sol";

uint256 constant SetApprovalForAllSystemID =
    uint256(keccak256("system.SetApprovalForAll"));

contract SetApprovalForAllSystem is System {
    using ECS721Lib for IUint256Component;

    constructor(IWorld world, address components) System(world, components) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 token, uint256 owner, uint256 operator, bool approved) =
            abi.decode(args, (uint256, uint256, uint256, bool));

        executeTyped(token, owner, operator, approved);
    }

    function executeTyped(
        uint256 token,
        uint256 owner,
        uint256 operator,
        bool approved
    ) public virtual returns (bytes memory) {
        uint256 sender = addressToEntity(_msgSender());
        require(
            sender == owner || sender == token, "Caller is not owner or token"
        );
        addressToEntity(_msgSender());
        COMPONENTS._setApprovalForAll(token, owner, operator, approved);
    }
}
