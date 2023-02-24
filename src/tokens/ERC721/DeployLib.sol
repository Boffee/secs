// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./systems/ERC721MintSystem.sol";
import "./systems/ERC721SafeMintSystem.sol";
import "./ERC721ECS.sol";

library DeployLib {
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
}
