// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IECS721Hooks {
    function beforeTokenTransfer(uint256 from, uint256 to, uint256 entity)
        external;

    function afterTokenTransfer(uint256 from, uint256 to, uint256 entity)
        external;

    function afterApproval(uint256 owner, uint256 approved, uint256 entity) external;

    function afterApprovalForAll(uint256 owner, uint256 operator, bool approved) external;
}
