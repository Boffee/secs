// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../systems/System.sol";
import "./DelegateCall.sol";

library SystemDelegateCall {
    using DelegateCall for address;

    function systemDelegateCall(address system, bytes memory args)
        internal
        returns (bytes memory)
    {
        return system.functionDelegateCall(
            abi.encodeWithSelector(EXECUTE_SELECTOR, args)
        );
    }
}
