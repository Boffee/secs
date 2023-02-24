// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC20/ERC20ECSLib.sol";
import "secs/systems/System.sol";

uint256 constant ERC20MintSystemID = uint256(keccak256("system.ERC20.Mint"));

contract ERC20MintSystem is System {
    using ERC20ECSLib for IUint256Component;

    constructor(IWorld world) System(world, ERC20MintSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 token, uint256 account, uint256 amount) =
            abi.decode(args, (uint256, uint256, uint256));

        executeTyped(token, account, amount);
    }

    function executeTyped(uint256 token, uint256 account, uint256 amount)
        public
        virtual
    {
        if (addressToEntity(address(this)) != token) {
            COMPONENTS._spendAllowance(
                token, token, addressToEntity(_msgSender()), amount
            );
        }
        COMPONENTS._mint(token, account, amount);
    }
}

function getERC20MintSystem(IUint256Component systems)
    view
    returns (ERC20MintSystem)
{
    return ERC20MintSystem(getAddressById(systems, ERC20MintSystemID));
}

function deployERC20MintSystem(IWorld world) {
    address system = address(new ERC20MintSystem(world));

    IUint256Component components = world.components();
    getAllowanceComponent(components).authorizeWriter(system);
    getBalanceComponent(components).authorizeWriter(system);
}
