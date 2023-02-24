// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLogic.sol";
import "secs/systems/System.sol";

uint256 constant ERC721SetApprovalForAllSystemID =
    uint256(keccak256("system.ERC721.SetApprovalForAll"));

contract ERC721SetApprovalForAllSystem is System {
    using ERC721ECSLogic for IUint256Component;

    constructor(IWorld world) System(world, ERC721SetApprovalForAllSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 token, uint256 operator, bool approved) =
            abi.decode(args, (uint256, uint256, bool));

        executeTyped(token, operator, approved);
    }

    function executeTyped(uint256 token, uint256 operator, bool approved)
        public
        virtual
    {
        COMPONENTS._setApprovalForAll(
            token, addressToEntity(_msgSender()), operator, approved
        );
    }
}

function getERC721SetApprovalForAllSystem(IUint256Component systems)
    view
    returns (ERC721SetApprovalForAllSystem)
{
    return ERC721SetApprovalForAllSystem(
        getAddressById(systems, ERC721SetApprovalForAllSystemID)
    );
}

function deployERC721SetApprovalForAllSystem(IWorld world) {
    address system = address(new ERC721SetApprovalForAllSystem(world));

    IUint256Component components = world.components();
    getOperatorApprovalComponent(components).authorizeWriter(system);
}
