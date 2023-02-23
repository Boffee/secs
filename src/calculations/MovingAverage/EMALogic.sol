// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "solmate/utils/SignedWadMath.sol";
import "./components/MovingAverageComponent.sol";

library EMALogic {
    function _updateEMA(
        IUint256Component components,
        uint256 id,
        uint256 amount
    ) internal {
        MovingAverageComponent movingAverageComponent =
            getMovingAverageComponent(components);

        MovingAverageData memory ma = movingAverageComponent.getValue(id);

        uint256 timeSinceLastUpdate =
            Math.max(block.timestamp - ma.lastUpdateTimestamp, 1);
        uint256 newValue = updateEMA(
            ma.value,
            amount / timeSinceLastUpdate,
            (timeSinceLastUpdate * 1e18) / ma.window
        );

        movingAverageComponent.set(
            id,
            MovingAverageData({
                value: uint128(newValue),
                window: ma.window,
                lastUpdateTimestamp: uint40(block.timestamp)
            })
        );
    }
}

function updateEMA(uint256 curr, uint256 update, uint256 discreteWeight)
    pure
    returns (uint256)
{
    uint256 continuousWeight = 1e18 - uint256(wadExp(-int256(discreteWeight)));
    return unsafeUpdateEMA(curr, update, continuousWeight);
}

function unsafeUpdateEMA(uint256 curr, uint256 update, uint256 weight)
    pure
    returns (uint256)
{
    return (curr * (1e18 - weight) + update * weight) / 1e18;
}
