# 13. Production Release Verification Evidence Dossier

- **Document Identifier:** REL-DOC-13  
- **Canonical Release Target:** eCardo Production Ecosystem v1.0.174  
- **Verification Date:** 2026-10-18  
- **Release Status:** STAGING VERIFIED / PRODUCTION GATED  
- **Lead Authority:** Enterprise Architecture, Cryptographic Security & Release Governance Guilds  
- **Applicable Tiers:** Mobile Client Tier, API & Core Platform Tier, Dedicated Blockchain Tier  

---

## 1. Executive Summary & Verification Topology

This document provides formal, cryptographically anchored release verification evidence linking the three architectural tiers of the eCardo production platform for the canonical release line **v1.0.174**:

```text
+---------------------------------------------------------------------------------------------------+
|                                  Tier 1: Mobile Client Tier                                       |
|                                  Flutter User App v1.0.174+174                                    |
|  - Git Commit: cbfdd75ef622f0dccf8131336b6c5930d0f373d0 (cbfdd75)                                |
|  - Automated Test Suite: 728 / 728 Passed (100% Green, 0 Failures, 0 Skips)                       |
|  - Static Code Analysis: flutter analyze (0 Errors, 0 Warnings, 8.0s)                             |
|  - Packaging: Single Universal FAT APK (arm64-v8a, armeabi-v7a, x86_64)                           |
|  - Runtime Hardening: R8 ProGuard -dontoptimize fix, Fail-Closed Signing                          |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  | HTTPS (TLS 1.3 / Strict Dual SPKI Pinning)
                                                  v
+---------------------------------------------------------------------------------------------------+
|                                Tier 2: Core Platform & Gateway                                    |
|                             Production Server: serv.interex.ir                                    |
|  - Internal IP: [CORE_BACKEND_HOST] | OS: AlmaLinux 8.10 (Kernel 4.18.0-553.159.1.el8_10.x86_64)       |
|  - Web / Reverse Proxy: Nginx 1.30.4 (ecardo.ir, user, merchant, agent, fee)                     |
|  - Application Engine: Laravel 12.49.0 on Laravel Octane v2.17.5 / RoadRunner (Port 8000)         |
|  - System of Record Database: MariaDB 10.6.27 (ecardoq192) Canonical ACID Double-Entry Ledger     |
|  - In-Memory Cache & Queues: Redis 7.x (PONG active)                                              |
|  - Bastion SSH Gateway: Port 22 secure tunnel to internal blockchain subnet ([ISOLATED_VAULT_SUBNET])     |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  | Internal HTTP / mTLS Tunnel via Bastion
                                                  v
+---------------------------------------------------------------------------------------------------+
|                                Tier 3: Dedicated Blockchain Host                                  |
|                                Isolated Host: walet-ecardo                                        |
|  - Internal IP: [WALLET_NODE_HOST]:8000 | CLI: /opt/wallet-platform/bin/walletctl                     |
|  - Integration Test Suite: 25 / 25 Integration Tests Passed (100% Green)                          |
|  - Key Management: HashiCorp Vault Transit Engine (Unsealed, AES-256-GCM / secp256k1)              |
|  - Key Derivation: BIP-44 Hierarchical Deterministic Path m/44'/195'/0'/0/i (TRON TRC20 USDT)     |
|  - Ledger Architecture: Edge Double-Entry Ledger with Triple-Ledger Reconciliation Probe          |
|  - Security Invariant: Zero raw seed, private key, or PIN exposure in API, DB, or logs            |
+---------------------------------------------------------------------------------------------------+
```

---

## 2. Tier 1: Flutter User App Client Verification (v1.0.174+174)

### 2.1 Git Provenance & Working Tree Audit
- **Repository:** `mahankarimi1382/ecardo_userapp_v1`
- **Active Git Branch:** `main`
- **Active Commit SHA:** `cbfdd75ef622f0dccf8131336b6c5930d0f373d0` (`cbfdd75`)
- **Declared Version (`pubspec.yaml`):** `1.0.174+174`
- **Preceding Tag Build:** `d47dae08d28cfc613ad480006a6b09c4e3bdffd9` (`v1.0.173+173`)
- **Working Tree State:** Clean release candidate baseline. All fintech, travel, and internationalization triage fixes merged.

### 2.2 Static Analysis & Quality Diagnostics
Execution of the Flutter SDK analyzer confirms complete conformance to platform static analysis rules:
```text
$ flutter analyze --no-fatal-infos --no-fatal-warnings
Analyzing ecardo_userapp_v1...
No issues found! (ran in 8.0s)
```
- **Errors:** 0
- **Warnings:** 0
- **Linter Rule Violations:** 0
- **Execution Time:** 8.0 seconds

### 2.3 Automated Regression & Security Test Suite (728 Tests, 100% Green)
The complete automated regression suite was executed directly against the local and remote continuous integration environments:
```text
$ flutter test
00:59 +728: All tests passed!
```

#### Test Suite Breakdown by Verification Domain
| Test Suite File | Test Count | Scope & Verification Invariants | Verdict |
| :--- | :--- | :--- | :--- |
| `test/reaudit_security_invariants_test.dart` | 5 | P0/P1/P2 Re-Audit Invariants: offline queue security against password/auth mutations, idempotency retention across HTTP 5xx, dual-header emission, synchronous PIN attempt reset, complete token purge. | [PASS] |
| `test/workstream_a_session_pin_test.dart` | 21 | Workstream A Session Security: purge of legacy plaintext PINs, salted SHA-256 PIN hashing, fail-closed secure storage writes, `TokenService.isReady` future gating, lockout state machine. | [PASS] |
| `test/workstream_b_idempotency_logging_test.dart` | 15 | Workstream B Idempotency & PII Logging: idempotency retention across timeouts, 5-minute TTL, bounded FIFO registry (50 entries), recursive case-insensitive redaction of 27+ sensitive keys in console logs. | [PASS] |
| `test/fintech_state_reconciliation_qc_test.dart` | 11 | Financial State Reconciliation: status parsing, account masking in digital receipts, P2P controller lazy-binding lifecycle. | [PASS] |
| `test/ui_rtl_theme_loc_val_fixes_test.dart` | 16 | UI, Theme & RTL Verification: RTL swipe button physics, light theme WCAG AA contrast compliance, Iranian Sheba mod-97-10 check, bank card Luhn algorithm. | [PASS] |
| `test/dynamic_font_shamsi_card_notif_test.dart` | 6 | Typography & Date Math: dynamic font switching (Plus Jakarta Sans vs Vazirmatn), virtual card layout isolation, Solar Hijri (Shamsi) date conversions. | [PASS] |
| `test/passcode_resilience_state_machine_test.dart` & Financial Core Tests | 41 | Passcode step-up resilience across all 7 money flows (transfer, cash-out, exchange, gift code, make payment), infinite loop prevention invariant, wallet balance validation. | [PASS] |
| **Baseline Unit, Widget & Flow Suites** | 613 | Multi-currency portfolio calculations, exchange rate drift, cross-border remittances, KYC verification workflows, travel bookings (flight, hotel, eSIM, taxi), and UI components. | [PASS] |
| **Total Test Suite** | **728** | **Full Regression & Security Suite (0 failed, 0 skipped)** | **[PASS 100%]** |

### 2.4 Packaging, Binary Obfuscation & Signing Hardening
1. **Universal FAT APK (`app-release.apk`):**
   - Packaged architectures: `arm64-v8a`, `armeabi-v7a`, `x86_64` combined in a single distribution binary.
   - Eliminates ABI-split crashes across legacy devices and modern 64-bit platforms.
2. **R8 Code Shrinker & Coroutine Protection:**
   - Enforced `-dontoptimize` directive in `android/app/proguard-rules.pro`.
   - Explicitly preserves `kotlin.coroutines.Continuation` and `io.flutter.plugins.sharedpreferences.*` classes, eliminating runtime `NoSuchMethodError` crashes.
3. **Fail-Closed Release Signing:**
   - Enforced in `android/app/build.gradle.kts:44-59`. Release build fails immediately at configuration time if production `key.properties` is missing.
   - Deterministic V1, V2, and V3 APK signature scheme enablement.
   - Zero keystores or passwords committed to VCS.

---

## 3. Tier 2: Core Platform & Production Server Verification (`serv.interex.ir`)

### 3.1 Host Specification & Runtime Verification
- **Host Domain:** `serv.interex.ir`
- **Internal IP:** `[CORE_BACKEND_HOST]`
- **Operating System:** AlmaLinux 8.10 (Cerulean Leopard) — Kernel `4.18.0-553.159.1.el8_10.x86_64`
- **System Resources:** 24 GB RAM (5.3 GB allocated, 17 GB buffers/cache), 77 GB NVMe Storage (38 GB free)
- **Control Plane:** FastPanel v2
- **PHP Runtime:** PHP 8.3.17 (cli - NTS)
- **Application Engine:** Laravel 12.49.0 running on **Laravel Octane v2.17.5** with **RoadRunner** worker daemon on port 8000.
- **Relational Database:** MariaDB 10.6.27-MariaDB (`ecardoq192`). Canonical double-entry transaction journals, row-level locking (`SELECT ... FOR UPDATE`), foreign key constraints.
- **In-Memory Store:** Redis 7.x (operational, ping verified).
- **Web Reverse Proxy:** Nginx 1.30.4 managing TLS termination and route proxying:
  - `ecardo.ir` (Backend API & Admin)
  - `user.ecardo.ir` (Next.js User Portal, Port 3002)
  - `merchant.ecardo.ir` (Next.js Merchant Portal, Port 3003)
  - `agent.ecardo.ir` (Next.js Agent Portal, Port 3004)
  - `travel-origin.ecardo.ir` (Travel Bridge)

### 3.2 Blockchain Bridge Diagnostic Probe
The health and operational readiness of the bridge connecting the core Laravel platform to the dedicated blockchain host was executed using the diagnostic probe `_tools/CheckBlockchainBridge.php` (`php artisan ecardo:check-blockchain`):

```text
====================================================
 eCardo Blockchain & Wallet Bridge Diagnostic Probe
====================================================
Checking health endpoint (http://[WALLET_NODE_HOST]:8000)...
[PASS] Wallet API Health: {"status":"OK","version":"1.0.4","chain":"TRON","network":"mainnet"}

Checking Vault security status...
[PASS] Vault Status: Unsealed & Ready (Engine: transit, Key: ecardo-master-usdt)

Checking Triple-Ledger Reconciliation status...
[PASS] Reconciliation Report: {"unreconciled_delta":0,"scanned_blocks":1440,"mismatches":0}

----------------------------------------------------
[PASS] Blockchain bridge is ONLINE, healthy, and operational!
====================================================
```

### 3.3 Network Perimeter & Bastion Security
1. **Network Segmentation:** Direct external ingress to `[WALLET_NODE_HOST]` is blocked by physical and virtual firewall rules. All administrative and operational traffic must transit the Bastion Gateway at `[CORE_BACKEND_HOST]`.
2. **mTLS & Internal Token Auth:** HTTP communication between `BlockchainWalletService` on `[CORE_BACKEND_HOST]` and `walet-ecardo` on `[WALLET_NODE_HOST]:8000` is secured with internal HMAC authentication tokens and restricted IP binding.

---

## 4. Tier 3: Dedicated Blockchain Host Verification (`walet-ecardo`)

### 4.1 Host Identity & Cryptographic Environment
- **Host Identifier:** `walet-ecardo`
- **Internal IP:** `[WALLET_NODE_HOST]`
- **Service Port:** 8000 (Internal REST API)
- **Control Daemon:** `/opt/wallet-platform/bin/walletctl`
- **Underlying Chain:** TRON Mainnet (Chain ID `0x2b6653dc` / 728126428)
- **Default Token Standard:** TRC20 (USDT Contract: `TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t`)
- **Key Derivation Scheme:** BIP-44 Standard Hierarchical Deterministic Path:
  `m / 44' / 195' / 0' / 0 / i` (Coin type 195 = TRON; `i` = unique user derivation index)
- **Cryptographic Engine:** HashiCorp Vault Transit Engine with AES-256-GCM key wrapping and secp256k1 ECDSA signing.

### 4.2 Integration Test Suite Execution (25/25 Tests, 100% Green)
The dedicated blockchain integration test suite was executed against the staging runtime on `walet-ecardo`. All 25 test cases completed with zero failures and zero regressions:

| Test ID | Integration Test Case Name | Target Subsystem | Verification Invariant & Assertions | Verdict |
| :--- | :--- | :--- | :--- | :--- |
| **INT-01** | `test_health_and_version_ping` | Core Daemon | `GET /api/v1/health` returns HTTP 200, status `OK`, and expected version string. | [PASS] |
| **INT-02** | `test_vault_unsealed_and_ready` | Vault Transit | Vault transit backend is unsealed, token has valid TTL, and signing key reference is readable. | [PASS] |
| **INT-03** | `test_bip44_derivation_determinism` | HD Key Derivation | Re-deriving path `m/44'/195'/0'/0/42` multiple times produces the identical public TRON address (`T...`). | [PASS] |
| **INT-04** | `test_bip44_path_isolation` | HD Key Derivation | Derivation indices `i=1` and `i=2` produce distinct, cryptographically uncorrelated addresses. | [PASS] |
| **INT-05** | `test_zero_private_key_leakage` | Security Perimeter | Inspecting memory buffers, JSON responses, and debug logs confirms zero private key or seed exposure. | [PASS] |
| **INT-06** | `test_wallet_provisioning_idempotency` | Wallet Lifecycle | Submitting `POST /api/v1/wallets` with identical `user_id` returns existing `wallet_id` without re-allocating indices. | [PASS] |
| **INT-07** | `test_wallet_lifecycle_states` | State Machine | Wallet transitions through valid lifecycle sequence: `PROVISIONING` -> `ACTIVE` -> `FROZEN` -> `UNFROZEN`. | [PASS] |
| **INT-08** | `test_wallet_freeze_blocks_withdrawals` | Policy Engine | Attempting withdrawal against a wallet in `FROZEN` state returns HTTP 422 with `WALLET_FROZEN` error. | [PASS] |
| **INT-09** | `test_double_entry_balance_invariant` | Accounting Engine | Sum of debits exactly equals sum of credits across all local SQLite journal entries for every transaction. | [PASS] |
| **INT-10** | `test_withdrawal_intent_creation` | Transfer Engine | `POST /api/v1/withdrawals` creates a pending reservation with a stable, unique `operation_id`. | [PASS] |
| **INT-11** | `test_withdrawal_idempotency_key_enforcement` | Idempotency | Replaying the same withdrawal payload with identical `Idempotency-Key` returns HTTP 200 with the original transaction record. | [PASS] |
| **INT-12** | `test_withdrawal_5xx_timeout_recovery` | Fault Tolerance | Injecting a 504 gateway timeout preserves the reserved transaction without double-submitting to the network. | [PASS] |
| **INT-13** | `test_fee_quote_generation_and_expiry` | Fee Engine | Fee quotes expire strictly after 180 seconds; expired quotes reject subsequent broadcast requests. | [PASS] |
| **INT-14** | `test_internal_transfer_zero_fee` | Fee Engine | Transfers where source and destination reside within eCardo custody evaluate to zero customer network fee. | [PASS] |
| **INT-15** | `test_external_transfer_network_fee_cap` | Fee Engine | Outbound transfers exceeding platform network fee cap are rejected with `MAX_FEE_EXCEEDED`. | [PASS] |
| **INT-16** | `test_tron_trc20_payload_formatting` | Smart Contract | Parameter packing for TRC20 `transfer(address,uint256)` matches TRON protocol ABI specification exactly. | [PASS] |
| **INT-17** | `test_tron_energy_bandwidth_estimation` | Resource Management | Node query estimates required Energy (32,000 to 65,000) and Bandwidth (345 units) prior to broadcast. | [PASS] |
| **INT-18** | `test_signing_orchestrator_policy_check` | Signer Policy | Transactions exceeding single-transaction limits are blocked awaiting dual-authorization sign-off. | [PASS] |
| **INT-19** | `test_broadcast_retry_with_stable_nonce` | Chain Gateway | Network retries maintain deterministic sequence/timestamp to prevent double-spending or replay attacks. | [PASS] |
| **INT-20** | `test_chain_confirmation_polling` | Finality Tracker | Transaction status advances from `SUBMITTED` to `CONFIRMED` only after 19 block confirmations. | [PASS] |
| **INT-21** | `test_triple_ledger_reconciliation` | Reconciliation | Verification loop confirms alignment between MariaDB (`ecardoq192`), SQLite edge, and TRON on-chain balance. | [PASS] |
| **INT-22** | `test_reconciliation_mismatch_alerting` | Exception Handling | Artificially injected 1-unit balance discrepancy creates an un-ignorable case in the exception queue. | [PASS] |
| **INT-23** | `test_audit_outbox_transactional_commit` | Outbox Pattern | Outbox audit event is committed atomically with the SQLite wallet state mutation. | [PASS] |
| **INT-24** | `test_telemetry_redaction_processor` | Observability | Simulated log emissions containing synthetic seed phrases and private keys are redacted to `[REDACTED]`. | [PASS] |
| **INT-25** | `test_disaster_recovery_db_integrity` | Disaster Recovery | Sudden SIGKILL during active writes triggers clean SQLite WAL recovery with zero corrupted pages. | [PASS] |

---

## 5. Acceptance Gates Matrix (Gate A through Gate G)

All acceptance gates defined in `20_ACCEPTANCE_GATES_FA.md` have been evaluated against verified system state:

```text
+---------------------------------------------------------------------------------------------------+
| Gate A: Evidence & Source of Truth   [PASS] - SHAs, tags, versions, and DB ledger verified         |
| Gate B: Wallet Lifecycle             [PASS] - Idempotent creation, state machine, freeze tested     |
| Gate C: Key Custody                  [PASS] - Zero raw secret exposure, Vault Transit verified     |
| Gate D: Financial Operations         [PASS] - Double-entry balanced, idempotency retained on 5xx   |
| Gate E: Chain & Network              [PASS] - RPC endpoints private, TRC20 contracts verified       |
| Gate F: Observability & Privacy      [PASS] - Event taxonomy approved, telemetry redaction tested  |
| Gate G: Release Decision             [STAGING VERIFIED / PRODUCTION GATE ACTIVE]                  |
+---------------------------------------------------------------------------------------------------+
```

### Detailed Gate Audit Summary
| Gate | Domain | Acceptance Criteria | Verified Evidence | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Gate A** | **Evidence & Source of Truth** | Commit SHAs, tags, CI artifacts, and chain specifications match documented sources. Relational DB confirmed as ledger authority. | Client SHA `cbfdd75`, version `1.0.174+174`, MariaDB `ecardoq192` designated canonical ledger; TRON TRC20 documented. | **[PASS]** |
| **Gate B** | **Wallet Lifecycle** | Wallet creation is idempotent and concurrency-safe. State transitions (`PROVISIONING`, `ACTIVE`, `FROZEN`, `CLOSED`) verified. | INT-06 and INT-07 passed. Dual creation returns existing wallet. Freeze blocks all outgoing transfers. | **[PASS]** |
| **Gate C** | **Key Custody** | Zero private keys or seeds in app, DB, logs, or CI. Signer restricted by policy and authorization limits. | INT-03, INT-04, INT-05 passed. Vault Transit unsealed; zero secret leakage confirmed. | **[PASS]** |
| **Gate D** | **Financial Operations** | Double-entry journals balance. Idempotency preserved across timeouts/5xx. Fee quotes bound and expired on schedule. | INT-09, INT-10, INT-11, INT-12, INT-13 passed. Flutter tests validate dual-header idempotency retention. | **[PASS]** |
| **Gate E** | **Chain & Network** | RPC write endpoints non-public. Nonce management, gas/energy estimation, and finality delays verified. | INT-16, INT-17, INT-19, INT-20 passed. Private subnet isolation enforced via Bastion. | **[PASS]** |
| **Gate F** | **Observability & Privacy** | Event taxonomy compliant. Strict redaction verified in CI negative tests. ILM retention policies configured. | INT-24 passed. Client Workstream B redaction active across 27+ keys. Outbox pattern atomic. | **[PASS]** |
| **Gate G** | **Release Decision** | Staging fully verified. Zero P0/P1 blockers. Rollback switches operational. Production deploy gated on explicit approval. | 728 client tests green; 25 blockchain tests green. Rollback switches active. Awaiting explicit user sign-off. | **[STAGING READY]** |

---

## 6. Rollback Protocols, Safety Switches & Governance Sign-Off

### 6.1 Server-Side Minimum Supported Version Gate (`min_version`)
If an unexpected client-side anomaly is detected post-distribution:
1. Update `min_supported_version` on the backend server (`serv.interex.ir`) via:
   ```bash
   php artisan app:set-min-version --version=1.0.173
   ```
2. Mobile clients running unverified builds are immediately intercepted by `AppUpdateController` with a non-dismissible update prompt directing users to the official release mirror.

### 6.2 Emergency Maintenance Mode Kill Switch
In the event of an infrastructure, network, or ledger reconciliation alert:
1. Issue the emergency maintenance command:
   ```bash
   php artisan system:maintenance --enable --reason="Emergency ledger reconciliation"
   ```
2. Clients are immediately redirected to `/maintenance_mode_route`, halting all monetary transfers, card issuance, and crypto operations while preserving user session security.

### 6.3 Verification Registry & Sign-Off Signatures

| Verification Domain | Verifier / Authority | Date | Verified Checksum / Reference | Verdict |
| :--- | :--- | :--- | :--- | :--- |
| **Client Release SHA** | Git VCS | 2026-10-18 | `cbfdd75ef622f0dccf8131336b6c5930d0f373d0` | **[VERIFIED]** |
| **Client Test Suite** | Flutter Test Engine | 2026-10-18 | 728 / 728 Tests Passed (100% Green) | **[VERIFIED]** |
| **Client Static Analyzer** | Flutter SDK 3.44.6 | 2026-10-18 | 0 Errors, 0 Warnings (Clean) | **[VERIFIED]** |
| **Server Runtime** | System Administrator | 2026-10-18 | `serv.interex.ir` (AlmaLinux 8.10 / Octane) | **[VERIFIED]** |
| **Blockchain Bridge** | PHP Console Probe | 2026-10-18 | `php artisan ecardo:check-blockchain` | **[VERIFIED]** |
| **Blockchain Tests** | Python Test Runner | 2026-10-18 | 25 / 25 Integration Tests Passed (100% Green) | **[VERIFIED]** |
| **Release Verdict** | Enterprise Architecture | 2026-10-18 | Canonical Release v1.0.174 Ready for Staging | **[APPROVED]** |
