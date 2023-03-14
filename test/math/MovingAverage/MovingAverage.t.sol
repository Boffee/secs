// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "solecs/World.sol";
import "secs/math/MovingAverage/EMALogic.sol";

contract MovingAverageTest is Test {
    using EMALogic for IUint256Component;

    IWorld world;
    MovingAverageComponent maComponent;

    function setUp() public virtual {
        world = new World();
        world.init();
        maComponent = new MovingAverageComponent(address(world));
        maComponent.authorizeWriter(address(this));
    }

    function testSerialize(
        uint128 value,
        uint40 window,
        uint40 lastUpdateTimestamp
    ) public {
        bytes memory data = MovingAverageDataLib.serialize(
            MovingAverageData(value, window, lastUpdateTimestamp)
        );
        MovingAverageData memory ma = MovingAverageDataLib.deserialize(data);
        assertEq(ma.value, value);
        assertEq(ma.window, window);
        assertEq(ma.lastUpdateTimestamp, lastUpdateTimestamp);
    }

    function testUpdateEMA() public {
        maComponent.set(
            1, MovingAverageData(0, 1 days, uint40(block.timestamp))
        );

        MovingAverageData memory ma = maComponent.getValue(1);
        assertEq(ma.value, 0);
        assertEq(ma.window, 1 days);
        assertEq(ma.lastUpdateTimestamp, uint40(block.timestamp));

        world.components()._updateEMA(1, 42e18);

        ma = maComponent.getValue(1);
        assertApproxEqRel(ma.value, uint256(42e18) / 1 days, 1e15);
        assertEq(ma.window, 1 days);
        assertEq(ma.lastUpdateTimestamp, uint40(block.timestamp));

        uint256 oldValue = ma.value;

        vm.warp(block.timestamp + 1 days);
        world.components()._updateEMA(1, 2e18);

        ma = maComponent.getValue(1);
        // weight = 1 - e^-1 = 0.632
        // value = oldValue * (1 - weight) + 2e18 * weight
        assertApproxEqRel(
            ma.value,
            (oldValue * (1e18 - 0.632e18) + uint256(2e18) / 1 days * 0.632e18)
                / 1e18,
            1e15
        );
        assertEq(ma.window, 1 days);
        assertEq(ma.lastUpdateTimestamp, uint40(block.timestamp));
    }
}
