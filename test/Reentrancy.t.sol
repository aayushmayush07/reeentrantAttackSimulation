// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/VulnerableVault.sol";
import "../src/Attacker.sol";

contract ReentrancyTest is Test {
    VulnerableVault vault;
    Attacker attacker;

    address victim = address(0xAAA);
    address controller = address(this); // test contract

    function setUp() public {
        vault = new VulnerableVault();
        attacker = new Attacker(vault);

        // Give the victim and the test contract some ether
        vm.deal(victim, 10 ether);
        vm.deal(controller, 100 ether);

        // Victim deposits 10 ETH into the vault
        vm.startPrank(victim);
        vault.deposit{value: 10 ether}();
        vm.stopPrank();

        // Attacker contract starts with 0; we’ll send it 1 ETH in attack()
        assertEq(address(vault).balance, 10 ether, "vault funded by victim");
    }

    function testReentrancyDrainsVault() public {
        // Fund EOA (the test) and call attack() sending 1 ETH to Attacker
        // The attacker deposits 1 ETH then withdraws repeatedly to drain victim funds
        vm.prank(controller);
        attacker.attack{value: 1 ether}(10); // 10 re-entries → drains 10 ETH + attacker’s own 1 ETH back

        // After the attack:
        // Vault should be empty (10 victim + 1 attacker paid out)
        assertEq(address(vault).balance, 0, "vault drained");

        // Attacker contract should now hold 11 ETH (their 1 ETH + 10 stolen)
        assertEq(address(attacker).balance, 11 ether, "attacker profited");
    }
}
