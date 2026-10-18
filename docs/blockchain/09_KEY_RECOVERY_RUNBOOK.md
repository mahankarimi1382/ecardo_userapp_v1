# 09. Key Management & Recovery Runbook

**Document Version:** 1.0.0  
**Target Environment:** walet-ecardo (`192.168.200.57`) via Bastion `serv.interex.ir` (`192.168.100.65`)  
**Repository:** `ecardo_userapp_v1`  
**Classification:** Restricted / Cryptographic Security Operations  
**Date:** 2026-10-18  

---

## 1. Cryptographic Architecture & Security Boundaries

The eCardo Wallet Platform enforces a strict **Zero Plaintext Invariant**. At no point are unencrypted master seeds, child private keys, or third-party secret credentials stored on disk, written to database columns, serialized in application logs, or transmitted to client devices.

```
+-----------------------------------------------------------------------------------------+
|                                    STORAGE BOUNDARIES                                   |
+-----------------------------------------------------------------------------------------+
| [Layer 1: SQLite Database] (/opt/wallet-platform/data/wallet.db)                         |
|  - Contains: Public addresses, derivation indices, transaction hashes, ledger journals |
|  - Strict Invariant: ZERO private keys or seed phrases permitted                       |
+-----------------------------------------------------------------------------------------+
| [Layer 2: Key Vault] (packages.security.vault.VaultService)                             |
|  - In-Memory Envelope Encryption using PBKDF2-HMAC-SHA256 (100,000 iterations)          |
|  - Salt: ecardo_vault_salt_2026                                                         |
|  - Secrets wrapped with HMAC-SHA256 authentication                                      |
+-----------------------------------------------------------------------------------------+
| [Layer 3: Isolated Signer Boundary] (services.signer.service.SignerService)             |
|  - Process-isolated cryptographic signing engine                                        |
|  - Ephemeral child key generation: derived in-memory, zeroed after signature generation  |
|  - Hardcoded safety rails: Contract whitelist, max withdrawal cap, replay prevention   |
+-----------------------------------------------------------------------------------------+
```

### 1.1 Vault Access Control List (ACL) Policies

Access to keys within `VaultService` is partitioned by service identity. Requests from unauthorized callers raise an immediate `PermissionError` (verified in test IT-19):

```python
_policies = {
    "signer": ["wallet_root_seed", "hot_wallet_key"],
    "wallet-api": ["jwt_public_key", "webhook_secret", "mellat_credentials"],
    "listener": ["tron_rpc_key"],
    "admin": ["admin_session_secret"]
}
```

---

## 2. Deterministic Key Derivation Policy (BIP44 / BIP32)

eCardo implements hierarchical deterministic derivation compliant with **BIP44** and **SLIP-0044** for TRON asset separation:

### 2.1 Derivation Path Specification

$$\text{Derivation Path: } m / 44' / 195' / 0' / 0 / i$$

- $44'$: BIP44 standard specification.
- $195'$: TRON coin type registered in SLIP-0044.
- $0'$: Primary organization account.
- $0$: External receiving address chain.
- $i$: Monotonically increasing child index assigned sequentially to registered users ($i \ge 0$).

### 2.2 Address Generation Pipeline

1. **Master Seed:** 256-bit cryptographic entropy stored inside the Vault (`wallet_root_seed`).
2. **Curve & Math:** Pure `secp256k1` ECDSA key-pair derivation.
3. **Hashing & Formatting:**
   - Public Key $(X, Y) \to$ Keccak-256 hash $\to$ extract last 20 bytes.
   - Prepend TRON network byte prefix `0x41`.
   - Calculate double SHA256 checksum (first 4 bytes).
   - Encode using Base58Check $\to$ 34-character address starting with `T`.
4. **Architectural Rule:** Child deposit addresses do not possess independent seed phrases. They are derived on-demand from the root seed using index $i$.

---

## 3. Root Seed Backup, Custody & Disaster Recovery Protocol

### 3.1 Cold Root Seed Generation & Custody

The master seed entropy represents the ultimate source of truth for all custodial funds.

1. **Generation Ceremony:**
   - Performed on an air-gapped machine running Debian Live OS with networking hardware physically removed.
   - Entropy sourced from true hardware random number generators (TRNG) + system CSPRNG.
2. **Shamir's Secret Sharing (3-of-5 Split):**
   - The master root seed is split into 5 distinct cryptographic shares using Shamir's Secret Sharing scheme (SLIP-0039 standard).
   - Threshold: **Any 3 shares are required** to reconstruct the master seed ($k = 3, n = 5$).
   - Distribution:
     - **Share 1:** Primary Corporate Safe (Dual-combination access).
     - **Share 2:** Chief Information Security Officer (CISO) Private Custody.
     - **Share 3:** Head of Financial Operations / Escrow Legal Custody.
     - **Share 4:** Off-site Disaster Recovery Facility (Air-gapped safe deposit).
     - **Share 5:** Technical Director Emergency Cold Vault.
3. **Physical Media Standards:**
   - All shares are stamped onto 316-grade stainless steel / titanium plates.
   - Resistant to fire (up to 1,400°C), submersion, corrosion, and physical impact.
   - Paper or digital plain-text backups are strictly prohibited.

### 3.2 Disaster Recovery & Verification Drill (IT-20)

Disaster recovery procedures are verified continuously:
- SQLite backup and restore verification confirms schema and ledger balance parity (verified in IT-20).
- Annual fire-drill: Operators reconstruct test seed shares in staging to verify operational readiness.

---

## 4. Vault Sealing & Unsealing Runbook

The Vault maintains the cryptographic master keys in memory. When sealed, the master key is destroyed in memory, stopping all signing operations instantly while keeping the database accessible in read-only mode for query purposes.

### 4.1 Vault Status Verification

```bash
# Check Vault status via CLI
python3 /opt/wallet-platform/bin/walletctl health

# Check Vault readiness via HTTP API
curl -s http://127.0.0.1:8000/ready
```

- **Normal / Ready State:** `{"ready": true, "vault_sealed": false}`
- **Sealed / Locked State:** `{"ready": true, "vault_sealed": true}`

### 4.2 Multi-Operator Unsealing Ceremony

Unsealing requires two authorized security officers (Dual-Control Principle):

1. **Step 1 — Establish Secure Session:**
   - Connect via Bastion (`192.168.100.65`) to `walet-ecardo` (`192.168.200.57`).
2. **Step 2 — Inject Passphrase Environment Variable:**
   - Officer A enters Part 1 of the credential; Officer B enters Part 2:
   ```bash
   export WALLET_VAULT_PASSPHRASE="<combined_secure_passphrase>"
   ```
3. **Step 3 — Restart and Re-initialize Service:**
   ```bash
   sudo systemctl restart wallet-api
   ```
4. **Step 4 — Verify Unseal Success:**
   ```bash
   python3 /opt/wallet-platform/bin/walletctl health
   ```
   *Confirm output indicates:* `Vault: OK (Sealed: False)`.
5. **Step 5 — Clear Shell History:**
   ```bash
   history -c
   unset WALLET_VAULT_PASSPHRASE
   ```

### 4.3 Emergency Instant Sealing

If an active intrusion or memory anomaly is detected:

```bash
# Emergency stop immediately zeroes memory and halts signing
sudo systemctl stop wallet-api
```

---

## 5. Isolated Signer Failover & Guardrails

The Signer Service (`services/signer/service.py`) executes as an isolated signing domain with hardcoded algorithmic guardrails.

```
                      +-----------------------------+
                      | Incoming Withdrawal Request |
                      +-----------------------------+
                                     |
                                     v
                   +-----------------------------------+
                   |     1. Replay Prevention Check    | ---> [Already Signed?] -> RAISE SignerError
                   +-----------------------------------+
                                     | (Pass)
                                     v
                   +-----------------------------------+
                   |   2. Whitelist & Syntax Verify    | ---> [Invalid TRON Addr] -> RAISE SignerError
                   +-----------------------------------+
                                     | (Pass)
                                     v
                   +-----------------------------------+
                   |     3. Single Withdrawal Cap      | ---> [Amount > 50,000] -> RAISE SignerError
                   +-----------------------------------+
                                     | (Pass)
                                     v
                   +-----------------------------------+
                   | 4. In-Memory Child Key Derivation |
                   +-----------------------------------+
                                     |
                                     v
                   +-----------------------------------+
                   |     5. Generate ECDSA Signature   |
                   +-----------------------------------+
                                     |
                                     v
                   +-----------------------------------+
                   |  6. Zero Key Memory & Return Sig  |
                   +-----------------------------------+
```

### 5.1 Enforced Guardrails

1. **Contract Whitelist:** The signer strictly permits TRC20 USDT transfers to the verified contract address `TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t`. Transactions targeting unknown contracts are rejected.
2. **Destination Syntax Enforcement:** Destination must be a valid TRON address starting with `T` and exactly 34 characters (verified in IT-10). Non-TRON addresses (e.g., Ethereum `0x...`) are rejected immediately.
3. **Threshold Cap Enforcement:** Single withdrawal transactions cannot exceed **50,000.00 USDT** (`MAX_SINGLE_WITHDRAWAL`). Requests exceeding this limit raise `SignerError` and require dual-admin manual approval (verified in IT-13).
4. **Replay & Nonce Defense:** The signer maintains an in-memory set `_signed_requests`. Submitting an identical `request_id` raises a duplicate signing error (verified in IT-09).
5. **Clean Recovery:** Signer process restart recovers cleanly without leaking keys or corrupting state (verified in IT-14).

---

## 6. Emergency Protocols: Pause, Freeze & Incident Containment

### 6.1 Platform-Wide Emergency Pause

When systemic risk or blockchain anomaly is detected, operators trigger an immediate global pause.

#### Execution:
```bash
python3 /opt/wallet-platform/bin/walletctl emergency pause
```

#### Operational Effects:
- `POST /api/v1/withdrawals` rejects all new withdrawal requests with HTTP 503.
- Sweeper daemon halts consolidation broadcasts.
- Chain Listener continues indexing blocks and recording deposits in `deposits` table, but credits remain in `PENDING` state until safety is restored.
- Financial integrity is preserved with zero ledger corruption (verified in IT-17).

### 6.2 Targeted Risk Freeze (AML & Sanctions Screening)

For individual users exhibiting suspicious velocity, sanction matches, or high risk scores (e.g., Chainalysis flag):

1. **Automated Event Insertion:** A risk record is recorded in `risk_events` table with status `OPEN` and severity `CRITICAL` (verified in IT-12).
2. **Immediate Lock:** The user's account is locked from outbound transfers.
3. **Balance Preservation:** Existing balance remains intact in the double-entry ledger; no unauthorized confiscation occurs without compliance approval.

### 6.3 Resumption Protocol (Post-Emergency)

Resuming operations requires formal verification:

1. **Run Full Triple Reconciliation:**
   ```bash
   python3 /opt/wallet-platform/bin/walletctl reconciliation run
   ```
   *Resumption is strictly prohibited unless `balanced: true` and `mismatches: []`.*
2. **Execute Resume:**
   ```bash
   python3 /opt/wallet-platform/bin/walletctl emergency resume
   ```
3. **Monitor Live Journal:**
   ```bash
   journalctl -u wallet-api -f -n 50
   ```

---

## 7. Key Compromise & Migration Playbook

If a private key or seed compromise is suspected:

```
[Phase 1: Triage & Halt]
  * Trigger `walletctl emergency pause`
  * Revoke all API Gateway session tokens
  * Isolate walet-ecardo network perimeter

[Phase 2: Asset Evacuation]
  * Sign emergency sweep of all Treasury funds to offline Cold Quarantine Address
  * Verify all pending unbroadcast nonces

[Phase 3: Seed Rotation]
  * Generate new Master Seed (Entropy v2) in air-gapped clean environment
  * Re-encrypt v2 seed using fresh PBKDF2 salt and passphrase

[Phase 4: Address Remapping]
  * Re-derive child deposit addresses for all registered users under v2
  * Update `wallets` table: mark v1 addresses as `DEPRECATED_LEGACY_READ_ONLY`
  * Historical records in `deposits` and `ledger_entries` remain IMMUTABLE

[Phase 5: Reconciliation & Verification]
  * Run `walletctl reconciliation run` to verify zero variance
  * Conduct comprehensive postmortem and publish security advisory
```
