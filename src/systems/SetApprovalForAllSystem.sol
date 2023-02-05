// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "./System.sol";
import "../components/OwnerComponent.sol";
import "../libraries/ComponentGetter.sol";
import "../libraries/Permission.sol";

uint256 constant SetApprovalForAllSystemID = uint256(
    keccak256("system.SetApprovalForAll")
);

contract SetApprovalForAllSystem is System {
    using ComponentGetter for IUint256Component;
    using Permission for IUint256Component;

    constructor(IWorld world, address components) System(world, components) {}

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 token, uint256 operator, bool approved) = abi.decode(
            args,
            (uint256, uint256, bool)
        );

        executeTyped(token, operator, approved);
    }

    function executeTyped(
        uint256 token,
        uint256 operator,
        bool approved
    ) public virtual returns (bytes memory) {
        _setApprovalForAll(
            token,
            addressToEntity(_msgSender()),
            operator,
            approved
        );
    }

    function _setApprovalForAll(
        uint256 token,
        uint256 owner,
        uint256 operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "Approve to caller");

        if (approved) {
            COMPONENTS.operatorApprovalComponent().set(
                hashEntities(token, owner, operator)
            );
        } else {
            COMPONENTS.operatorApprovalComponent().remove(
                hashEntities(token, owner, operator)
            );
        }
    }
}
