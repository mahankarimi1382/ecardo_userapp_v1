# 08. Chain & Wallet Platform Runbook

**Document Version:** 1.0.0  
**Target Environment:** walet-ecardo (`192.168.200.57`) via Bastion `serv.interex.ir` (`192.168.100.65`)  
**Repository:** `ecardo_userapp_v1`  
**Classification:** Internal Confidential / SRE & Operations  
**Date:** 2026-10-18  

---

## 1. Executive Summary & Infrastructure Topology

The eCardo Wallet & Payment Platform operates as a high-performance, low-footprint microservices infrastructure deployed on the dedicated host `walet-ecardo` (`192.168.200.57`). It provides non-custodial and custodial crypto-asset management (specifically TRON TRC20 USDT), double-entry ledger bookkeeping, isolated transaction signing, and fiat gateway integration (Behpardakht Mellat PSP).

```
                      +---------------------------------------+
                      |        Client Tier (Flutter App)       |
                      +---------------------------------------+
                                          |
                                    HTTPS / TLS 1.3
                                          v
+-----------------------------------------------------------------------------------+
| Bastion / Gateway (192.168.100.65)                                                |
| - mTLS / Reverse Proxy                                                            |
| - Rate Limiting & Firewall Isolation                                              |
+-----------------------------------------------------------------------------------+
                                          |
                            Private Network / Direct TCP
                                          v
+-----------------------------------------------------------------------------------+
| walet-ecardo (192.168.200.57)                                                     |
| [Resources: 4 vCPU, 3.8 GB RAM | OS: Linux / Ubuntu LTS]                          |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  | systemd: wallet-api.service (Port 8000)                                     |  |
|  | - REST Endpoints (/health, /ready, /api/v1/wallets, /api/v1/withdrawals)   |  |
|  +-----------------------------------------------------------------------------+  |
|  | systemd: wallet-dashboard.service (Port 8080)                               |  |
|  | - Administrative SRE & Operations Management UI                             |  |
|  +-----------------------------------------------------------------------------+  |
|                                                                                   |
|  Core Service Daemons & Engines (/opt/wallet-platform):                            |
|  * services.listener.service.ChainListenerService                                 |
|  * services.signer.service.SignerService (Isolated Boundary)                      |
|  * services.sweeper.service.SweeperService (Hot Treasury Aggregation)            |
|  * services.reconciliation.service.ReconciliationService (Triple Ledger Engine)   |
|  * packages.security.vault.VaultService (PBKDF2-HMAC-SHA256 Encrypted Store)       |
|  * packages.ledger.engine.LedgerEngine (Immutable Double-Entry Accounting)         |
|  * packages.providers.mellat.MellatPaymentAdapter (Fiat PSP Routing)              |
|                                                                                   |
|  Persistent Storage:                                                              |
|  * /opt/wallet-platform/data/wallet.db (SQLite 3 with WAL Journal Mode)           |
+-----------------------------------------------------------------------------------+
```

---

## 2. Daemons & Systemd Service Management

All core services on `walet-ecardo` are controlled via `systemd`. The primary REST API runs under `wallet-api.service`, and the operations portal runs under `wallet-dashboard.service`.

### 2.1 Primary Service: `wallet-api.service`

- **Unit File:** `/etc/systemd/system/wallet-api.service`
- **Execution Target:** `/usr/bin/python3 /opt/wallet-platform/apps/wallet-api/server.py`
- **Internal Port:** `8000` (`0.0.0.0:8000`)
- **Execution User:** `ecardo`
- **Working Directory:** `/opt/wallet-platform`
- **Environment:** `PYTHONPATH=/opt/wallet-platform`
- **Restart Policy:** `Restart=always`, `RestartSec=3`

#### Standard Management Commands

```bash
# Check service status and active thread/process metrics
sudo systemctl status wallet-api

# Restart wallet-api service gracefully
sudo systemctl restart wallet-api

# Stop wallet-api service
sudo systemctl stop wallet-api

# Start wallet-api service
sudo systemctl start wallet-api

# View live systemd logs
journalctl -u wallet-api -f -n 100
```

### 2.2 Dashboard Service: `wallet-dashboard.service`

- **Unit File:** `/etc/systemd/system/wallet-dashboard.service`
- **Execution Target:** `/usr/bin/python3 /opt/wallet-platform/apps/web_dashboard/server.py 8080`
- **Internal Port:** `8080`
- **Execution User:** `ecardo`
- **Working Directory:** `/opt/wallet-platform`

#### Standard Management Commands

```bash
# Check dashboard status
sudo systemctl status wallet-dashboard

# Restart dashboard service
sudo systemctl restart wallet-dashboard

# View dashboard access logs
journalctl -u wallet-dashboard -f -n 50
```

### 2.3 Subsystem Lifecycle Overview

| Subsystem Component | Module Location | Execution Model | Failure Mode |
|---|---|---|---|
| **API Server** | `apps/wallet-api/server.py` | Standalone HTTP Daemon | HTTP 503 / systemd auto-restart in 3s |
| **Chain Listener** | `services/listener/service.py` | Embedded / Periodic Poller | Checkpoint saved; resumes on restart without event loss |
| **Isolated Signer** | `services/signer/service.py` | In-Process Boundary | Fail closed; rejects invalid or duplicate signing |
| **Sweeper Daemon** | `services/sweeper/service.py` | Batch Consolidation Worker | Skips unconfirmed balances; retries next cycle |
| **Reconciliation Engine** | `services/reconciliation/service.py` | Periodic / CLI On-Demand | Alerts SRE; blocks automatic balance sync if unbalanced |
| **Mellat PSP Adapter** | `packages/providers/mellat.py` | Synchronous / Webhook Callback | Rejects invalid res_code; idempotent verification |

---

## 3. Health Checks & Observability Probes

The platform exposes synchronous HTTP probes for orchestration, monitoring, and automated load balancer health checks.

### 3.1 HTTP Probes Reference

#### 1. Liveness Probe: `GET /health` (or `GET /api/v1/health`)
- **Purpose:** Verifies process execution and internal event loop responsiveness.
- **Port:** `8000`
- **Expected Status:** `200 OK`
- **Response Schema:**
```json
{
  "status": "HEALTHY",
  "time": 1776510123.456,
  "platform": "ecardo-wallet-local"
}
```

#### 2. Readiness Probe: `GET /ready` (or `GET /api/v1/ready`)
- **Purpose:** Verifies that internal cryptographic secrets are accessible and Vault is unsealed.
- **Port:** `8000`
- **Expected Status:** `200 OK` (when operational)
- **Response Schema:**
```json
{
  "ready": true,
  "vault_sealed": false
}
```
*Note: If `vault_sealed` is `true`, all transaction signing and withdrawal endpoints immediately fail closed.*

#### 3. Reconciliation Probe: `GET /api/v1/reconciliation`
- **Purpose:** On-demand audit of the double-entry accounting ledger balance and fiat gateway state.
- **Port:** `8000`
- **Expected Status:** `200 OK`
- **Response Schema:**
```json
{
  "balanced": true,
  "mismatches": [],
  "currencies_checked": ["USDT", "IRR"],
  "status": "PASS"
}
```

#### 4. User Balance Query Probe: `GET /api/v1/wallets/user/{user_id}/balance`
- **Purpose:** Diagnostic inspection of projected balance directly from immutable ledger entries.
- **Port:** `8000`
- **Expected Status:** `200 OK`
- **Response Schema:**
```json
{
  "user_id": "usr-88f29c10",
  "balances": {
    "USDT": "150.00",
    "IRR": "50000000"
  }
}
```

### 3.2 Operating System & Storage Diagnostics

Execute directly on `walet-ecardo`:

```bash
# 1. Verify SQLite WAL mode and file locks
ls -lh /opt/wallet-platform/data/wallet.db*

# 2. Check SQLite database integrity
sqlite3 /opt/wallet-platform/data/wallet.db "PRAGMA integrity_check;"
# Expected output: ok

# 3. Inspect WAL journal state
sqlite3 /opt/wallet-platform/data/wallet.db "PRAGMA wal_checkpoint(PASSIVE);"

# 4. Check memory and CPU usage
free -m
uptime
```

---

## 4. `walletctl` CLI Reference Manual

The `walletctl` CLI utility (`/opt/wallet-platform/bin/walletctl`) provides operators with a direct command-line interface for telemetry, database auditing, reconciliation execution, and emergency controls.

### 4.1 CLI Syntax

```bash
python3 /opt/wallet-platform/bin/walletctl <command> [subcommand/args]
```

### 4.2 Command Matrix

| Command | Subcommands / Args | Description | Target Subsystem |
|---|---|---|---|
| `status` | None | Displays overall platform operational status, chain contracts, fiat gateway, Vault status, and ledger condition. | Global Overview |
| `health` | None | Performs instant database connectivity, registered user counts, and Vault unseal verification. | Health Audit |
| `db` | `status` | Outputs exact row counts for `users`, `wallets`, `deposits`, `withdrawals`, `ledger_entries`, `rial_payments`. | Storage Layer |
| `reconciliation` | `run` | Triggers a full mathematical reconciliation across USDT and IRR journal entries and external gateways. | Financial Ledger |
| `emergency` | `pause` | Triggers a global withdrawal and operations halt across the entire platform. | Security & Risk |
| `emergency` | `resume` | Resumes normal operations following authorized dual-control approval. | Security & Risk |
| `web` | `[port]` (default: 8080) | Launches the interactive web management dashboard in foreground. | SRE Portal |

### 4.3 Command Examples & Expected Output

#### Platform Status Check
```bash
python3 /opt/wallet-platform/bin/walletctl status
```
*Output:*
```text
=== ecardo Wallet & Payment Infrastructure Status (Local) ===
Chain: TRON TRC20 USDT (Contract: TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t)
Fiat Gateway: Behpardakht Mellat Adapter
Vault Status: Active / Unsealed
Double-Entry Ledger: Balanced & Immutable
```

#### Health Diagnostic
```bash
python3 /opt/wallet-platform/bin/walletctl health
```
*Output:*
```text
=== Health Check ===
Database: OK (34 users registered)
Vault: OK (Sealed: False)
System API: READY
```

#### Database Metrics Inspection
```bash
python3 /opt/wallet-platform/bin/walletctl db status
```
*Output:*
```text
  Table users           : 34 rows
  Table wallets         : 34 rows
  Table deposits        : 18 rows
  Table withdrawals     : 12 rows
  Table ledger_entries  : 142 rows
  Table rial_payments   : 28 rows
```

#### Full Triple-Ledger Reconciliation
```bash
python3 /opt/wallet-platform/bin/walletctl reconciliation run
```
*Output:*
```text
Running full reconciliation...
Result: {
  "balanced": true,
  "mismatches": [],
  "currencies_checked": [
    "USDT",
    "IRR"
  ],
  "status": "PASS"
}
```

---

## 5. Chain Listener Operations & Confirmation Policy

The Chain Listener (`services/listener/service.py`) monitors on-chain TRC20 transfer events for registered deposit addresses and updates the ledger once blocks reach finality.

### 5.1 Chain Parameters

- **Target Chain:** TRON Mainnet / Private EVM-equivalent
- **Smart Contract:** TRC20 USDT (`TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t`)
- **Block Time:** ~3 seconds per block
- **Minimum Confirmations Policy:** **19 Blocks** (~57 seconds)
  - Formula: `confirmations = max(0, current_head - block_number)`
  - Rationale: In DPoS/TRON networks, 19 blocks provide supermajority witness finality, mitigating block reorganization (reorg) risks.

### 5.2 Deposit Processing State Machine

```
   [On-Chain Transfer Detected]
                 |
                 v
       +-------------------+
       | Status: DETECTED  | ---> Insert row in `deposits` table
       +-------------------+
                 |
        Confirmations < 19
                 |
                 v
       +-------------------+
       | Status: PENDING   | ---> Update confirmations in DB
       +-------------------+
                 |
        Confirmations >= 19
                 |
                 v
       +-------------------+
       | Status: CREDITED  | ---> Execute `LedgerEngine.credit_deposit`
       +-------------------+      Dr Treasury:USDT / Cr User:{id}:USDT
                 |
        [Duplicate Scan Alert]
                 v
    +--------------------------+
    | Status: ALREADY_CREDITED | ---> No ledger mutation (Idempotent)
    +--------------------------+
```

### 5.3 Listener Checkpoint & Recovery Procedure

1. If the listener process restarts, it reads the maximum `block_number` from the `deposits` table or dedicated sync checkpoint.
2. It resumes block polling from `checkpoint_block - 20` to guarantee overlap coverage.
3. Every detected transaction hash is checked against the database with a unique index constraint. Duplicate incoming transfers return `ALREADY_CREDITED` and do not cause duplicate balance credits (verified in IT-07).

---

## 6. Consolidation Sweeper Runbook

The Consolidation Sweeper (`services/sweeper/service.py`) automates the movement of user deposits from child deposit addresses to the platform Hot Treasury.

### 6.1 Sweeper Configuration

- **Hot Treasury Address:** `T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb`
- **Sweep Threshold (`MIN_SWEEP_AMOUNT`):** `10.00 USDT`
- **Asset:** USDT (TRC20)

### 6.2 Energy & Gas Fee Protocol

TRC20 transfers on the TRON network require Energy and Bandwidth. If a child deposit address does not hold sufficient TRX or staked energy, standard transfer calls will fail.

#### Energy Provisioning Standard Operating Procedure:
1. **Fee-Delegation / Sponsor:** eCardo utilizes a central fee-pooling wallet to delegate energy to the child deposit address prior to broadcasting the transfer.
2. **Pre-Sweep Check:** The sweeper verifies that `child_address.energy >= 32,000` or `child_address.trx_balance >= 15.0 TRX` before submitting the sweep transaction.
3. **Execution:** The isolated signer derives the child private key at index $i$, signs the TRC20 `transfer(to=HOT_TREASURY, amount)` payload, and broadcasts it to the network.

---

## 7. Standard Operating Procedures (SOPs)

### SOP-01: Scheduled Maintenance & Service Restart

1. **Notify Operations:** Declare maintenance window in change management tracker.
2. **Trigger Safety Pause:**
   ```bash
   python3 /opt/wallet-platform/bin/walletctl emergency pause
   ```
3. **Wait for In-Flight Operations:** Monitor active requests:
   ```bash
   journalctl -u wallet-api -n 20
   ```
4. **Perform Safe Restart:**
   ```bash
   sudo systemctl restart wallet-api
   sudo systemctl restart wallet-dashboard
   ```
5. **Verify Health:**
   ```bash
   python3 /opt/wallet-platform/bin/walletctl health
   curl -s http://127.0.0.1:8000/ready
   ```
6. **Resume Operations:**
   ```bash
   python3 /opt/wallet-platform/bin/walletctl emergency resume
   ```

### SOP-02: Database Online Backup & Compaction

1. SQLite allows live online backups without locking active readers/writers.
2. Execute backup to secure off-host storage directory:
   ```bash
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   sqlite3 /opt/wallet-platform/data/wallet.db ".backup '/opt/wallet-platform/data/backups/wallet_${TIMESTAMP}.bak'"
   ```
3. Checkpoint WAL log into main DB file:
   ```bash
   sqlite3 /opt/wallet-platform/data/wallet.db "PRAGMA wal_checkpoint(TRUNCATE);"
   ```
4. Encrypt and transfer backup file off-site (verified in IT-20).

### SOP-03: Resolving Node Lag or Desynchronization

1. Check current head vs local confirmed block:
   ```bash
   # Query node block height via curl
   curl -s -X POST http://192.168.200.57:8090/wallet/getnowblock | jq .block_header.raw_data.number
   ```
2. If local listener lag exceeds 50 blocks:
   - Check upstream network connectivity on Bastion (`192.168.100.65`).
   - Verify TRON RPC endpoint latency and rate limits.
   - Restart listener subsystem.
3. Confirm that no pending deposits are stuck in `PENDING` longer than 15 minutes.
