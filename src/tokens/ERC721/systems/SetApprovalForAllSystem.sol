// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ECS721Lib.sol";
import "secs/systems/System.sol";

uint256 constant SetApprovalForAllSystemID =
    uint256(keccak256("system.ERC721.SetApprovalForAll"));

contract SetApprovalForAllSystem is System {
    using ECS721Lib for IUint256Component;

    constructor(IWorld world) System(world, SetApprovalForAllSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 token, uint256 operator, bool approved) =
            abi.decode(args, (uint256, uint256, bool));

        executeTyped(token, operator, approved);
    }

    function executeTyped(uint256 token, uint256 operator, bool approved)
        public
        virtual
        returns (bytes memory)
    {
        COMPONENTS._setApprovalForAll(
            token, addressToEntity(_msgSender()), operator, approved
        );
    }
}