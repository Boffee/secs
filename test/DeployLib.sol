// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console2.sol";
import "solecs/World.sol";
import "secs/libraries/ComponentGetter.sol";
import "secs/libraries/SystemGetter.sol";
import "secs/tokens/ECS721.sol";
import "./mocks/MockECS721.sol";

library DeployLib {
    function deploy() internal returns (IWorld world) {
        world = new World();
        world.init();
        deployComponents(world);
        deploySystems(world);
        deployECS721(world);
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

    function deployECS721(IWorld world) internal {
        address ecs721 = address(new MockECS721(world));
        authorizeWriter(world, ApprovalComponentID, ecs721);
        authorizeWriter(world, BalanceComponentID, ecs721);
        authorizeWriter(world, NameComponentID, ecs721);
        authorizeWriter(world, OperatorApprovalComponentID, ecs721);
        authorizeWriter(world, OwnerComponentID, ecs721);
        authorizeWriter(world, SymbolComponentID, ecs721);
    }
}
