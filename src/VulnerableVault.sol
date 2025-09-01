// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // this will be called again and again for reentrant attack
    function withdraw() external {
        uint256 bal = balances[msg.sender];
        require(bal > 0, "no balance");
        // this one when called initialise receive or falback that call this withdraw again and again
        (bool ok, ) = msg.sender.call{value: bal}("");
        require(ok, "send failed");
        // state update happens too late
        balances[msg.sender] = 0;
    }
}
