// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {World} from "solecs/world.sol";
import "./systems/ERC20MintSystem.sol";
import "./ERC20ECS.sol";

library ERC20DeployLib {
    function deploy() internal returns (IWorld world) {
        world = new World();
        world.init();
        deployComponents(world);
        deploySystems(world);
    }

    function deployComponents(IWorld world) internal {
        IUint256Component components = world.components();
        if (!isRegistered(components, AllowanceComponentID)) {
            deployAllowanceComponent(world);
        }
        if (!isRegistered(components, BalanceComponentID)) {
            deployBalanceComponent(world);
        }
        if (!isRegistered(components, NameComponentID)) {
            deployNameComponent(world);
        }
        if (!isRegistered(components, SymbolComponentID)) {
            deploySymbolComponent(world);
        }
        if (!isRegistered(components, TotalSupplyComponentID)) {
            deployTotalSupplyComponent(world);
        }
    }

    function deploySystems(IWorld world) internal {
        IUint256Component systems = world.systems();
        if (!isRegistered(systems, ERC20ApproveSystemID)) {
            deployERC20ApproveSystem(world);
        }
        if (!isRegistered(systems, ERC20MintSystemID)) {
            deployERC20MintSystem(world);
        }
        if (!isRegistered(systems, ERC20BurnFromSystemID)) {
            deployERC20BurnFromSystem(world);
        }
        if (!isRegistered(systems, ERC20TransferFromSystemID)) {
            deployERC20TransferFromSystem(world);
        }
    }

    function configERC20ECS(
        ERC20ECS erc20,
        string memory name,
        string memory symbol
    ) internal {
        IUint256Component components = erc20.COMPONENTS();
        getAllowanceComponent(components).authorizeWriter(address(erc20));
        getBalanceComponent(components).authorizeWriter(address(erc20));
        getNameComponent(components).authorizeWriter(address(erc20));
        getSymbolComponent(components).authorizeWriter(address(erc20));
        getTotalSupplyComponent(components).authorizeWriter(address(erc20));

        erc20.setName(name);
        erc20.setSymbol(symbol);
    }
}
