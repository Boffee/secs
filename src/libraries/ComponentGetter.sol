// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";
import "../components/AllowanceComponent.sol";
import "../components/ApprovalComponent.sol";
import "../components/BalanceComponent.sol";
import "../components/DescriptionComponent.sol";
import "../components/NameComponent.sol";
import "../components/OperatorApprovalComponent.sol";
import "../components/OwnerComponent.sol";
import "../components/SymbolComponent.sol";
import "../components/TotalSupplyComponent.sol";

library ComponentGetter {
    function allowanceComponent(IUint256Component components)
        internal
        view
        returns (AllowanceComponent)
    {
        return
            AllowanceComponent(getAddressById(components, AllowanceComponentID));
    }

    function approvalComponent(IUint256Component components)
        internal
        view
        returns (ApprovalComponent)
    {
        return
            ApprovalComponent(getAddressById(components, ApprovalComponentID));
    }

    function balanceComponent(IUint256Component components)
        internal
        view
        returns (BalanceComponent)
    {
        return BalanceComponent(getAddressById(components, BalanceComponentID));
    }

    function descriptionComponent(IUint256Component components)
        internal
        view
        returns (DescriptionComponent)
    {
        return DescriptionComponent(
            getAddressById(components, DescriptionComponentID)
        );
    }

    function nameComponent(IUint256Component components)
        internal
        view
        returns (NameComponent)
    {
        return NameComponent(getAddressById(components, NameComponentID));
    }

    function ownerComponent(IUint256Component components)
        internal
        view
        returns (OwnerComponent)
    {
        return OwnerComponent(getAddressById(components, OwnerComponentID));
    }

    function operatorApprovalComponent(IUint256Component components)
        internal
        view
        returns (OperatorApprovalComponent)
    {
        return OperatorApprovalComponent(
            getAddressById(components, OperatorApprovalComponentID)
        );
    }

    function symbolComponent(IUint256Component components)
        internal
        view
        returns (SymbolComponent)
    {
        return SymbolComponent(getAddressById(components, SymbolComponentID));
    }

    function totalSupplyComponent(IUint256Component components)
        internal
        view
        returns (TotalSupplyComponent)
    {
        return TotalSupplyComponent(
            getAddressById(components, TotalSupplyComponentID)
        );
    }
}
