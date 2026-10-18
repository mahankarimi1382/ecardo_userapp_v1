# 10. Comprehensive Threat Model — Blockchain & Custody Platform

**Document Version:** 1.0.0  
**Target Environment:** walet-ecardo (`192.168.200.57`) via Bastion `serv.interex.ir` (`192.168.100.65`)  
**Repository:** `ecardo_userapp_v1`  
**Classification:** Internal Confidential / Security Architecture  
**Date:** 2026-10-18  

---

## 1. Scope & Methodology

This threat model establishes a structured security analysis for the eCardo Blockchain Wallet Platform, encompassing cryptographic custody, double-entry financial ledgering, isolated transaction signing, chain event indexing, and fiat gateway routing.

The assessment employs the **STRIDE** model (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege) augmented with blockchain-specific threat categories including reorganizations (reorgs), replay attacks, RPC poisoning, and double-spend race conditions.

```
+----------------------------------------------------------------------------------------------------+
|                                    PLATFORM TRUST BOUNDARIES                                       |
+----------------------------------------------------------------------------------------------------+
| [TB-1: Client / Public]  Flutter Mobile App / Public Web                                           |
|       |                                                                                            |
|   HTTPS / TLS 1.3 (Signed Requests, Nonces, JWT)                                                   |
|       v                                                                                            |
| [TB-2: Edge / Bastion]   serv.interex.ir (192.168.100.65) - Firewall & Reverse Proxy               |
|       |                                                                                            |
|   Private VPC / mTLS Direct TCP                                                                    |
|       v                                                                                            |
| [TB-3: Host Perimeter]  walet-ecardo (192.168.200.57)                                              |
|       +------------------------------------------------------------------------------------------+ |
|       | [TB-4: Service Core]  wallet-api.service (Port 8000)                                     | |
|       |       |                       |                      |                                   | |
|       |       v (Memory/IPC)          v (Direct DB)          v (Memory/IPC)                      | |
|       | [TB-5: Vault]           [TB-6: SQLite WAL]     [TB-7: Isolated Signer]                   | |
|       | PBKDF2-HMAC-SHA256      wallet.db              Derivation & Signing Guardrails           | |
|       +------------------------------------------------------------------------------------------+ |
|       |                                               |                                          | |
|       v (Outbound TLS)                                v (Outbound TLS)                           | |
| [TB-8: External Chain RPC]                      [TB-9: Fiat PSP Gateway]                         | |
| TRON Public / Node RPC (TRC20)                  Behpardakht Mellat Payment Adapter               | |
+----------------------------------------------------------------------------------------------------+
```

---

## 2. Asset Inventory & Criticality Classification

| Tier | Asset Name | Description & Storage Location | Impact of Compromise |
|---|---|---|---|
| **Tier 1 (Catastrophic)** | **Root Master Seed** | 256-bit entropy in Vault (`wallet_root_seed`) | Total loss of all custodial user crypto-assets |
| **Tier 1 (Catastrophic)** | **Hot Treasury Key** | Private key for Treasury (`T9yD14Nj...`) | Immediate theft of consolidated platform funds |
| **Tier 1 (Catastrophic)** | **Signer In-Memory State** | Ephemeral derived child private keys | Targeted theft of individual user deposits |
| **Tier 2 (Critical)** | **Double-Entry Ledger** | Journal entries table (`ledger_entries`) | Accounting corruption, silent insolvency |
| **Tier 2 (Critical)** | **Withdrawal Queue** | `withdrawals` table state machine | Double-withdrawal execution, unbacked payouts |
| **Tier 2 (Critical)** | **JWT & HMAC Secrets** | `jwt_public_key`, `webhook_secret` | System-wide authentication bypass / forgery |
| **Tier 3 (High)** | **Mellat PSP Credentials** | Terminal ID & Merchant keys in Vault | Unauthorized payment settlements / chargebacks |
| **Tier 3 (High)** | **Admin Session Keys** | Session tokens for dashboard (Port 8080) | Unauthorized privilege escalation / config tampering |
| **Tier 4 (Medium)** | **Wallet Registry Metadata** | Address-to-user mappings in `wallets` | Privacy de-anonymization, deposit interception |

---

## 3. Detailed Threat Vector Analysis

### Vector 1: Private Key Extraction & Cryptographic Compromise

- **Attack Scenario:** An attacker exploits a server vulnerability, inspects SQLite database backups, reads debug logs, or dumps system memory to obtain private keys or the master seed.
- **Architectural Safeguards:**
  1. *Zero Plaintext Invariant:* No private key or seed phrase is ever stored in the SQLite database or written to disk files.
  2. *Envelope Encryption:* Secrets are encrypted at rest and in memory using PBKDF2-HMAC-SHA256 with 100,000 iterations and application-specific salts (`ecardo_vault_salt_2026`).
  3. *Ephemeral Derivation:* Child keys are generated deterministically in memory only for the millisecond duration required to sign a transaction, then immediately cleared.
  4. *Access Partitioning:* Only the isolated `SignerService` holds the ACL to request `wallet_root_seed`. All other services raise `PermissionError` (verified in IT-19).

### Vector 2: Double-Spending & Withdrawal Replay Attacks

- **Attack Scenario:** A malicious user sends concurrent withdrawal requests to debit a single balance twice, or an attacker replays a previously broadcast withdrawal transaction.
- **Architectural Safeguards:**
  1. *Two-Phase Balance Reservation:* Before signing, `LedgerEngine.hold_withdrawal` reserves funds and writes a pending hold entry within an ACID database transaction.
  2. *Idempotency Enforcers:* Every withdrawal requires a unique `idempotency_key` and UUID `request_id`.
  3. *Signer Replay Cache:* `SignerService` tracks all signed `request_id` values in memory (`_signed_requests`). Duplicate signing requests are rejected with `SignerError` (verified in IT-09).
  4. *Nonce Invalidation:* In incoming API calls and webhooks, nonces are validated once and cached; duplicate nonces are blocked with `AuthError` (verified in IT-23).

### Vector 3: Blockchain Reorganizations (Reorgs) & Finality Failures

- **Attack Scenario:** An attacker deposits TRC20 USDT, waits for 1 or 2 block confirmations, withdraws equivalent fiat or crypto, and subsequently causes a block reorganization on the network, orphaning the original deposit block.
- **Architectural Safeguards:**
  1. *19-Block Confirmation Threshold:* Deposits remain strictly in `PENDING` state until `confirmations = max(0, current_head - block_number) >= 19` (verified in IT-05).
  2. *State Immutability:* Deposits are only marked `CREDITED` once 19 blocks pass, triggering the one-time ledger credit (`Dr Treasury:USDT, Cr User:{id}:USDT`).
  3. *Duplicate Event Immunity:* If the listener re-processes an already credited transaction hash during a re-scan, it returns `ALREADY_CREDITED` and produces zero duplicate entries (verified in IT-07).

### Vector 4: RPC Node Poisoning & Man-in-the-Middle

- **Attack Scenario:** An attacker intercepts RPC communications or poisons a local read node to forge fake `Transfer` events or spoof node block heights.
- **Architectural Safeguards:**
  1. *Direct Contract Verification:* The listener inspects the smart contract address (`TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t`) and ensures destination matches a verified user address in the `wallets` table.
  2. *Cryptographic Verification:* TRON transaction receipts and event logs must match verified cryptographic hashes.
  3. *Private Network Peering:* Node communication runs over encrypted channels without public RPC exposure.

### Vector 5: Insider Threats, Rogue Administrators & Privilege Escalation

- **Attack Scenario:** A compromised administrator account or rogue internal developer attempts to manipulate balances directly or execute unauthorized bulk withdrawals.
- **Architectural Safeguards:**
  1. *Immutable Double-Entry Ledger:* Direct balance mutations are impossible. Balances are dynamically projected from journal entries. Every credit requires an offsetting debit. Unbalanced ledger entries fail transactions with `LedgerError` (verified in IT-18).
  2. *Hardcoded Signer Threshold:* Single transactions exceeding **50,000.00 USDT** are blocked at the signing level (`MAX_SINGLE_WITHDRAWAL`), preventing runaway automated draining (verified in IT-13).
  3. *Granular 5-Tier RBAC:* Permissions are segmented into `SUPER_ADMIN`, `FINANCE_OPERATOR`, `SUPPORT_OPERATOR`, `RISK_OPERATOR`, and `READ_ONLY_AUDITOR` (verified in IT-21).
  4. *Triple-Ledger Reconciliation:* Automated audits continuously verify that total user liability matches treasury assets and Mellat settlements (verified in IT-25).

### Vector 6: Fiat Payment Callback Forgery & Gateway Manipulation

- **Attack Scenario:** An attacker generates fake Behpardakht Mellat PSP callback POST requests with spoofed success status codes (`res_code=0`) to credit fiat IRR without payment.
- **Architectural Safeguards:**
  1. *Authority Verification:* The callback must match a pre-existing `authority` record initiated in the database.
  2. *Gateway Status Validation:* Bad gateway return codes (e.g., `res_code=41` Invalid Request) are blocked and rejected (verified in IT-24).
  3. *Two-Step Server Verification:* Mellat `bpVerifyRequest` is executed server-to-server before finalizing credits on the ledger.

---

## 4. Comprehensive Threat & Mitigation Matrix

| Threat ID | Threat Description | STRIDE Category | Severity | Enforced Mitigations | Test Verification |
|---|---|---|---|---|---|
| **TM-BC-01** | Extraction of master root seed from disk or logs | Info Disclosure | **Critical** | Zero Plaintext Invariant; PBKDF2-HMAC-SHA256 envelope encryption; strict Vault ACLs. | IT-19 |
| **TM-BC-02** | Concurrent double-withdrawal of same crypto balance | Tampering | **High** | Two-phase withdrawal reservation in SQLite WAL; balance check before hold. | IT-08, IT-11 |
| **TM-BC-03** | Replayed withdrawal signing request | Spoofing | **High** | Signer in-memory request cache `_signed_requests` + UUID idempotency keys. | IT-09 |
| **TM-BC-04** | Withdrawal directed to malformed or alien chain address | Tampering | **Medium** | Base58Check TRON address validation (`T...`, length 34); non-TRON addresses rejected. | IT-10 |
| **TM-BC-05** | Unauthorized high-value withdrawal draining treasury | Elevation of Priv | **Critical** | Hardcoded `MAX_SINGLE_WITHDRAWAL = 50000.00 USDT` cap in SignerService. | IT-13 |
| **TM-BC-06** | Block reorganization (reorg) invalidating credited deposit | Tampering | **High** | 19-block confirmation policy threshold enforced before crediting. | IT-05 |
| **TM-BC-07** | Duplicate crediting on listener event replay | Tampering | **High** | Unique constraint on `tx_hash` in deposits table; idempotent `ALREADY_CREDITED` return. | IT-07 |
| **TM-BC-08** | Unbalanced double-entry journal posting | Tampering | **Critical** | `LedgerEngine.post_balanced_transaction` requires `sum(debit) == sum(credit)`. | IT-18 |
| **TM-BC-09** | Sanctioned or illicit user moving funds | Repudiation | **High** | Risk event screening (`risk_events` table); immediate freeze of flagged users. | IT-12 |
| **TM-BC-10** | Forged JWT authentication token | Spoofing | **High** | Cryptographic signature verification with public key; bad signatures rejected. | IT-22 |
| **TM-BC-11** | Replayed webhook callback or authentication nonce | Spoofing | **Medium** | Single-use nonce cache with TTL; duplicate nonces rejected. | IT-23 |
| **TM-BC-12** | Spoofed Mellat PSP payment callback | Spoofing | **High** | Authority tracking, gateway status verification, server-to-server settlement check. | IT-24 |
| **TM-BC-13** | Unauthorized admin performing financial actions | Elevation of Priv | **High** | 5-tier role-based access control (RBAC) enforced on administrative endpoints. | IT-21 |
| **TM-BC-14** | Blockchain network or node outage | Denial of Serv | **Medium** | Safe degradation: listener holds pending state; ledger remains uncorrupted. | IT-17 |
| **TM-BC-15** | Database crash during financial operation | Denial of Serv | **High** | SQLite Write-Ahead Logging (WAL) and atomic transactions ensure rollback. | IT-18 |
| **TM-BC-16** | Vault outage or locked state | Denial of Serv | **High** | Fail-closed signing: signing safely halts without leaking secrets when sealed. | IT-19 |
| **TM-BC-17** | Duplicate wallet address allocation to user | Tampering | **Medium** | Idempotent wallet allocation: existing address reused for user/chain/asset. | IT-03 |
| **TM-BC-18** | Discrepancy between ledger and external assets | Tampering | **Critical** | Automated triple-ledger reconciliation engine (`ReconciliationService`). | IT-25 |
| **TM-BC-19** | Unplanned daemon restart losing scan position | Denial of Serv | **Low** | Listener restarts from last recorded block checkpoint. | IT-15 |
| **TM-BC-20** | Sweeper crash leaving deposits unaggregated | Denial of Serv | **Low** | Sweeper safely resumes uncollected credited deposits in subsequent cycle. | IT-16 |

---

## 4. Residual Risks & Governance Decisions

1. **Host-Level Single Point of Failure (SPOF):** The wallet platform currently resides on a single primary VM (`walet-ecardo`, `192.168.200.57`). In the event of catastrophic physical hardware failure on the host hypervisor, cold backup restoration (IT-20) is required. A multi-node active-passive failover cluster is scheduled for Phase 3.
2. **Third-Party RPC Latency:** Reliance on external TRON RPC gateways introduces dependency on upstream network stability. High latency degrades deposit indexing time but does not threaten cryptographic safety.
3. **Regulatory & Compliance Mandate:** While technical screening mechanisms are implemented (IT-12), regulatory compliance requirements (KYC/AML) must be periodically audited by the legal compliance officer.
