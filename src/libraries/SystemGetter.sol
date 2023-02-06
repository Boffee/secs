// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/utils.sol";
import "../systems/ApproveSystem.sol";
import "../systems/BurnSystem.sol";
import "../systems/SafeTransferFromSystem.sol";
import "../systems/SetApprovalForAllSystem.sol";
import "../systems/TransferFromSystem.sol";

library SystemGetter {
    function approveSystem(IUint256Component systems)
        internal
        view
        returns (ApproveSystem)
    {
        return ApproveSystem(getAddressById(systems, ApproveSystemID));
    }

    function burnSystem(IUint256Component systems)
        internal
        view
        returns (BurnSystem)
    {
        return BurnSystem(getAddressById(systems, BurnSystemID));
    }

    function safeTransferFromSystem(IUint256Component systems)
        internal
        view
        returns (SafeTransferFromSystem)
    {
        return SafeTransferFromSystem(
            getAddressById(systems, SafeTransferFromSystemID)
        );
    }

    function setApprovalForAllSystem(IUint256Component systems)
        internal
        view
        returns (SetApprovalForAllSystem)
    {
        return SetApprovalForAllSystem(
            getAddressById(systems, SetApprovalForAllSystemID)
        );
    }

    function transferFromSystem(IUint256Component systems)
        internal
        view
        returns (TransferFromSystem)
    {
        return TransferFromSystem(getAddressById(systems, TransferFromSystemID));
    }
}
