// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library DelegateCall {
    function functionDelegateCall(address to, bytes memory data)
        internal
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = to.delegatecall(data);
        if (success) {
            return returndata;
        } else {
            assembly {
                revert(add(32, returndata), mload(returndata))
            }
        }
    }
}
