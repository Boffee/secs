// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC20/ERC20ECSLogic.sol";
import "secs/systems/PayableSystem.sol";

uint256 constant ERC20MintPayableSystemID =
    uint256(keccak256("system.ERC20.MintPayable"));

contract ERC20MintPayableSystem is PayableSystem {
    using ERC20ECSLogic for IUint256Component;

    constructor(IWorld world) PayableSystem(world, ERC20MintPayableSystemID) {}

    function execute(bytes memory args)
        public
        payable
        virtual
        returns (bytes memory)
    {
        (uint256 token, uint256 account, uint256 amount) =
            abi.decode(args, (uint256, uint256, uint256));

        executeTyped(token, account, amount);
    }

    function executeTyped(uint256 token, uint256 account, uint256 amount)
        public
        payable
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

function getERC20MintPayableSystem(IUint256Component systems)
    view
    returns (ERC20MintPayableSystem)
{
    return ERC20MintPayableSystem(
        getAddressById(systems, ERC20MintPayableSystemID)
    );
}

function deployERC20MintPayableSystem(IWorld world) {
    address system = address(new ERC20MintPayableSystem(world));

    IUint256Component components = world.components();
    getAllowanceComponent(components).authorizeWriter(system);
    getBalanceComponent(components).authorizeWriter(system);
}
