// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import "./IERC721ECSHooks.sol";

interface IERC721ECS is IERC721Metadata, IERC721ECSHooks {
    function burn(uint256 tokenId) external;

    function balanceOf(uint256 account) external view returns (uint256);

    function safeTransferFrom(
        uint256 from,
        uint256 to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(uint256 from, uint256 to, uint256 tokenId)
        external;

    function transferFrom(uint256 from, uint256 to, uint256 tokenId) external;

    function approve(uint256 to, uint256 tokenId) external;

    function setApprovalForAll(uint256 operator, bool _approved) external;

    function isApprovedForAll(uint256 owner, uint256 operator)
        external
        view
        returns (bool);
}
