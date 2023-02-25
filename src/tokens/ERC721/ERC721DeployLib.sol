// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {World} from "solecs/world.sol";
import "./systems/ERC721MintSystem.sol";
import "./systems/ERC721SafeMintSystem.sol";
import "./ERC721ECS.sol";

library ERC721DeployLib {
    function deploy() internal returns (IWorld world) {
        world = new World();
        world.init();
        deployComponents(world);
        deploySystems(world);
    }

    function deployComponents(IWorld world) internal {
        deployApprovalComponent(world);
        deployBalanceComponent(world);
        deployNameComponent(world);
        deployOperatorApprovalComponent(world);
        deployOwnerComponent(world);
        deploySymbolComponent(world);
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

    function configERC721ECS(
        ERC721ECS erc721,
        string memory name,
        string memory symbol
    ) internal {
        IUint256Component components = erc721.COMPONENTS();
        getApprovalComponent(components).authorizeWriter(address(erc721));
        getBalanceComponent(components).authorizeWriter(address(erc721));
        getNameComponent(components).authorizeWriter(address(erc721));
        getOperatorApprovalComponent(components).authorizeWriter(
            address(erc721)
        );
        getOwnerComponent(components).authorizeWriter(address(erc721));
        getSymbolComponent(components).authorizeWriter(address(erc721));

        erc721.setName(name);
        erc721.setSymbol(symbol);
    }
}
