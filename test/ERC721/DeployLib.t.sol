// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./DeployLib.sol";

contract DeployLibTest is Test {
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

        component = approvalComponent(components);
        assertEq(component.world(), address(world));

        component = balanceComponent(components);
        assertEq(component.world(), address(world));

        component = nameComponent(components);
        assertEq(component.world(), address(world));

        component = operatorApprovalComponent(components);
        assertEq(component.world(), address(world));

        component = ownerComponent(components);
        assertEq(component.world(), address(world));

        component = symbolComponent(components);
        assertEq(component.world(), address(world));
    }

    function testSystems() public {
        IUint256Component systems = world.systems();
        System system;

        system = approveSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = burnSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = safeTransferFromSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = setApprovalForAllSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = transferFromSystem(systems);
        assertEq(address(system.WORLD()), address(world));
    }
}
