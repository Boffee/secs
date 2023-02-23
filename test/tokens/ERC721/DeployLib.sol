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

        address mintSystem = address(new MintSystem(world));
        authorizeWriter(world, BalanceComponentID, mintSystem);
        authorizeWriter(world, OwnerComponentID, mintSystem);

        address safeMintSystem = address(new SafeMintSystem(world));
        authorizeWriter(world, BalanceComponentID, safeMintSystem);
        authorizeWriter(world, OwnerComponentID, safeMintSystem);

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
        returns (MockERC721ECS erc721)
    {
        erc721 = new MockERC721ECS(world);
        authorizeWriter(world, ApprovalComponentID, address(erc721));
        authorizeWriter(world, BalanceComponentID, address(erc721));
        authorizeWriter(world, NameComponentID, address(erc721));
        authorizeWriter(world, OperatorApprovalComponentID, address(erc721));
        authorizeWriter(world, OwnerComponentID, address(erc721));
        authorizeWriter(world, SymbolComponentID, address(erc721));
    }
}
