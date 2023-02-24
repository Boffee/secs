// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console2.sol";
import "solecs/World.sol";
import "./mocks/MockERC20ECS.sol";

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
        new AllowanceComponent(address(world));
        new BalanceComponent(address(world));
        new NameComponent(address(world));
        new SymbolComponent(address(world));
        new TotalSupplyComponent(address(world));
    }

    function deploySystems(IWorld world) internal {
        deployERC20ApproveSystem(world);
        deployERC20MintSystem(world);
        deployERC20BurnFromSystem(world);
        deployERC20TransferFromSystem(world);
    }

    function deployERC20ECS(
        IWorld world,
        string memory name,
        string memory symbol
    ) internal returns (MockERC20ECS erc20) {
        erc20 = new MockERC20ECS(world);
        configERC20ECS(erc20, name, symbol);
    }
}
