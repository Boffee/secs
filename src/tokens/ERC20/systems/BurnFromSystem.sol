// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC20/ECS20Lib.sol";
import "secs/systems/System.sol";

uint256 constant BurnFromSystemID = uint256(keccak256("system.ERC20.BurnFrom"));

contract BurnFromSystem is System {
    using ECS20Lib for IUint256Component;

    constructor(IWorld world) System(world, BurnFromSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 token, uint256 account, uint256 amount) =
            abi.decode(args, (uint256, uint256, uint256));

        return abi.encode(executeTyped(token, account, amount));
    }

    function executeTyped(uint256 token, uint256 account, uint256 amount)
        public
        virtual
        returns (bool)
    {
        uint256 spender = addressToEntity(_msgSender());
        if (spender != account) {
            COMPONENTS._spendAllowance(token, account, spender, amount);
        }
        COMPONENTS._burn(token, account, amount);
        return true;
    }
}

function getBurnFromSystem(IUint256Component systems)
    view
    returns (BurnFromSystem)
{
    return BurnFromSystem(getAddressById(systems, BurnFromSystemID));
}
