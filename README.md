# Smart Contract Security Laboratory

My personal knowledge base and executable exploit suite for EVM vulnerabilities. Every vulnerability is isolated, covered by a dedicated contract, and validated via local Foundry tests.

---

## 🛠️ Tech Stack

* **Solidity:** 0.8.28
* **Framework:** Foundry (Forge, Cast)
* **Testing:** Fuzzing, Handler-Based Invariants, Deep Call Tracing (`-vvvv`)
* **Libraries:** OpenZeppelin Contracts v5.x

---

## 🔬 Vulnerability Matrix & Notes

### Lab 01: Reentrancy (Classic External Call)
Target contract transfers ETH before updating the user's balance mapping, violating the CEI pattern. Deployed an attack contract that uses `receive()` to intercept control and loop the withdrawal, draining the entire vault using a single initial deposit.

### Lab 02: Flash Loan & Oracle Manipulation
Borrowed massive capital from a lending pool via flash loan, dumped it into a low-liquidity AMM pool to manipulate the spot price calculation, and used the fake price to borrow protocol funds on the cheap within a single transaction.

### Lab 03: Integer Underflow/Overflow
Targeted legacy pre-0.8 code without SafeMath protections. Forced a fee deduction to wrap around its minimum mathematical limit, flipping a zero balance straight to `2^256 - 1` for infinite tokens.

### Lab 04: Unchecked Return Values
The vault executed raw `.call` or `.send` for asset transfers but skipped `require(success)`. Tricked the accounting system by passing an attack node that explicitly rejected incoming ETH, forcing the transfer to fail while internal states marked it as paid.

### Lab 05: DoS via Block Gas Limit
The contract loops through a dynamic, uncapped array during critical reward distributions. Pushed thousands of spam addresses into the system, forcing any subsequent execution to hit the block gas limit and completely freeze the protocol operations.

### Lab 06: Front-Running (Mempool Exploitation)
Scanned the public mempool for unconfirmed transactions containing revealable cleartext data or passwords. Copied the victim's payload and frontran them by blasting the transaction with a much higher `maxFeePerGas` to get mined first.

### Lab 07: Broken Access Control
Critical administrative functions lacked the `onlyOwner` modifier or failed to initialize the `Ownable` state. Directly called storage modification routines to overwrite the owner variable and hijack full admin privileges.

### Lab 08: Bad Randomness
The lottery contract generated random numbers using manipulable on-chain parameters like `block.timestamp` and `block.prevrandao`. Deployed an attacking contract that calculates the exact same random output within the same block flow, winning every single round.

### Lab 09: Function Visibility Flaws
Critical initialization and minting routines were accidentally declared as `public`/`external` instead of `internal`/`private`. Called the unprotected setup function post-deployment to reset pool parameters and mint new supply.

### Lab 10: Tx.origin Phishing Bypass
The vault used `require(tx.origin == owner)` for access control instead of `msg.sender`. Phished the contract owner into interacting with a malicious contract, which immediately triggered a nested call to the target vault, bypassing authorization since `tx.origin` remained the owner.

### Lab 11: Uninitialized Proxy & Storage Collision
Left the logic/implementation contract uninitialized or messed up the storage slot layout between the proxy and logic layers. Took over the logic contract directly via an open `initialize()` call and executed a state wipe to brick the proxy completely.

### Lab 12: Delegatecall Inside Loops
The contract handles batch instructions using `delegatecall` inside a loop, allowing `msg.value` to be evaluated multiple times. Passed an array of multiple withdrawal orders while only depositing the `msg.value` once, multiplying the payout.

### Lab 13: ERC-4626 Vault Inflation (Math Rounding Down)
Deposited 1 wei of assets into the `ERC4626` vault to grab 1 share, then executed a massive direct token `transfer` into the pool. This inflated the asset-to-share ratio, forcing subsequent user deposits to round down to zero shares due to Solidity's integer division, effectively stealing their funds.

### Lab 14: Uniswap V3 TWAP Manipulation
Altered pool ticks across recent observations by executing high-volume swaps in single-sided, illiquid price ranges. Shifted the TWAP tick index right before a lending contract queried it, enabling inflated borrows using worthless collateral.

### Lab 15: Read-Only Reentrancy
Queried protocol prices while an external Curve/Balancer AMM pool was in a broken, intermediate state. Triggered a standard reentrancy loop to withdraw liquidity, forcing the target vault to read a corrupted `get_virtual_price` and allow heavily undercollateralized borrows.

### Lab 16: Cross-Dex Arbitrage Bot
Exploited asset price gaps across disconnected automated market makers. Wrote a flash loan bot that grabs a pool asset, swaps it on the expensive DEX, rebought on the cheap DEX, and repaid the loan, extracting 5 ETH of risk-free profit in a single block.

### Lab 17: Cryptographic Signature Replay (`SignatureReplayVault`)
The verification logic in `SignatureReplayVault.sol` hashes only the recipient and amount, completely omitting `block.chainid`, `address(this)`, or sequential nonces. Captured a valid owner signature used on `vaultAlpha` and successfully replayed the identical data string to completely drain `vaultBeta`.

### Lab 18: Cross-Chain Bridge Proof Forgery (`BridgeProofVault`)
Exploited a 64-byte Merkle tree collision vulnerability inside `BridgeProofVault.sol` due to missing leaf domain separation. Constructed a forged cryptographic proof by passing an intermediate internal node layout as raw payload data (`address` + `uint256`), triggering a valid verification cycle and draining bridge liquidity without trusted validator signatures.

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
