// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "secs/libraries/ComponentGetter.sol";
import "secs/libraries/SystemGetter.sol";
import "./DeployLib.sol";

contract DeployLibTest is Test {
    using ComponentGetter for IUint256Component;
    using SystemGetter for IUint256Component;

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
        assertEq(component.world(), address(world));

        component = components.symbolComponent();
        assertEq(component.world(), address(world));
    }

    function testSystems() public {
        IUint256Component systems = world.systems();
        System system;

        system = systems.approveSystem();
        assertEq(address(system.WORLD()), address(world));

        system = systems.burnSystem();
        assertEq(address(system.WORLD()), address(world));

        system = systems.safeTransferFromSystem();
        assertEq(address(system.WORLD()), address(world));

        system = systems.setApprovalForAllSystem();
        assertEq(address(system.WORLD()), address(world));

        system = systems.transferFromSystem();
        assertEq(address(system.WORLD()), address(world));
    }
}
