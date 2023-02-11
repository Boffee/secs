// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "./IECS20Hooks.sol";

interface IECS20 is IERC20, IERC165, IECS20Hooks {
    function burn(address account, uint256 amount) external returns (bool);

    function burn(uint256 account, uint256 amount) external returns (bool);

    function balanceOf(uint256 account) external view returns (uint256);

    function transfer(uint256 to, uint256 amount) external returns (bool);

    function allowance(uint256 owner, uint256 spender)
        external
        view
        returns (uint256);

    function approve(uint256 spender, uint256 amount) external returns (bool);

    function transferFrom(uint256 from, uint256 to, uint256 amount)
        external
        returns (bool);
}
