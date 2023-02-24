// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "solecs/World.sol";
import "secs/tokens/ERC721/DeployLib.sol";

contract DeployLibTest is Test {
    IWorld world;

    function setUp() public virtual {
        world = new World();
        world.init();
        DeployLib.deployComponents(world);
        DeployLib.deploySystems(world);
    }

    function testWorld() public {
        assertTrue(address(world) != address(0));
    }

    function testComponents() public {
        IUint256Component components = world.components();
        IComponent component;

        component = getApprovalComponent(components);
        assertEq(component.world(), address(world));

        component = getBalanceComponent(components);
        assertEq(component.world(), address(world));

        component = getNameComponent(components);
        assertEq(component.world(), address(world));

        component = getOperatorApprovalComponent(components);
        assertEq(component.world(), address(world));

        component = getOwnerComponent(components);
        assertEq(component.world(), address(world));

        component = getSymbolComponent(components);
        assertEq(component.world(), address(world));
    }

    function testSystems() public {
        IUint256Component systems = world.systems();
        System system;

        system = getERC721ApproveSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = getERC721BurnSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = getERC721SafeTransferFromSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = getERC721SetApprovalForAllSystem(systems);
        assertEq(address(system.WORLD()), address(world));

        system = getERC721TransferFromSystem(systems);
        assertEq(address(system.WORLD()), address(world));
    }
}
