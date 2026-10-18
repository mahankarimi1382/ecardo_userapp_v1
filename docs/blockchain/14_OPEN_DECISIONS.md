# 14. Open Architectural Decisions & Roadmap Evolution Triggers

- **Document Identifier:** DEC-DOC-14  
- **Roadmap Phase:** Post-Baseline Inventory & Architecture Evolution  
- **Status:** APPROVED FRAMEWORK & ACTIVE TRACKING  
- **Date:** 2026-10-18  
- **Target Repository:** `ecardo_userapp_v1` & eCardo Core Platform  
- **Deciders:** Chief Systems Architect, Principal Security Architect, Core Financial Engineering Lead, Blockchain Lead  
- **Consulted:** Mobile Platform Guild, SRE & Observability Guild, Legal & Compliance Guild  

---

## 1. Executive Summary & Decision Governance

This document records the architectural roadmap decisions, evaluation triggers, and quantitative migration thresholds governing the evolution of eCardo's blockchain, key custody, and financial accounting core.

### 1.1 Governance Philosophy
Every major infrastructure transition—whether expanding multi-chain adapters, migrating key custody to hardware HSMs, or re-architecting the double-entry accounting engine—carries significant operational complexity and security risk. To maintain zero financial loss and uninterrupted platform availability, all architectural transitions must be:
1. **Trigger-Driven:** Initiated strictly when predefined quantitative metrics (volume, latency, asset exposure) or formal regulatory requirements are reached.
2. **Backward-Compatible:** Engineered with dual-run, shadow-traffic, and immediate fallback capabilities.
3. **Audited & Proven:** Validated via isolated proof-of-concept (PoC) sandboxes, automated regression test suites, and independent security reviews prior to production deployment.

```text
+---------------------------------------------------------------------------------------------------+
|                                  Current Operational Baseline                                     |
|  - Chain: TRON Mainnet (TRC20 USDT) via BIP-44 m/44'/195'/0'/0/i                                  |
|  - Key Custody: HashiCorp Vault Transit Engine (Software secp256k1 on isolated VM walet-ecardo)   |
|  - Accounting Core: MariaDB 10.6 InnoDB Double-Entry Ledger (ACID Row-Locks on ecardoq192)        |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  | Quantitative & Event-Driven Triggers
                                                  v
+---------------------------------------------------------------------------------------------------+
|                                     Target Evolution Tracks                                       |
|  Track 1: Multi-Chain EVM & BSC Adapter Expansion (Binance Smart Chain & EVM Chains)              |
|  Track 2: Hardware Security Module (HSM / MPC) Migration ($2.5M AUC / Regulatory Gate)            |
|  Track 3: High-Throughput Ledger Evolution (TigerBeetle Financial Database at 1,200 TPS)           |
+---------------------------------------------------------------------------------------------------+
```

---

## 2. Decision Track 1: Multi-Chain EVM & BSC Adapter Expansion (ADR-BC-01)

- **Decision Reference:** ADR-BC-01  
- **Status:** PROPOSED & SCHEDULED FOR SPRINT 2026-Q4  
- **Primary Driver:** Expanding liquidity corridors, reducing customer gas costs for micro-transfers, and supporting multi-currency digital asset portfolios.  

### 2.1 Context and Technical Evaluation
The operational baseline on `walet-ecardo` (`192.168.200.57`) currently executes transactions on TRON Mainnet (TRC20 USDT) using BIP-44 path `m/44'/195'/0'/0/i`. While TRON provides high throughput and deterministic energy/bandwidth mechanics, customer demand requires support for Binance Smart Chain (BSC / BEP-20) and Ethereum Virtual Machine (EVM) networks (e.g., Ethereum Mainnet, Polygon, Arbitrum).

#### Cryptographic & Protocol Comparison
| Parameter | Current Baseline (TRON) | Proposed Addition (BSC / BEP-20) | Proposed Addition (EVM / Polygon) |
| :--- | :--- | :--- | :--- |
| **Elliptic Curve** | `secp256k1` ECDSA | `secp256k1` ECDSA | `secp256k1` ECDSA |
| **Hash Algorithm** | SHA-256 + RIPEMD-160 | Keccak-256 | Keccak-256 |
| **Address Format** | Base58Check (`T...`) | Hexadecimal with EIP-55 checksum (`0x...`) | Hexadecimal with EIP-55 checksum (`0x...`) |
| **BIP-44 Coin Type** | `195'` (`m/44'/195'/0'/0/i`) | `60'` (`m/44'/60'/0'/0/i`) | `60'` (`m/44'/60'/0'/0/i`) |
| **Chain ID** | `0x2b6653dc` (728126428) | `56` (Mainnet) / `97` (Testnet) | `137` (Polygon) / `1` (Ethereum) |
| **Gas / Fee Model** | Energy & Bandwidth Units | Dynamic Gas Price (Gwei) in BNB | EIP-1559 Base Fee + Priority Tip (POL/ETH) |
| **Consensus Finality** | DPoS (~19 block confirmations) | PoSA (~15 block confirmations) | PoS / Rollup Finality (~128 blocks / state root) |

### 2.2 Target Gateway Architecture: Modular Chain Adapters
To support multi-chain operations without proliferating disparate codebases, `walet-ecardo` will implement a unified `ChainAdapterInterface`:

```text
+---------------------------------------------------------------------------------------------------+
|                                      Wallet Core Orchestrator                                     |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
|                                       ChainAdapterInterface                                       |
|  + estimateFee(tx: TxIntent): FeeQuote                                                            |
|  + deriveAddress(masterKeyRef: string, index: int): string                                        |
|  + buildTransferPayload(to: string, amount: BigInt, contract?: string): RawTx                      |
|  + signAndBroadcast(rawTx: RawTx, keyRef: string): TxResult                                       |
|  + pollConfirmation(txHash: string): ConfirmationStatus                                           |
+---------------------------------------------------------------------------------------------------+
        |                                         |                                         |
        v                                         v                                         v
+-----------------------+                 +-----------------------+                 +-----------------------+
|      TronAdapter      |                 |       BscAdapter      |                 |      BesuEvmAdapter   |
| (TRC20 USDT / Energy) |                 | (BEP20 USDT / BNB Gas)|                 | (Private Consortium)  |
+-----------------------+                 +-----------------------+                 +-----------------------+
```

### 2.3 Activation Prerequisites & Implementation Triggers
The multi-chain adapter expansion will be activated only when all of the following conditions are satisfied:
1. **Commercial Demand Trigger:** Total user transfer requests for BEP-20 / EVM assets account for at least 15% of inbound transfer inquiries over a rolling 30-day window.
2. **Testnet Integration Suite:** 100% pass rate on BSC Testnet (Chain ID 97) and Sepolia (Chain ID 11155111) covering:
   - Dynamic gas estimation under mempool congestion.
   - Nonce management and replacement under `REPLACEMENT_UNDERPRICED` conditions.
   - Deep chain reorganization resilience (handling up to 5-block reorgs without double credits).
3. **Smart Contract Security Audit:** Any token bridge, custody escrow, or timelock contract deployed on BSC or EVM networks must complete a third-party security audit with zero unresolved High or Critical findings.
4. **Private Consortium Evaluation:** If internal inter-branch settlements require a private network, Hyperledger Besu with QBFT consensus will be deployed across four isolated fault domains prior to mainnet public bridge activation.

---

## 3. Decision Track 2: Future Hardware HSM Migration Thresholds (ADR-BC-02)

- **Decision Reference:** ADR-BC-02  
- **Status:** APPROVED FRAMEWORK & THRESHOLD-GATED  
- **Primary Driver:** Eliminating software memory exposure of cryptographic signing keys, establishing physical tamper-resistance, and meeting regulatory compliance mandates.  

### 3.1 Context and Current State
Key derivation and transaction signing on `walet-ecardo` (`192.168.200.57`) currently utilize HashiCorp Vault Transit Engine with AES-256-GCM / secp256k1 software key wrapping. While access is restricted behind network firewalls, dual-token authorization, and policy enforcement, the master key material remains hosted inside virtualized OS memory.

### 3.2 Quantitative & Regulatory Migration Triggers
Migration from virtualized Vault Transit to dedicated Hardware Security Modules (HSM) or Multi-Party Computation (MPC) infrastructure will be triggered upon crossing any of the following quantitative thresholds:

```text
+---------------------------------------------------------------------------------------------------+
| Trigger A: Assets Under Custody (AUC) Exceeds $2,500,000 USD (or equivalent in USDT/EUR)           |
+---------------------------------------------------------------------------------------------------+
| Trigger B: Daily Outbound Withdrawal Velocity Exceeds $250,000 USD for 7 Consecutive Days         |
+---------------------------------------------------------------------------------------------------+
| Trigger C: Formal Acquisition of VASP or Electronic Money Institution (EMI) Regulatory License     |
+---------------------------------------------------------------------------------------------------+
| Trigger D: Enterprise Custody Quorum Requiring Physical Multi-Person (m-of-n) Ceremony Sign-Off   |
+---------------------------------------------------------------------------------------------------+
```

#### Detailed Threshold Specifications
1. **Threshold A — Assets Under Custody (AUC):** When the aggregate value of customer and treasury cryptographic assets held in platform custody exceeds **\$2,500,000 USD**, the capital risk warrants dedicated physical hardware protection.
2. **Threshold B — Transaction Velocity:** When daily outbound transfers exceed **\$250,000 USD** for 7 consecutive days, automated software signers introduce excessive automated drain exposure.
3. **Threshold C — Regulatory Compliance:** Formal submission or granting of a Virtual Asset Service Provider (VASP) license or Central Bank payment processing authorization mandating FIPS 140-2 Level 3 or Level 4 cryptographic module certification.
4. **Threshold D — Quorum Governance:** Institutional enterprise clients requiring physical smart-card m-of-n threshold signing for treasury sweeps exceeding \$50,000 USD.

### 3.3 Target Hardware Platforms & Transition Architecture
Upon crossing an activation trigger, eCardo will execute migration to one of the following evaluated architectures:

| Architecture Option | Target Technology | Security Certification | Strengths | Operational Tradeoffs |
| :--- | :--- | :--- | :--- | :--- |
| **Option 1: Dedicated Hardware HSM** | Thales Luna HSM / YubiHSM 2 / AWS CloudHSM | FIPS 140-2 Level 3 / Level 4 | Physical tamper-zeroization, non-extractable master keys, high cryptographic signing rate. | Higher capital expenditure, dedicated rack hardware, physical maintenance. |
| **Option 2: Multi-Party Computation (MPC)** | Fireblocks / Qredo / Fordefi protocol integration | SOC 2 Type II, ISO 27001 | Eliminates single root key; key shares split across server, cloud, and mobile guardian. | External SaaS SLA dependency, monthly recurring API licensing cost. |

### 3.4 Zero-Downtime Transition Protocol
1. **Parallel Signer Bridge:** Deploy the hardware HSM alongside the existing Vault Transit engine.
2. **New Key Reference Generation:** Generate new master root references within the HSM without exporting keys.
3. **Gradual User Migration:** New user wallets are provisioned using HSM-derived child keys (`m/44'/195'/0'/0/i_new`). Existing active wallets are migrated during scheduled sweeps.
4. **Legacy Vault Retirement:** The software Vault Transit engine is transitioned to read-only verification mode and decommissioned only after all historical customer balances have been reconciled and swept.

---

## 4. Decision Track 3: High-Throughput Accounting Ledger — TigerBeetle Evaluation Triggers (ADR-BC-03)

- **Decision Reference:** ADR-BC-03  
- **Status:** EVALUATION FRAMEWORK ESTABLISHED  
- **Primary Driver:** Eliminating relational database row-lock contention on omnibus accounts, preventing garbage collection pauses, and scaling double-entry ledger throughput.  

### 4.1 Context and Technical Evaluation
eCardo's primary financial ledger currently resides in MariaDB 10.6 (`ecardoq192`) running InnoDB with strict ACID transaction isolation and row-level locking (`SELECT ... FOR UPDATE`). A synchronized edge SQLite database runs on `walet-ecardo`.

While MariaDB provides excellent relational querying and audit trail capabilities, centralized fintech super-apps encounter severe lock contention on high-velocity omnibus accounts (such as platform fee revenue accounts, central liquidity pools, and merchant checkout accounts). When thousands of concurrent mobile clients submit transfers simultaneously, serialized row locks create query queues, increasing P99 latency and risking thread pool exhaustion.

#### Technical Analysis: TigerBeetle Financial Database
TigerBeetle is a specialized, open-source distributed financial accounting database written in Zig, purpose-built for financial transactions:
- **Consensus & Fault Tolerance:** Uses Viewstamped Replication (VSR) consensus with deterministic state machine replication, surviving network partitions and disk corruption.
- **Data Model:** Native double-entry accounting primitives with 128-bit unsigned integer account IDs, transfer balances, and currency unit codes. Floating-point arithmetic is structurally impossible.
- **Performance:** Direct I/O storage engine with zero memory allocation after startup, executing up to **1,000,000 transfer operations per second** with sub-millisecond commit latency.

### 4.2 Concrete Evaluation Triggers & Thresholds
Transitioning from MariaDB to a dedicated TigerBeetle financial ledger core will be initiated upon crossing any of the following operational triggers:

```text
+---------------------------------------------------------------------------------------------------+
| Trigger 1: Sustained Transfer Throughput Exceeds 1,200 Financial Transactions Per Second (TPS)     |
+---------------------------------------------------------------------------------------------------+
| Trigger 2: MariaDB Database CPU Exceeds 75% Solely Due to Row-Lock Contention on Omnibus Accounts  |
+---------------------------------------------------------------------------------------------------+
| Trigger 3: P99 Commit Latency on Double-Entry Journal Entries Exceeds 250 Milliseconds            |
+---------------------------------------------------------------------------------------------------+
| Trigger 4: Historical Journal Entries Exceed 100,000,000 Rows Causing Partition Bottlenecks        |
+---------------------------------------------------------------------------------------------------+
```

### 4.3 Phased Adoption & Dual-Ledger Roadmap

```text
[Phase 1: Shadow CDC Ingestion]  -->  [Phase 2: Parallel Dual-Write]  -->  [Phase 3: TigerBeetle Authority]
MariaDB commits primary;               Both engines commit;                TigerBeetle commits primary;
Debezium replicates to TigerBeetle.    Real-time reconciliation alerts.    MariaDB serves analytical queries.
```

1. **Phase 1 — Shadow CDC Ingestion (PoC):**
   - MariaDB remains the authoritative ledger.
   - A Change Data Capture (CDC) connector (Debezium/Kafka) streams committed journal entries into a standalone TigerBeetle evaluation cluster.
   - Benchmark commit latencies, resource consumption, and crash-recovery determinism under synthetic 5,000 TPS load bursts.
2. **Phase 2 — Parallel Dual-Write & Continuous Reconciliation:**
   - The backend `TransferOrchestrator` writes to both MariaDB and TigerBeetle within the transfer execution pipeline.
   - An automated background reconciler continuously verifies that TigerBeetle balances match MariaDB balances to the exact integer unit. Any delta triggers an immediate `reconciliation.mismatch_detected` event.
3. **Phase 3 — TigerBeetle Primary Authority:**
   - TigerBeetle is promoted to the authoritative system of record for account balances and transfer reservations.
   - MariaDB is retained as the downstream relational datastore for user profiles, KYC metadata, complex historical reporting, and tax document generation.

---

## 5. Architectural Assumptions & Blocker Resolution Matrix

This registry tracks the status, working assumptions, and resolution milestones for the critical architectural questions identified in Phase 0 research (`22_DECISIONS_AND_ASSUMPTIONS_FA.md`):

| Item ID | Architectural Question / Assumption | Current Working Assumption | Impacted Systems | Assigned Lead | Target Resolution Milestone | Risk Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **BL-01** | **Node Technology & Version:** Exact node client binary and network version. | Dedicated host `walet-ecardo` running TRON client daemon and `/opt/wallet-platform/bin/walletctl`. | `walet-ecardo`, Bridge | Infrastructure SRE Lead | Milestone M-01 (Completed) | [RESOLVED] |
| **BL-02** | **Chain Identity & EVM Compatibility:** Network ID, consensus, and curve. | TRON Mainnet (Chain ID 728126428, `secp256k1`). EVM compatibility evaluated under ADR-BC-01. | Key Derivation, Relayer | Blockchain Architect | Milestone M-02 (Active Review) | [LOW RISK] |
| **BL-03** | **Validator Distribution & Quorum:** Physical machine segregation across fault domains. | Private subnet deployment. Besu QBFT evaluation requires 4 independent hosts for quorum. | Blockchain Node, Infra | SRE Lead | Milestone M-03 (Post-Phase 1) | [MEDIUM RISK] |
| **BL-04** | **Unique Key vs Mnemonic Seed:** User recovery phrase vs institutional key reference. | Custodial HD derivation (`m/44'/195'/0'/0/i`). Zero mnemonic exposure to end users; institutional recovery. | Flutter App, Key Vault | Security Architect | Milestone M-01 (Approved) | [RESOLVED] |
| **BL-05** | **Custody Model & Responsibility:** Custodial, self-custody, or hybrid smart account. | Full institutional custody by eCardo in v1.0. User holds account authentication; platform holds cryptographic keys. | Product, Legal, Security | Chief Systems Architect | Milestone M-01 (Approved) | [RESOLVED] |
| **BL-06** | **Source of Truth per Asset:** Canonical ledger authority by asset class. | Fiat/Cards = MariaDB (`ecardoq192`); On-chain crypto = TRON blockchain receipts reconciled with ledger. | Ledger, Reconciliation | Core Financial Lead | Milestone M-01 (Approved) | [RESOLVED] |
| **BL-07** | **External Transfer Scope:** Internal ledger vs on-chain vs fiat banking wire. | Internal transfers = zero-fee ledger entries; External crypto = signed on-chain broadcast via `walet-ecardo`. | Transfer Orchestrator | Backend Architect | Milestone M-02 (In Progress) | [LOW RISK] |
| **BL-08** | **Card Processor Funding Linkage:** Card account on-chain vs ledger funding. | Payment cards are external instruments backed by relational funding accounts, NOT individual on-chain keys. | Card Service, MariaDB | Fintech Lead | Milestone M-01 (Approved) | [RESOLVED] |
| **BL-09** | **Smart Contract Upgrade Governance:** Admin key ownership and timelock delays. | Multi-signature admin requirement with 48-hour timelock delay for any smart contract upgrade. | Smart Contracts, Safe | Blockchain Architect | Milestone M-03 (Planned) | [LOW RISK] |
| **BL-10** | **Regulatory Jurisdiction & Data Residency:** Sovereign server constraints. | All production workloads and audit data must remain on sovereign servers (`serv.interex.ir`), zero foreign cloud dependencies. | Entire Infrastructure | Legal & Compliance Lead | Continuous Invariant | [RESOLVED] |

---

## 6. Review Cadence & Document Lifecycle

1. **Quarterly Review:** This document is reviewed at the conclusion of each engineering quarter by the Architecture Review Board (ARB).
2. **Trigger Monitoring:** Telemetry and SRE dashboards monitor the quantitative triggers for HSM migration (AUC > \$2.5M) and TigerBeetle evaluation (TPS > 1,200). When a metric approaches 80% of its trigger threshold, an automated notification is dispatched to engineering leadership to initiate formal PoC planning.
