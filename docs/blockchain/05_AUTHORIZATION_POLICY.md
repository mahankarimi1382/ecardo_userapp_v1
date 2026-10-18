# 05. Authorization Policy, Governance & Risk Engine

## 1. Governance Principles & Threat Model

The eCardo Authorization Policy enforces the fundamental security principle: **"No individual or single component may unilaterally create, alter, sign, or freeze assets outside of strictly audited, cryptographically enforced policies."**

Security cannot rely merely on a locked user interface or the existence of a blockchain. Enforceable authorization must be maintained synchronously across the API Gateway, the Backend Application Layer, the Policy Engine, the Signing Orchestrator, the Database, and on-chain Smart Contracts.

### Core Governance Rules
1. **Least Privilege & Role Separation:** Complete segregation between operators, risk analysts, approvers, administrators, and automated signers.
2. **Four-Eyes (Dual Control) Mandate:** Critical financial movements and configuration mutations require independent dual authorization. An initiator can never approve their own request.
3. **Canonical Payload Binding:** Approvals are bound to a cryptographic SHA-256 digest of the canonical operation payload. Any modification to parameters (recipient, amount, fee cap, nonce) immediately invalidates prior approvals.
4. **Defense in Depth:** Even if an attacker gains control of an internal API key or operator session, they cannot drain treasury reserves or bypass velocity and hardware signer limits.

---

## 2. Granular Role-Based Access Control (RBAC) Matrix

The system establishes nine distinct security principals. Each role is constrained to specific actions with granular requirements for Multi-Factor Authentication (MFA), Step-Up biometrics, or Quorum approvals.

### 2.1 Role Definitions
- **`Customer`:** End-user account holder. Can initiate requests, view balances, and transfer funds within personal limits.
- **`CustomerSecurityAdmin`:** End-user security self-service. Can register/revoke passkeys, trusted devices, or authorized payout destinations after strict step-up authentication.
- **`SupportAgent`:** Front-line support personnel. Restricted to read-only masked views. Zero access to signing services, private keys, or address mappings.
- **`RiskAnalyst`:** Compliance and fraud monitoring. Can flag anomalies and recommend or place temporary operational suspensions (`SUSPENDED`). Cannot execute transfers or withdrawals.
- **`WalletOperator`:** Operations engineer responsible for queuing maintenance intents and low-tier operational batches. Cannot approve their own submissions.
- **`Approver`:** Designated treasury officer or risk manager authorized to evaluate and countersign queued intents.
- **`SecurityAdmin`:** Infrastructure administrator managing policy versions, key rotations, and access rules. Requires four-eyes authorization for all mutations.
- **`Auditor`:** Independent compliance officer. Possesses read-only access to immutable audit logs, ledger trails, and verification reports.
- **`BreakGlass`:** Time-delimited emergency response principal requiring dual executive keys, instant alerts to security operations, and mandatory post-incident audit.

### 2.2 Permissions Matrix

| Resource / Action | Customer | Support Agent | Risk Analyst | Wallet Operator | Approver | Security Admin | Break Glass | Mandatory Security Controls |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **View Wallet Balance** | Own | Masked | Read-Only | Read-Only | Read-Only | Audit | Full | Scope check on server |
| **Create Wallet Record** | System | Denied | Denied | Initiate | Review | Denied | Audit | Automated backend derivation |
| **Initiate Payout (< Tier 1)** | Yes | Denied | Denied | Initiate | Automated | Denied | Denied | Standard MFA / Session valid |
| **Initiate Payout (>= Tier 2)** | Step-Up | Denied | Denied | Initiate | Required | Denied | Denied | Passkey / WebAuthn Step-Up |
| **Approve Payout (>= Tier 3)** | Denied | Denied | Denied | Denied | Dual (2) | Denied | Allowed | Four-Eyes: Initiator != Approver |
| **Suspend Wallet (Risk)** | Denied | Denied | Allowed | Allowed | Review | Allowed | Allowed | Automated alert to user & ops |
| **Freeze Wallet (Legal/Court)**| Denied | Denied | Propose | Propose | Required | Dual (2) | Allowed | Legal case reference required |
| **Unfreeze Wallet** | Denied | Denied | Denied | Propose | Required | Dual (2) | Allowed | Dual approval + compliance sign-off |
| **Update Address Mapping** | Denied | Denied | Denied | Denied | Denied | Denied | Denied | **PROHIBITED** (Immutable) |
| **Modify Fee Policy** | Denied | Denied | Propose | Denied | Review | Dual (2) | Denied | Timelock + Dual Approval |
| **Modify Velocity Limits** | Denied | Denied | Propose | Denied | Review | Dual (2) | Denied | Timelock + Dual Approval |
| **Treasury Sweep / Rebalance**| Denied | Denied | Denied | Initiate | Dual (2) | Review | Quorum | Canonical Hash + Multi-Sig |
| **Key Rotation Initiation** | Denied | Denied | Denied | Denied | Review | Dual (2) | Quorum | HSM / KMS authorization gate |
| **Export Unmasked Audit Logs**| Denied | Denied | Denied | Denied | Denied | Review | Allowed | Read-only WORM storage access |

---

## 3. Policy Engine Architecture & Evaluation Pipeline

The Policy Engine serves as the authoritative gateway through which all financial and administrative intents must pass prior to reaching the Signing Orchestrator.

```text
  [ Client Request ] (API Gateway)
          |
          v
+---------------------------------------------------------------------------------+
|                         Policy Evaluation Pipeline                              |
+---------------------------------------------------------------------------------+
| 1. Context Enrichment                                                           |
|    - Resolve Actor, Role, Device Fingerprint, Geo-IP, KYC Tier, Wallet Age      |
|                                                                                 |
| 2. Static RBAC Gate                                                             |
|    - Does Actor Role have permission for target action?                         |
|                                                                                 |
| 3. Dynamic Velocity & Anomaly Engine                                            |
|    - Evaluate 1h, 24h, 30d cumulative outbound volume against account tier      |
|    - Check Global Egress Circuit Breaker                                        |
|    - Check Destination Allowlist / Sanctions Screening                          |
|                                                                                 |
| 4. Policy Decision Matrix                                                       |
|    +-------------------------+------------------------------------------------+ |
|    | Condition               | Decision Outcome                               | |
|    |-------------------------+------------------------------------------------| |
|    | Within Tier 1 limits    | ALLOW (Direct to Signer)                       | |
|    | Above Tier 1 / New Device| REQUIRE_STEP_UP (Passkey / WebAuthn Challenge) | |
|    | Above Tier 2 threshold  | REQUIRE_DUAL_APPROVAL (Enqueue in Four-Eyes)   | |
|    | Risk Score > Threshold  | SUSPEND_AND_ALERT (Block execution)           | |
|    | Velocity Exceeded       | REJECT_VELOCITY_LIMIT                          | |
|    +-------------------------+------------------------------------------------+ |
+---------------------------------------------------------------------------------+
          |
          v
  [ Decision Outcome ]
```

### 3.1 Policy Decision Codes
- `ALLOW`: Intent conforms to all constraints. Issued signed ephemeral authorization token (JWT/Ed25519) valid for 60 seconds.
- `REQUIRE_STEP_UP`: User must supply biometric proof (FIDO2/Passkey or time-based OTP).
- `REQUIRE_DUAL_APPROVAL`: Enqueued in the Four-Eyes Approval Workflow awaiting secondary authorized officer confirmation.
- `DENY_RISK`: Rejected due to sanctions list match, high-risk IP, or anomalous behavioral pattern.
- `DENY_VELOCITY`: Exceeds hourly, daily, or monthly limits for the user's KYC tier.
- `SYSTEM_CIRCUIT_BREAKER`: Platform-wide egress limit exceeded; transfers paused globally pending security review.

---

## 4. Dual Approval (Four-Eyes Principle) & Canonical Hashing

For high-value payouts and institutional treasury movements, no transaction is signed based on a single session.

### 4.1 Value Threshold Tiers (Normalized in USDT / Minor Units)

| Tier | Payout Range (USD Equivalent) | Approval Requirements | Timeout / TTL |
| :--- | :--- | :--- | :--- |
| **Tier 1 (Automated)** | $0.00 – $999.99 | Single User Authorization + Velocity Check | Instant |
| **Tier 2 (Elevated)** | $1,000.00 – $9,999.99 | Step-Up MFA (Passkey/FIDO2) + Anomaly Check | 10 Minutes |
| **Tier 3 (Institutional)**| $10,000.00 – $99,999.99 | Four-Eyes: WalletOperator + Independent Approver | 4 Hours |
| **Tier 4 (Treasury Vault)**| >= $100,000.00 | Multi-Sig / Cold Quorum: 3-of-5 Officers + 24h Timelock | 24 Hours |

### 4.2 Canonical Payload Digest Calculation
To prevent any possibility of "man-in-the-middle" tampering between the approval step and the signing step, all approvals are bound to the SHA-256 hash of a normalized canonical JSON string:

```text
CanonicalPayload = {
    "amount_minor": 25000000000,
    "amount_scale": 6,
    "asset_id": "USDT",
    "chain_id": "TRON_MAINNET",
    "destination_address": "TYPsmL8vVf3Wc8z9D1wS4aE2bQ8rZ1mXpY",
    "expires_at": "2026-10-18T16:30:00Z",
    "fee_cap_minor": 15000000,
    "nonce": "ecardo-tx-uuid-7489-4912",
    "operation_id": "op-payout-9921448",
    "source_wallet_id": "w-user-88412"
}
```

$$\text{PayloadHash} = \text{SHA-256}(\text{CanonicalJSONString}(\text{Payload}))$$

### 4.3 Invalidation and Revocation Rules
1. **Payload Invariance:** If the destination address, amount, fee cap, or asset is altered by even one character or bit, $\text{PayloadHash}$ changes, causing the Signing Orchestrator to reject the approval token.
2. **Identity Non-Overlap:** The system enforces:
   $$\text{InitiatorID} \neq \text{ApproverID}$$
   Attempts by an initiator to approve their own request are rejected with HTTP 403 `FORBIDDEN_SELF_APPROVAL`.
3. **Approval Expiration:** Approvals expire strictly when `expires_at` is reached. Unexecuted intents are automatically transitioned to `EXPIRED`.

---

## 5. Velocity Limits & Platform Circuit Breakers

Velocity limits prevent rapid account draining in the event of compromised customer devices or automated credential stuffing.

### 5.1 Account-Level Velocity Tiers

| KYC Tier | Max Single Payout | Max 1-Hour Velocity | Max Rolling 24-Hour | Max 30-Day Cumulative |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 0 (Unverified)**| $0 (Withdrawals Blocked) | $0 | $0 | $0 |
| **Tier 1 (Basic Mobile)**| $500 | $1,000 | $2,500 | $10,000 |
| **Tier 2 (ID Verified)** | $5,000 | $10,000 | $25,000 | $100,000 |
| **Tier 3 (Institutional)**| $50,000 | $100,000 | $250,000 | $1,000,000 |

### 5.2 Anti-Spam & Burst Limits
- **Burst Cap:** A single wallet cannot execute more than 3 outgoing transactions within any rolling 60-second window.
- **Micro-Transaction Spam Guard:** Minimum transaction amount is enforced (e.g., 5.00 USDT) to prevent network bloat and dust attacks.

### 5.3 Global Egress Circuit Breaker
The platform monitors cumulative net platform outflows in real time:
- If cumulative platform external payouts exceed **$500,000 USD equivalent in any 60-minute rolling window**, the Global Circuit Breaker trips:
  - All automated Tier 1 and Tier 2 payouts transition into `QUEUED_PENDING_GLOBAL_CHECK`.
  - Immediate high-priority PagerDuty alert dispatched to the Chief Risk Officer and Head of Security.
  - Resetting the circuit breaker requires two separate Security Administrators with hardware tokens.

---

## 6. Multi-Layer Enforcement Architecture

Policy enforcement is not isolated to application code. It operates across three distinct boundaries:

```text
+-----------------------------------------------------------------------------------+
| 1. API Gateway / Middleware (Laravel Guard)                                       |
|    - Validates JWT token, Bearer auth, scope, and user session status             |
|    - Enforces rate limiting per IP and User ID                                    |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
| 2. Signing Orchestrator Service ([WALLET_NODE_HOST]:8000 / walet-ecardo)               |
|    - Receives signing request containing Payload + Policy Decision Token          |
|    - Verifies cryptographic signature on Policy Token from Policy Engine          |
|    - Recomputes SHA-256 canonical hash of payload                                 |
|    - Interrogates local SQLite rate limits and address blacklist                  |
|    - Only upon 100% verification does it call Vault/HSM for key signature        |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
| 3. Smart Contract Governance (TRON / EVM Contracts)                               |
|    - OpenZeppelin AccessControl / MultiSig on-chain contracts                     |
|    - Pausable: Emergency circuit breaker halts token contract in severe breach    |
|    - TimelockController: 48-hour delay for code upgrades or admin role grants     |
+-----------------------------------------------------------------------------------+
```

---

## 7. Append-Only Audit Logging Specification

Every authorization decision, state change, approval, and administrative intervention must be logged in an append-only, tamper-evident audit store.

### 7.1 Audit Event Schema

```json
{
  "event_id": "evt-8f92-a1b4-4e2a",
  "actor_id": "usr-approver-4491",
  "actor_type": "EMPLOYEE_APPROVER",
  "action": "PAYOUT_INTENT_APPROVE",
  "resource_type": "PAYOUT_INTENT",
  "resource_id": "op-payout-9921448",
  "before_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "after_hash": "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e",
  "reason_code": "HIGH_VALUE_DUAL_APPROVAL_CONFIRMED",
  "approval_ids": [
    "appr-first-officer-992",
    "appr-second-officer-993"
  ],
  "request_id": "req-gw-uuid-192849",
  "client_ip_masked": "192.168.100.xxx",
  "device_fingerprint_hash": "8f82b79a5e1281",
  "result": "SUCCESS",
  "timestamp": "2026-10-18T14:45:12.894Z"
}
```

### 7.2 Log Integrity Guarantees
- **WORM Storage:** Audit logs are mirrored to Write-Once-Read-Many (WORM) storage with deletion protection.
- **Zero Secrets / PII:** Plaintext passwords, authentication tokens, private keys, credit card numbers, and raw user identity files are strictly stripped before reaching the audit index.
- **Cryptographic Checkpointing:** A daily Merkle root of all audit entries is computed and anchored to the system log, rendering historical log manipulation mathematically detectable.
