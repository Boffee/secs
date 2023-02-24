// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLogic.sol";
import "secs/systems/PayableSystem.sol";

uint256 constant ERC721MintPayableSystemID =
    uint256(keccak256("system.ERC721.MintPayable"));

contract ERC721MintPayableSystem is PayableSystem {
    using ERC721ECSLogic for IUint256Component;

    constructor(IWorld world) PayableSystem(world, ERC721MintPayableSystemID) {}

    function execute(bytes memory args)
        public
        payable
        virtual
        returns (bytes memory)
    {
        (uint256 to, uint256 entity) = abi.decode(args, (uint256, uint256));

        executeTyped(to, entity);
    }

    function executeTyped(uint256 to, uint256 entity) public payable virtual {
        uint256 token = getEntityToken(entity);
        if (addressToEntity(address(this)) != token) {
            require(
                COMPONENTS.isApprovedForAll(
                    token, token, addressToEntity(_msgSender())
                ),
                "Caller is not approved"
            );
        }
        COMPONENTS._mint(to, entity);
    }
}

function getERC721MintPayableSystem(IUint256Component systems)
    view
    returns (ERC721MintPayableSystem)
{
    return ERC721MintPayableSystem(
        getAddressById(systems, ERC721MintPayableSystemID)
    );
}

function deployERC721MintPayableSystem(IWorld world) {
    address system = address(new ERC721MintPayableSystem(world));

    IUint256Component components = world.components();
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
