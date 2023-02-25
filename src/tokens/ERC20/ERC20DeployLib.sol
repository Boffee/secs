// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/world.sol";
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
        deployAllowanceComponent(world);
        deployBalanceComponent(world);
        deployNameComponent(world);
        deploySymbolComponent(world);
        deployTotalSupplyComponent(world);
    }

    function deploySystems(IWorld world) internal {
        deployERC20ApproveSystem(world);
        deployERC20MintSystem(world);
        deployERC20BurnFromSystem(world);
        deployERC20TransferFromSystem(world);
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
