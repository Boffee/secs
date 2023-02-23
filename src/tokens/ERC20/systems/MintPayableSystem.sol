// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC20/ERC20ECSLib.sol";
import "secs/systems/PayableSystem.sol";

uint256 constant MintPayableSystemID =
    uint256(keccak256("system.ERC20.MintPayable"));

contract MintPayableSystem is PayableSystem {
    using ERC20ECSLib for IUint256Component;

    constructor(IWorld world) PayableSystem(world, MintPayableSystemID) {}

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

function getMintPayableSystem(IUint256Component systems)
    view
    returns (MintPayableSystem)
{
    return MintPayableSystem(getAddressById(systems, MintPayableSystemID));
}
