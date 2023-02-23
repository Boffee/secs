// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "secs/tokens/ERC20/ERC20ECS.sol";
import "secs/tokens/ERC20/systems/MintSystem.sol";
import "secs/tokens/ERC20/systems/BurnFromSystem.sol";

contract MockERC20ECS is ERC20ECS {
    using SystemDelegateCall for address;

    constructor(IWorld world) ERC20ECS(world) {}

    function mint(address to, uint256 value) public {
        address(getMintSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(thisEntity(), to, value)
        );
    }
}
