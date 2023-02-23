// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console2.sol";
import "solecs/World.sol";
import "./mocks/MockERC20ECS.sol";

library DeployLib {
    function deploy() internal returns (IWorld world) {
        world = new World();
        world.init();
        deployComponents(world);
        deploySystems(world);
        configERC20ECS(world, deployERC20ECS(world));
    }

    function authorizeWriter(IWorld world, uint256 componentId, address writer)
        internal
    {
        IComponent(getAddressById(world.components(), componentId))
            .authorizeWriter(writer);
    }

    function deployComponents(IWorld world) internal {
        new AllowanceComponent(address(world));
        new BalanceComponent(address(world));
        new NameComponent(address(world));
        new SymbolComponent(address(world));
        new TotalSupplyComponent(address(world));
    }

    function deploySystems(IWorld world) internal {
        address approveSystem = address(new ApproveSystem(world));
        authorizeWriter(world, AllowanceComponentID, approveSystem);

        address burnFromSystem = address(new BurnFromSystem(world));
        authorizeWriter(world, AllowanceComponentID, burnFromSystem);
        authorizeWriter(world, BalanceComponentID, burnFromSystem);

        address transferFromSystem = address(new TransferFromSystem(world));
        authorizeWriter(world, AllowanceComponentID, transferFromSystem);
        authorizeWriter(world, BalanceComponentID, transferFromSystem);
    }

    function deployERC20ECS(IWorld world) internal returns (ERC20ECS ecs20) {
        return new MockERC20ECS(world);
    }

    function configERC20ECS(IWorld world, ERC20ECS ecs20) internal {
        authorizeWriter(world, AllowanceComponentID, address(ecs20));
        authorizeWriter(world, BalanceComponentID, address(ecs20));
        authorizeWriter(world, NameComponentID, address(ecs20));
        authorizeWriter(world, SymbolComponentID, address(ecs20));
        authorizeWriter(world, TotalSupplyComponentID, address(ecs20));
    }
}
