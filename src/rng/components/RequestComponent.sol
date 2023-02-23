// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";
import "secs/components/Uint256BareComponent.sol";

uint256 constant RequestComponentID = uint256(keccak256("component.Request"));

contract RequestComponent is Uint256BareComponent {
    constructor(address world)
        Uint256BareComponent(world, RequestComponentID)
    {}
}

function getRequestComponent(IUint256Component components)
    view
    returns (RequestComponent)
{
    return RequestComponent(getAddressById(components, RequestComponentID));
}
