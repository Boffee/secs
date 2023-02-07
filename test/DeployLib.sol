// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console2.sol";
import "solecs/World.sol";
import "secs/libraries/ComponentGetter.sol";
import "secs/libraries/SystemGetter.sol";
import "secs/tokens/ECS721.sol";
import "./mocks/MockECS721.sol";

library DeployLib {
    using SystemGetter for IUint256Component;

    function deploy() internal returns (IWorld world) {
        world = new World();
        world.init();
        deployComponents(world);
        deploySystems(world);
        configECS721(world, deployECS721(world));
    }

    function authorizeWriter(IWorld world, uint256 componentId, address writer)
        internal
    {
        IComponent(getAddressById(world.components(), componentId))
            .authorizeWriter(writer);
    }

    function deployComponents(IWorld world) internal {
        new ApprovalComponent( address(world));
        new BalanceComponent( address(world));
        new NameComponent( address(world));
        new OperatorApprovalComponent( address(world));
        new OwnerComponent( address(world));
        new SymbolComponent( address(world));
    }

    function deploySystems(IWorld world) internal {
        address approveSystem = address(new ApproveSystem(world));
        authorizeWriter(world, ApprovalComponentID, approveSystem);

        address burnSystem = address(new BurnSystem(world));
        authorizeWriter(world, ApprovalComponentID, burnSystem);
        authorizeWriter(world, BalanceComponentID, burnSystem);
        authorizeWriter(world, OwnerComponentID, burnSystem);

        address safeTransferFromSystem =
            address(new SafeTransferFromSystem(world));
        authorizeWriter(world, ApprovalComponentID, safeTransferFromSystem);
        authorizeWriter(world, BalanceComponentID, safeTransferFromSystem);
        authorizeWriter(world, OwnerComponentID, safeTransferFromSystem);

        address setApprovalForAllSystem =
            address(new SetApprovalForAllSystem(world));
        authorizeWriter(
            world, OperatorApprovalComponentID, setApprovalForAllSystem
        );

        address transferFromSystem = address(new TransferFromSystem(world));
        authorizeWriter(world, ApprovalComponentID, transferFromSystem);
        authorizeWriter(world, BalanceComponentID, transferFromSystem);
        authorizeWriter(world, OwnerComponentID, transferFromSystem);
    }

    function deployECS721(IWorld world) internal returns (ECS721 ecs721) {
        return new MockECS721(world);
    }

    function configECS721(IWorld world, ECS721 ecs721) internal {
        authorizeWriter(world, ApprovalComponentID, address(ecs721));
        authorizeWriter(world, BalanceComponentID, address(ecs721));
        authorizeWriter(world, NameComponentID, address(ecs721));
        authorizeWriter(world, OperatorApprovalComponentID, address(ecs721));
        authorizeWriter(world, OwnerComponentID, address(ecs721));
        authorizeWriter(world, SymbolComponentID, address(ecs721));

        IUint256Component systems = world.systems();
        ecs721.approveOperator(address(systems.approveSystem()));
        ecs721.approveOperator(address(systems.burnSystem()));
        ecs721.approveOperator(address(systems.safeTransferFromSystem()));
        ecs721.approveOperator(address(systems.setApprovalForAllSystem()));
        ecs721.approveOperator(address(systems.transferFromSystem()));
    }
}
