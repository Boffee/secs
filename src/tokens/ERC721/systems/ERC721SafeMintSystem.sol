// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLib.sol";
import "secs/systems/System.sol";

uint256 constant ERC721SafeMintSystemID =
    uint256(keccak256("system.ERC721.SafeMint"));

contract ERC721SafeMintSystem is System {
    using ERC721ECSLib for IUint256Component;

    constructor(IWorld world) System(world, ERC721SafeMintSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 to, uint256 entity, bytes memory data) =
            abi.decode(args, (uint256, uint256, bytes));

        executeTyped(to, entity, data);
    }

    function executeTyped(uint256 to, uint256 entity, bytes memory data)
        public
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

function getERC721SafeMintSystem(IUint256Component systems)
    view
    returns (ERC721SafeMintSystem)
{
    return ERC721SafeMintSystem(getAddressById(systems, ERC721SafeMintSystemID));
}

function deployERC721SafeMintSystem(IWorld world) {
    address system = address(new ERC721SafeMintSystem(world));

    IUint256Component components = world.components();
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
