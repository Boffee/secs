// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "solecs/interfaces/ISystem.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/interfaces/IWorld.sol";
import "solecs/Ownable.sol";

bytes4 constant EXECUTE_SELECTOR = bytes4(keccak256("execute(bytes)"));

abstract contract System is ISystem, Ownable, Context {
    IUint256Component public immutable COMPONENTS;
    IWorld public immutable WORLD;
    uint256 public immutable ID;

    constructor(IWorld world, uint256 id) {
        COMPONENTS = world.components();
        WORLD = world;
        ID = id;
        world.registerSystem(address(this), id);
    }
}
