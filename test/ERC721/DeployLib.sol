// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console2.sol";
import "solecs/World.sol";
import "./mocks/MockERC721ECS.sol";

library DeployLib {
    function deploy() internal returns (IWorld world) {
        world = new World();
        world.init();
        deployComponents(world);
        deploySystems(world);
        configERC721ECS(world, deployERC721ECS(world));
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

    function deployERC721ECS(IWorld world)
        internal
        returns (ERC721ECS ecs721)
    {
        return new MockERC721ECS(world);
    }

    function configERC721ECS(IWorld world, ERC721ECS ecs721) internal {
        authorizeWriter(world, ApprovalComponentID, address(ecs721));
        authorizeWriter(world, BalanceComponentID, address(ecs721));
        authorizeWriter(world, NameComponentID, address(ecs721));
        authorizeWriter(world, OperatorApprovalComponentID, address(ecs721));
        authorizeWriter(world, OwnerComponentID, address(ecs721));
        authorizeWriter(world, SymbolComponentID, address(ecs721));
    }
}
