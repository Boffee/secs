// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import "./IECS721Hooks.sol";

interface IECS721 is IERC721Metadata, IECS721Hooks {
    function burn(uint256 tokenId) external;
}
