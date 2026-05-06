# Smart Contract Security Laboratory

Practical implementation of common Solidity vulnerabilities and professional mitigation patterns using the **Foundry** framework.

## Security Labs Overview

### ## Lab 1: Reentrancy
- **Vulnerability**: Recursive calls draining contract funds before state balance updates (Classic DAO-style attack).
- **Mitigation**: Implementation of the **Checks-Effects-Interactions (CEI)** pattern to ensure state consistency.

### ## Lab 2: Access Control
- **Vulnerability**: Unprotected administrative functions allowing unauthorized ownership takeover via public setters.
- **Mitigation**: Application of the `onlyOwner` modifier and use of **Custom Errors** for gas-efficient access restriction.

### ## Lab 3: Integer Overflow/Underflow
- **Vulnerability**: Bypassing timelocks and logic checks by overflowing `uint256` variables within `unchecked` blocks.
- **Mitigation**: Proper utilization of Solidity 0.8.x default overflow checks and minimizing the use of `unchecked` for critical arithmetic.

### ## Lab 4: Price Oracle Manipulation
- **Vulnerability**: Critical dependency on a centralized, unprotected Oracle, allowing attackers to manipulate asset prices and drain lending pools.
- **Mitigation**: Implementation of decentralized price feeds (e.g., **Chainlink**) and strict access control for internal price updates.

---

## Technical Stack & Usage

### Prerequisites
- **Foundry**: The blazing fast toolkit for Ethereum application development.

### Installation
```bash
curl -L https://paradigm.xyz | bash
foundryup
```

### Running Tests
```bash
# Run all security test suites
forge test -vvv
```
