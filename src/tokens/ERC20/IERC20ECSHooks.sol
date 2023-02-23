// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IERC20ECSHooks {
    function beforeTokenTransfer(uint256 from, uint256 to, uint256 amount)
        external;

    function afterTokenTransfer(uint256 from, uint256 to, uint256 amount)
        external;

    function afterApproval(uint256 owner, uint256 spender, uint256 amount)
        external;
}
