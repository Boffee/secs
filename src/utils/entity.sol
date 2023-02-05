// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

function tokenToEntity(address token, uint256 id) pure returns (uint256) {
    return (uint256(uint160(token)) << 96) | id;
}

function entityToToken(uint256 entity)
    pure
    returns (address token, uint256 id)
{
    token = getEntityTokenAddress(entity);
    id = getEntityId(entity);
}

function accountToEntity(address account) pure returns (uint256) {
    return (uint256(uint160(account)));
}

function entityToAccount(uint256 entity) pure returns (address account) {
    account = address(uint160(entity));
}

function entityIsAccount(uint256 entity) pure returns (bool) {
    return entity >> 160 == 0;
}

function hashEntities(uint256 a, uint256 b) pure returns (uint256) {
    return uint256(keccak256(abi.encode(a, b)));
}

function hashEntities(uint256 a, uint256 b, uint256 c) pure returns (uint256) {
    return uint256(keccak256(abi.encode(a, b, c)));
}

function getEntityTokenAddress(uint256 entity) pure returns (address) {
    return address(uint160(entity >> 96));
}

function getEntityToken(uint256 entity) pure returns (uint256) {
    return entity >> 96;
}

function getEntityId(uint256 entity) pure returns (uint256) {
    return entity & 0xffffffffffffffffffffffff;
}
