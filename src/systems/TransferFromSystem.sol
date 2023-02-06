// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "../libraries/ECS721Lib.sol";
import "../utils/entity.sol";
import "./System.sol";

uint256 constant TransferFromSystemID = uint256(keccak256("system.Transfer"));

contract TransferFromSystem is System {
    using ECS721Lib for IUint256Component;

    constructor(IWorld world, address components) System(world, components) {}

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
