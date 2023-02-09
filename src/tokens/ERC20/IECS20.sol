// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "./IECS20Hooks.sol";

interface IECS20 is IERC20, IERC165, IECS20Hooks {
    function burn(address account, uint256 amount) external returns (bool);
}
