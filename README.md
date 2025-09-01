# 🛡️ Reentrancy Attack Simulation

This repository demonstrates how a **reentrancy attack** works in Solidity using [Foundry](https://book.getfoundry.sh/).  
It contains:
- A vulnerable vault (`VulnerableVault.sol`)
- An attacker contract (`Attacker.sol`)
- A Foundry test (`Reentrancy.t.sol`) that drains the vault

---

## 📂 Project Structure

src/
├── VulnerableVault.sol # The intentionally vulnerable vault
└── Attacker.sol # Attacker contract exploiting the vault
test/
└── Reentrancy.t.sol # Foundry test simulating the attack

yaml
Copy code

---

## ⚡ Setup

Make sure you have [Foundry installed](https://book.getfoundry.sh/getting-started/installation):

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
Clone this repo and install dependencies:

bash
Copy code
git clone <your-repo-url> reentrantAttackSimulation
cd reentrantAttackSimulation
forge install
▶️ Run the Attack
Run the test:

bash
Copy code
forge test -vv
Expected output:

Victim deposits 10 ETH into the vault

Attacker deposits 1 ETH

Attacker re-enters multiple times during withdrawal

Vault is drained to 0

Attacker ends up with 11 ETH (1 deposit + 10 stolen)

🧨 Vulnerability Explanation
The bug is in VulnerableVault.withdraw():

solidity
Copy code
(bool ok, ) = msg.sender.call{value: bal}(""); // external call
require(ok, "send failed");
balances[msg.sender] = 0; // ❌ too late: state updated after external call
Because the balance is updated after the transfer, the attacker can re-enter via their contract’s receive() function and withdraw repeatedly.