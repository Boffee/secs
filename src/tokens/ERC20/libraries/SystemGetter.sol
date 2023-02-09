// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/utils.sol";
import "../systems/ApproveSystem.sol";
import "../systems/BurnFromSystem.sol";
import "../systems/TransferFromSystem.sol";

library SystemGetter {
    function approveSystem(IUint256Component systems)
        internal
        view
        returns (ApproveSystem)
    {
        return ApproveSystem(getAddressById(systems, ApproveSystemID));
    }

    function burnFromSystem(IUint256Component systems)
        internal
        view
        returns (BurnFromSystem)
    {
        return BurnFromSystem(getAddressById(systems, BurnFromSystemID));
    }

    function transferFromSystem(IUint256Component systems)
        internal
        view
        returns (TransferFromSystem)
    {
        return TransferFromSystem(getAddressById(systems, TransferFromSystemID));
    }
}
