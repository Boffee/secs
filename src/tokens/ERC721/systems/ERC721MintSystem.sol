// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC721/ERC721ECSLib.sol";
import "secs/systems/System.sol";

uint256 constant ERC721MintSystemID = uint256(keccak256("system.ERC721.Mint"));

contract ERC721MintSystem is System {
    using ERC721ECSLib for IUint256Component;

    constructor(IWorld world) System(world, ERC721MintSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 to, uint256 entity) = abi.decode(args, (uint256, uint256));

        executeTyped(to, entity);
    }

    function executeTyped(uint256 to, uint256 entity) public virtual {
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

function getERC721MintSystem(IUint256Component systems)
    view
    returns (ERC721MintSystem)
{
    return ERC721MintSystem(getAddressById(systems, ERC721MintSystemID));
}

function deployERC721MintSystem(IWorld world) {
    address system = address(new ERC721MintSystem(world));

    IUint256Component components = world.components();
    getBalanceComponent(components).authorizeWriter(system);
    getOwnerComponent(components).authorizeWriter(system);
}
