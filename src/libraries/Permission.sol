// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./ComponentGetter.sol";
import "../utils/entity.sol";

library Permission {
    using ComponentGetter for IUint256Component;

    function isApprovedOrOwner(
        IUint256Component components,
        uint256 spender,
        uint256 entity
    ) internal view returns (bool) {
        uint256 owner = ownerOf(components, entity);
        return owner == spender
            || isApprovedForAll(components, getEntityToken(entity), owner, spender)
            || getApproved(components, entity) == spender;
    }

    function isApprovedForAll(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 operator
    ) internal view returns (bool) {
        return components.operatorApprovalComponent().getValue(
            hashEntities(token, owner, operator)
        );
    }

    function getApproved(IUint256Component components, uint256 entity)
        internal
        view
        returns (uint256)
    {
        return components.approvalComponent().getValue(entity);
    }

    function ownerOf(IUint256Component components, uint256 entity)
        internal
        view
        returns (uint256)
    {
        return components.ownerComponent().getValue(entity);
    }
}
