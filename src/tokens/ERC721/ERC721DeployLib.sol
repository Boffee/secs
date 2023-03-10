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
        IUint256Component components = world.components();
        if (!isRegistered(components, ApprovalComponentID)) {
            deployApprovalComponent(world);
        }
        if (!isRegistered(components, BalanceComponentID)) {
            deployBalanceComponent(world);
        }
        if (!isRegistered(components, NameComponentID)) {
            deployNameComponent(world);
        }
        if (!isRegistered(components, OperatorApprovalComponentID)) {
            deployOperatorApprovalComponent(world);
        }
        if (!isRegistered(components, OwnerComponentID)) {
            deployOwnerComponent(world);
        }
        if (!isRegistered(components, SymbolComponentID)) {
            deploySymbolComponent(world);
        }
    }

    function deploySystems(IWorld world) internal {
        IUint256Component systems = world.systems();
        if (!isRegistered(systems, ERC721ApproveSystemID)) {
            deployERC721ApproveSystem(world);
        }
        if (!isRegistered(systems, ERC721BurnSystemID)) {
            deployERC721BurnSystem(world);
        }
        if (!isRegistered(systems, ERC721MintSystemID)) {
            deployERC721MintSystem(world);
        }
        if (!isRegistered(systems, ERC721SafeMintSystemID)) {
            deployERC721SafeMintSystem(world);
        }
        if (!isRegistered(systems, ERC721SafeTransferFromSystemID)) {
            deployERC721SafeTransferFromSystem(world);
        }
        if (!isRegistered(systems, ERC721SetApprovalForAllSystemID)) {
            deployERC721SetApprovalForAllSystem(world);
        }
        if (!isRegistered(systems, ERC721TransferFromSystemID)) {
            deployERC721TransferFromSystem(world);
        }
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
