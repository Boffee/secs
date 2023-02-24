// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./systems/ERC20MintSystem.sol";
import "./ERC20ECS.sol";

library DeployLib {
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
}
