// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/ISystem.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/interfaces/IWorld.sol";
import "solecs/Ownable.sol";
import "../utils/Context.sol";

abstract contract System is ISystem, Ownable, Context {
    IUint256Component public immutable COMPONENTS;
    IWorld public immutable WORLD;

    constructor(IWorld world, address components) {
        COMPONENTS = components == address(0)
            ? world.components()
            : IUint256Component(components);
        WORLD = world;
    }
}