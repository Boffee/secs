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
        deployERC721ApproveSystem(world);
        deployERC721BurnSystem(world);
        deployERC721MintSystem(world);
        deployERC721SafeMintSystem(world);
        deployERC721SafeTransferFromSystem(world);
        deployERC721SetApprovalForAllSystem(world);
        deployERC721TransferFromSystem(world);
    }

    function deployERC721ECS(
        IWorld world,
        string memory name,
        string memory symbol
    ) internal returns (MockERC721ECS erc721) {
        erc721 = new MockERC721ECS(world);
        configERC721ECS(erc721, name, symbol);
    }
}
