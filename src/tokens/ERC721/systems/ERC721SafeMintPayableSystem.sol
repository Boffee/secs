// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLogic.sol";
import "secs/systems/PayableSystem.sol";

uint256 constant SafeERC721MintPayableSystemID =
    uint256(keccak256("system.ERC721.SafeMintPayable"));

contract SafeERC721MintPayableSystem is PayableSystem {
    using ERC721ECSLogic for IUint256Component;

    constructor(IWorld world)
        PayableSystem(world, SafeERC721MintPayableSystemID)
    {}

    function execute(bytes memory args)
        public
        payable
        virtual
        returns (bytes memory)
    {
        (uint256 to, uint256 entity, bytes memory data) =
            abi.decode(args, (uint256, uint256, bytes));

        executeTyped(to, entity, data);
    }

    function executeTyped(uint256 to, uint256 entity, bytes memory data)
        public
        payable
        virtual
    {
        uint256 token = getEntityToken(entity);
        uint256 operator = addressToEntity(_msgSender());
        if (addressToEntity(address(this)) != token) {
            require(
                COMPONENTS.isApprovedForAll(token, token, operator),
                "Caller is not approved"
            );
        }
        COMPONENTS._safeMint(operator, to, entity, data);
    }
}

function getSafeERC721MintPayableSystem(IUint256Component systems)
    view
    returns (SafeERC721MintPayableSystem)
{
    return SafeERC721MintPayableSystem(
        getAddressById(systems, SafeERC721MintPayableSystemID)
    );
}

function deploySafeERC721MintPayableSystem(IWorld world) {
    address system = address(new SafeERC721MintPayableSystem(world));

    IUint256Component components = world.components();
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
