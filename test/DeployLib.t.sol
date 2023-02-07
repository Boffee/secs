// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "secs/libraries/ComponentGetter.sol";
import "./DeployLib.sol";

contract DeployLibTest is Test {
    using ComponentGetter for IUint256Component;

    IWorld world;

    function setUp() public virtual {
        world = DeployLib.deploy();
    }

    function testWorld() public {
        assertTrue(address(world) != address(0));
    }

    function testComponents() public {
        IUint256Component components = world.components();
        IComponent component;

        component = components.approvalComponent();
        assertEq(component.world(), address(world));

        component = components.balanceComponent();
        assertEq(component.world(), address(world));

        component = components.nameComponent();
        assertEq(component.world(), address(world));

        component = components.operatorApprovalComponent();
        assertEq(component.world(), address(world));

        component = components.ownerComponent();
        console2.logBytes(components.ownerComponent().getRawValue(123));
        assertEq(component.world(), address(world));

        component = components.symbolComponent();
        assertEq(component.world(), address(world));
    }
}
