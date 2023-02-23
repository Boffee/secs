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
        address approveSystem = address(new ApproveSystem(world));
        authorizeWriter(world, AllowanceComponentID, approveSystem);

        address mintSystem = address(new MintSystem(world));
        authorizeWriter(world, BalanceComponentID, mintSystem);

        address burnFromSystem = address(new BurnFromSystem(world));
        authorizeWriter(world, AllowanceComponentID, burnFromSystem);
        authorizeWriter(world, BalanceComponentID, burnFromSystem);

        address transferFromSystem = address(new TransferFromSystem(world));
        authorizeWriter(world, AllowanceComponentID, transferFromSystem);
        authorizeWriter(world, BalanceComponentID, transferFromSystem);
    }

    function deployERC20ECS(IWorld world)
        internal
        returns (MockERC20ECS erc20)
    {
        erc20 = new MockERC20ECS(world);
        authorizeWriter(world, AllowanceComponentID, address(erc20));
        authorizeWriter(world, BalanceComponentID, address(erc20));
        authorizeWriter(world, NameComponentID, address(erc20));
        authorizeWriter(world, SymbolComponentID, address(erc20));
        authorizeWriter(world, TotalSupplyComponentID, address(erc20));
    }
}
