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

## Lab 8: ERC-4626 Inflation Attack (Rounding Errors)
- **Vulnerability**: A mathematical vulnerability in token vault share calculation where an attacker front-runs the first depositor with 1 wei to mint 1 share, then artificially inflates the vault's asset balance via a direct transfer.
- **Research**: Demonstrated how the inflated asset-to-share ratio forces subsequent honest deposits to yield less than 1 share. Due to Solidity's floor division, any fractional share calculation drops to zero, allowing the attacker to completely absorb the honest user's capital during withdrawal.
- **Mitigation**: Enforcing a minimum initial deposit (burning a fraction of the first shares to a dead address) or utilizing virtual assets and virtual shares to offset the inflation ratio.

## Lab 9: Governance Flash Loan Attack (Vote Hijacking)
- **Vulnerability**: A logical flaw where a governance contract calculates voting power using instantaneous spot balances via `balanceOf` instead of historical block snapshots.
- **Research**: Demonstrated how an attacker uses a flash loan to temporarily acquire 1,000,000 tokens, triggers the `vote()` function to record maximum voting weight, and repays the loan within the same transaction.
- **Mitigation**: Implementing checkpointed token balances (such as OpenZeppelin's `ERC20Votes`) to query voting power at a specific historical block number.

## Lab 10: Staking Pool Reward Manipulation (Pool Dilution)
- **Vulnerability**: An economic design flaw in yield distribution where reward metrics are updated instantaneously based on the current spot volume of staked assets rather than tracking the precise time duration capital spends locked in the contract.
- **Research**: Demonstrated how an attacker executes a pool dilution attack by front-running a reward notification transaction with a massive stake. The attacker claims a disproportionate 90% share of the rewards immediately within the same block and exits, draining the yield accumulated by long-term depositors.
- **Mitigation**: Implementing a linearly decaying reward distribution model (e.g., Synthetix `RewardRate` over a fixed `rewardsDuration`) or enforcing a minimum staking duration checkpoint to lock rewards until a time threshold is passed.

## Lab 11: Cream Finance Cross-Contract Reentrancy (Collateral Drain)
- **Vulnerability**: A critical business logic flaw in lending market architectures where asset borrowing operations violate the Checks-Effects-Interactions (CEI) pattern, executing low-level token transfers before updating the user's debt metrics in state storage.
- **Research**: Demonstrated how an attacker leverages a reentrancy hook during a `borrow()` execution to invoke `withdrawCollateral()`. Because the debt calculation remains at zero during the fallback invocation, the protocol permits the total liquidation of the collateral, leaving the system with unbacked bad debt.
- **Mitigation**: Strictly adhering to the Checks-Effects-Interactions pattern by updating state variables before executing external calls, or enforcing robust cross-contract reentrancy guards (`nonReentrant`) on all state-changing entry points.

## Lab 12: Lendf.Me ERC-777 Callback Hijacking (Balance Inflation)
- **Vulnerability**: A critical architectural flaw in decentralized state synchronization where a lending protocol invokes arbitrary external hooks or token callbacks before committing the depositor's net balance updates to storage state.
- **Research**: Demonstrated how an attacker leverages an ERC-777 token style callback to issue an immediate `withdraw()` request mid-deposit. Because the state update is delayed, the system permits the asset removal against previous balances and subsequently executes the delayed storage addition, creating capital out of thin air.
- **Mitigation**: Enforcing strict Checks-Effects-Interactions (CEI) design patterns where internal accounting ledger states are mutated before triggering any outbound communication, ether transfers, or token callback executions.

## Lab 13: ERC-4626 Vault Inflation Attack (Math Rounding Down)
- **Vulnerability**: A critical mathematical vulnerability in tokenized vault asset-to-share accounting where the system relies on native Solidity integer division that rounds down, allowing early depositors to manipulate the conversion rate by inflating the vault's total assets.
- **Research**: Demonstrated how an attacker minints the very first share for 1 wei, then executes a direct asset donation via `receiveProfit()` to artificially skew the share-price logic. Subsequent честный users suffer from heavy rounding-down errors, minting zero or fewer shares than their actual economic contribution, which results in capital theft during liquidation.
- **Mitigation**: Integrating robust virtual shares and virtual assets offsets into the allocation formulas (OpenZeppelin standard), or pruningly minting the baseline dead shares directly to `address(0)` on the first initialization block to make vault inflation economically non-viable.

### Lab 14: Uniswap V3 TWAP Oracle Manipulation
- **Concept:** Exploiting short-window Time-Weighted Average Price (TWAP) oracles in DeFi lending protocols.
- **Vulnerability:** The lending contract relies on a short 5-minute (300 seconds) TWAP window and uses a linear price-to-tick calculation `uint256(tick) * 10**18` for positive ticks, making it extremely sensitive to oracle manipulation.
- **Exploit Logic:** 
  1. Deposited 1 whole token (10^18 wei) as collateral into the lending platform.
  2. Directly manipulated the `MockUniswapV3Pool` state by forcing a massive cumulative tick of `30,000,000`.
  3. Advanced time by 1 second (`vm.warp`) to simulate the block progression.
  4. The oracle calculated the time-weighted average tick as `30,000,000 / 300 = 100,000`, inflating the collateral token price to `100,000 * 10**18`.
  5. Successfully drained **all 100,000 borrow tokens** from the platform under 1 single unit of collateral.
- **Status:** `[PASS]` (Foundry test verified).

### Lab 15: State Invariant & Handler-Based Fuzzing
- **Concept:** Property-based testing and state invariants using Foundry's advanced fuzzing engine.
- **Vulnerability:** Economic logic flaw in share calculation (`sharesToMint = (msg.value * totalShares) / totalAssets`). The contract relies solely on internal state accounting, making it vulnerable to direct asset donation.
- **Exploit Architecture:**
  1. Developed a dedicated `VaultHandler` to bound random fuzz inputs (`bound(shares, 0, userShares)`) and reduce test noise/reverts.
  2. Introduced a `donate()` target function to simulate a direct forced ETH transfer (`address(vault).call{value: amount}("")`), bypassing the `deposit()` logic.
  3. Created an invariant invariant check `realBalance == trackedAssets` to monitor the economic integrity of the protocol.
- **Result:** `[PASS]` Foundry successfully generated 128,000 chaotic call sequences, catching the state discrepancy on the very first fuzz run and validating the vector while maintaining clean CI/CD green status.

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
