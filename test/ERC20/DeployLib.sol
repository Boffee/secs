// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console2.sol";
import "solecs/World.sol";
import "secs/ERC20/libraries/SystemGetter.sol";
import "secs/libraries/ComponentGetter.sol";
import "./mocks/MockECS20.sol";

library DeployLib {
    using SystemGetter for IUint256Component;

    function deploy() internal returns (IWorld world) {
        world = new World();
        world.init();
        deployComponents(world);
        deploySystems(world);
        configECS20(world, deployECS20(world));
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
        new OperatorApprovalComponent(address(world));
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

    function deployECS20(IWorld world) internal returns (ECS20 ecs20) {
        return new MockECS20(world);
    }

    function configECS20(IWorld world, ECS20 ecs20) internal {
        authorizeWriter(world, AllowanceComponentID, address(ecs20));
        authorizeWriter(world, BalanceComponentID, address(ecs20));
        authorizeWriter(world, NameComponentID, address(ecs20));
        authorizeWriter(world, OperatorApprovalComponentID, address(ecs20));
        authorizeWriter(world, SymbolComponentID, address(ecs20));
        authorizeWriter(world, TotalSupplyComponentID, address(ecs20));

        IUint256Component systems = world.systems();
        ecs20.approveOperator(address(systems.approveSystem()));
        ecs20.approveOperator(address(systems.burnFromSystem()));
        ecs20.approveOperator(address(systems.transferFromSystem()));
    }
}
