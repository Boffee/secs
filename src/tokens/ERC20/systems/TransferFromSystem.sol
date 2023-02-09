// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "secs/tokens/ERC20/ECS20Lib.sol";
import "secs/systems/System.sol";

uint256 constant TransferFromSystemID =
    uint256(keccak256("system.ERC20.TransferFrom"));

contract TransferFromSystem is System {
    using ECS20Lib for IUint256Component;

    constructor(IWorld world) System(world, TransferFromSystemID) {}

    function execute(bytes memory args) public returns (bytes memory) {
        (uint256 token, uint256 from, uint256 to, uint256 amount) =
            abi.decode(args, (uint256, uint256, uint256, uint256));

        return abi.encode(executeTyped(token, from, to, amount));
    }

    function executeTyped(
        uint256 token,
        uint256 from,
        uint256 to,
        uint256 amount
    ) public returns (bool) {
        uint256 spender = addressToEntity(_msgSender());
        if (spender != from) {
            COMPONENTS._spendAllowance(token, from, spender, amount);
        }
        COMPONENTS._transfer(token, from, to, amount);
        return true;
    }
}
