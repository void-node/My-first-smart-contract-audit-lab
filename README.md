# Smart Contract Security Laboratory

Practical implementation of common Solidity vulnerabilities and professional mitigation patterns using the **Foundry** framework.

## Security Labs Overview

## Lab 1: Reentrancy
- **Vulnerability**: Recursive calls draining contract funds before state balance updates.
- **Mitigation**: Implementation of the **Checks-Effects-Interactions (CEI)** pattern.

## Lab 2: Access Control
- **Vulnerability**: Unprotected administrative functions allowing unauthorized ownership takeover.
- **Mitigation**: Application of the `onlyOwner` modifier and use of **Custom Errors**.

## Lab 3: Integer Overflow/Underflow
- **Vulnerability**: Bypassing timelocks by overflowing `uint256` variables within `unchecked` blocks.
- **Mitigation**: Proper utilization of Solidity 0.8.x default overflow checks.

## Lab 4: Price Oracle Manipulation
- **Vulnerability**: Dependency on an unprotected Oracle, allowing attackers to manipulate asset prices.
- **Mitigation**: Implementation of decentralized price feeds (e.g., **Chainlink**) and strict access control.

## Lab 5: Flash Loan Attack
- **Vulnerability**: Exploiting protocol logic by borrowing massive amounts of uncollateralized capital within a single transaction.
- **Mitigation**: Implementing "Snapshot" mechanisms or requiring actions to span across multiple blocks (Time-locks).

## Lab 6: Signature Malleability (Cryptography)
- **Vulnerability**: Exploiting the mathematical symmetry of ECDSA signatures (the `s` value) to bypass signature uniqueness checks.
- **Research**: Demonstrated how an attacker can "double-spend" a valid admin signature by flipping its `s` value.
- **Protection**: Verified that modern **OpenZeppelin ECDSA** libraries effectively mitigate this by enforcing "Low-S" values.

## Lab 7: Read-Only Reentrancy (Oracle Manipulation)
- **Vulnerability**: Exploiting a cross-contract state mismatch where a lending protocol reads asset prices from an external liquidity pool while it is temporarily in an unstable, half-executed state during a withdrawal.
- **Research**: Demonstrated how an attacker invokes a view function inside a `receive()` fallback loop when the pool's asset reserves and total supply tracking are out of sync, returning a manipulated price.
- **Mitigation**: Utilizing Time-Weighted Average Prices (TWAP) or applying reentrancy locks even to read-only view functions via cross-contract reentrancy checks.

---

## Technical Stack & Usage

### Installation
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Running Tests
```bash
forge test -vvv
```

---

## 📑 Audit Reports
Detailed analysis of found vulnerabilities and professional mitigation patterns can be found in the [reports](./reports) directory.
