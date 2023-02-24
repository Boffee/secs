// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC20/ERC20ECSLib.sol";
import "secs/systems/System.sol";

uint256 constant ERC20ApproveSystemID =
    uint256(keccak256("system.ERC20.Approve"));

contract ERC20ApproveSystem is System {
    using ERC20ECSLib for IUint256Component;

    constructor(IWorld world) System(world, ERC20ApproveSystemID) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 token, uint256 spender, uint256 amount) =
            abi.decode(args, (uint256, uint256, uint256));

        return abi.encode(executeTyped(token, spender, amount));
    }

    function executeTyped(uint256 token, uint256 spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        COMPONENTS._approve(
            token, addressToEntity(_msgSender()), spender, amount
        );
        return true;
    }
}

function getERC20ApproveSystem(IUint256Component systems)
    view
    returns (ERC20ApproveSystem)
{
    return ERC20ApproveSystem(getAddressById(systems, ERC20ApproveSystemID));
}

function deployERC20ApproveSystem(IWorld world) {
    address system = address(new ERC20ApproveSystem(world));

    IUint256Component components = world.components();
    getAllowanceComponent(components).authorizeWriter(system);
}
