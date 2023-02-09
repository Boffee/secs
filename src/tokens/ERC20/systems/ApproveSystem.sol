// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC20/ECS20Lib.sol";
import "secs/systems/System.sol";

uint256 constant ApproveSystemID = uint256(keccak256("system.ERC20.Approve"));

contract ApproveSystem is System {
    using ComponentGetter for IUint256Component;
    using ECS20Lib for IUint256Component;

    constructor(IWorld world) System(world, ApproveSystemID) {}

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
