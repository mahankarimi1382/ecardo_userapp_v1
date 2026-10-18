# 04. Wallet Registry Schema & Architecture

## 1. Executive Summary & Scope

The Wallet Registry serves as the canonical inventory and lifecycle management authority for all cryptographic and digital asset addresses within the eCardo ecosystem. It establishes a strictly governed, relational model connecting customer accounts, institutional custody domains, multi-chain addresses, and balance subaccounts.

### Core Architecture Principles
1. **Zero Raw Secret Storage:** No seed phrases, mnemonics, extended private keys (xprv), or raw private keys are ever stored in the database, application memory, or system logs. Only opaque key references (`key_ref`), derivation metadata, and public addresses are cataloged.
2. **Strict Multi-Chain Identity:** Unambiguous tracking of assets and addresses across networks (e.g., TRON TRC20, EVM networks, private eCardo chain), preventing cross-chain collisions and routing mistakes.
3. **Immutable Financial History:** Financial records, transaction linkages, and ledger entries are permanently preserved. Deletion of wallets, addresses, or historical balances is strictly prohibited at both the application and database trigger levels.
4. **Lifecycle State Machine:** All state transitions (e.g., `ACTIVE` -> `SUSPENDED` -> `FROZEN` -> `CLOSED` -> `ARCHIVED`) are validated, auditable, and driven by explicit business rules.

---

## 2. Domain Entities & Separation of Concerns

The registry differentiates between operational domains, custody boundaries, and balance categories:

```text
+---------------------------------------------------------------------------------------+
|                                    eCardo Platform                                    |
+---------------------------------------------------------------------------------------+
        |                                                              |
        v                                                              v
+-------------------------------+                       +-------------------------------+
|      Custody Domain: User     |                       |    Custody Domain: Treasury   |
| (Customer Wallets, BIP-44 HD) |                       |  (Hot / Warm / Cold Reserves) |
+-------------------------------+                       +-------------------------------+
        |                                                              |
        +-------------------------------+------------------------------+
                                        |
                                        v
                    +---------------------------------------+
                    |        Wallet Registry Schema         |
                    |---------------------------------------|
                    |  wallets                              |
                    |  wallet_addresses                     |
                    |  wallet_assets                        |
                    |  wallet_state_transitions             |
                    |  wallet_key_metadata                  |
                    +---------------------------------------+
                                        |
                    +-------------------+-------------------+
                    |                                       |
                    v                                       v
    +-------------------------------+       +-------------------------------+
    |    Central MariaDB Ledger     |       |    walet-ecardo SQLite Edge   |
    |          (ecardoq192)         |       |      (192.168.200.57:8000)    |
    |  System of Record Accounting  |       |   Signer & Local Edge State   |
    +-------------------------------+       +-------------------------------+
```

### 2.1 Custody Domains
- **`USER_CUSTODIAL`:** End-user wallets managed under platform custody using deterministic BIP-44 key derivation (`m/44'/195'/0'/0/i` for TRON/USDT). Keys are held in isolated Hardware Security Modules (HSM) or secure vaults.
- **`TREASURY_HOT`:** Low-balance operational wallets used for immediate payouts, fee relaying, and platform sponsorship. Subject to automated velocity caps and continuous refill thresholds.
- **`TREASURY_WARM`:** Intermediate treasury wallets managed with dual-authorization requirements, used to replenish hot wallets and aggregate incoming sweep transactions.
- **`TREASURY_COLD`:** Multi-signature / offline storage reserves containing the vast majority of platform reserves. Withdrawals require out-of-band quorum authorization.

---

## 3. Database Schema Specification (MariaDB & SQLite DDL)

The schema is designed for full relational consistency in central MariaDB (`ecardoq192`) and edge SQLite engines (`walet-ecardo`).

### 3.1 Table: `wallets`
Represents the primary logical wallet container assigned to a user, merchant, or internal operational entity.

```sql
CREATE TABLE wallets (
    id VARCHAR(36) NOT NULL,
    owner_id VARCHAR(36) NOT NULL,
    owner_type ENUM('USER', 'MERCHANT', 'SYSTEM_TREASURY', 'SYSTEM_ESCROW') NOT NULL DEFAULT 'USER',
    custody_domain ENUM('USER_CUSTODIAL', 'TREASURY_HOT', 'TREASURY_WARM', 'TREASURY_COLD') NOT NULL DEFAULT 'USER_CUSTODIAL',
    lifecycle_state ENUM('PROVISIONING', 'PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'FROZEN', 'CLOSING', 'CLOSED', 'ARCHIVED', 'COMPROMISED', 'RECOVERY_PENDING') NOT NULL DEFAULT 'PROVISIONING',
    previous_state ENUM('PROVISIONING', 'PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'FROZEN', 'CLOSING', 'CLOSED', 'ARCHIVED', 'COMPROMISED', 'RECOVERY_PENDING') NULL,
    state_reason VARCHAR(255) NULL,
    state_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    security_tier ENUM('STANDARD', 'ELEVATED', 'VIP_ENTERPRISE') NOT NULL DEFAULT 'STANDARD',
    version BIGINT UNSIGNED NOT NULL DEFAULT 1,
    is_tombstoned BOOLEAN NOT NULL DEFAULT FALSE,
    tombstone_reason VARCHAR(255) NULL,
    tombstoned_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    INDEX idx_wallets_owner (owner_id, owner_type),
    INDEX idx_wallets_state (lifecycle_state),
    INDEX idx_wallets_custody (custody_domain)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 3.2 Table: `wallet_addresses`
Maps cryptographic blockchain addresses across specific networks and chains to a parent wallet.

```sql
CREATE TABLE wallet_addresses (
    id VARCHAR(36) NOT NULL,
    wallet_id VARCHAR(36) NOT NULL,
    chain_id VARCHAR(32) NOT NULL,          -- e.g., 'TRON_MAINNET', 'ETH_MAINNET', 'ECARDO_CHAIN_1'
    network_id VARCHAR(32) NOT NULL,        -- e.g., 'MAINNET', 'TESTNET_NILE', 'SEPOLIA'
    address VARCHAR(128) NOT NULL,          -- Base58 (TRON) or Hex (EVM)
    address_format ENUM('BASE58CHECK', 'HEX_0X', 'BECH32') NOT NULL DEFAULT 'BASE58CHECK',
    derivation_index INT UNSIGNED NOT NULL, -- BIP-44 address_index
    is_primary BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified_on_chain BOOLEAN NOT NULL DEFAULT FALSE,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    CONSTRAINT fk_wallet_addresses_wallet FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    
    -- Invariant: An on-chain address must never be duplicated within the same chain and network
    UNIQUE KEY uq_chain_network_address (chain_id, network_id, address),
    
    -- Invariant: Derivation index must be strictly unique per wallet and chain
    UNIQUE KEY uq_wallet_chain_derivation (wallet_id, chain_id, derivation_index),
    
    INDEX idx_addresses_lookup (address),
    INDEX idx_addresses_chain (chain_id, network_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 3.3 Table: `wallet_assets`
Maintains the asset configuration and cached balance summary per asset for rapid UI queries. Note: The canonical financial source of truth is always the Double-Entry Ledger, not cached rows.

```sql
CREATE TABLE wallet_assets (
    id VARCHAR(36) NOT NULL,
    wallet_id VARCHAR(36) NOT NULL,
    asset_id VARCHAR(32) NOT NULL,          -- e.g., 'USDT', 'TRX', 'EUR', 'IRR'
    chain_id VARCHAR(32) NOT NULL,          -- e.g., 'TRON_MAINNET', 'OFFCHAIN_FIAT'
    token_contract_address VARCHAR(128) NULL, -- TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t for USDT TRC20
    decimal_places TINYINT UNSIGNED NOT NULL DEFAULT 6,
    
    -- Minor unit balances (stored as signed BIGINT; never IEEE floating point)
    balance_available_minor BIGINT NOT NULL DEFAULT 0,
    balance_reserved_minor BIGINT NOT NULL DEFAULT 0,
    balance_locked_minor BIGINT NOT NULL DEFAULT 0,
    
    is_deposit_allowed BOOLEAN NOT NULL DEFAULT TRUE,
    is_withdrawal_allowed BOOLEAN NOT NULL DEFAULT TRUE,
    last_journal_entry_id VARCHAR(36) NULL,
    last_reconciled_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    CONSTRAINT fk_wallet_assets_wallet FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    
    -- Invariant: One asset record per wallet, asset, and chain
    UNIQUE KEY uq_wallet_asset_chain (wallet_id, asset_id, chain_id),
    
    INDEX idx_assets_wallet_asset (wallet_id, asset_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 3.4 Table: `wallet_key_metadata`
Stores derivation schemas and key references without exposing secrets.

```sql
CREATE TABLE wallet_key_metadata (
    id VARCHAR(36) NOT NULL,
    wallet_id VARCHAR(36) NOT NULL,
    key_provider ENUM('VAULT_HSM', 'LOCAL_SECURE_STORAGE', 'EXTERNAL_MPC', 'AWS_KMS') NOT NULL DEFAULT 'VAULT_HSM',
    key_ref VARCHAR(255) NOT NULL,          -- Opaque KMS Key ID or Vault Secret Path (e.g. 'vault:secret/data/keys/root_v1')
    key_version VARCHAR(32) NOT NULL DEFAULT '1.0',
    derivation_scheme VARCHAR(32) NOT NULL DEFAULT 'BIP44',
    derivation_path_encrypted TEXT NOT NULL, -- Encrypted at rest using envelope encryption; never plaintext in DB
    curve ENUM('SECP256K1', 'ED25519') NOT NULL DEFAULT 'SECP256K1',
    public_key_compressed VARCHAR(66) NOT NULL, -- 33-byte hex compressed public key
    rotation_status ENUM('CURRENT', 'ROTATING', 'RETIRED', 'REVOKED') NOT NULL DEFAULT 'CURRENT',
    rotated_to_key_id VARCHAR(36) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    CONSTRAINT fk_wallet_keys_wallet FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    INDEX idx_keys_ref (key_ref)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 3.5 Table: `wallet_state_transitions` (Append-Only Audit Trail)
Records every status change for auditing and governance compliance.

```sql
CREATE TABLE wallet_state_transitions (
    id VARCHAR(36) NOT NULL,
    wallet_id VARCHAR(36) NOT NULL,
    from_state VARCHAR(32) NOT NULL,
    to_state VARCHAR(32) NOT NULL,
    actor_id VARCHAR(36) NOT NULL,
    actor_role VARCHAR(64) NOT NULL,
    reason_code VARCHAR(64) NOT NULL,
    reason_details TEXT NULL,
    approval_ids JSON NULL,                 -- Array of four-eyes approval IDs if required
    client_request_id VARCHAR(64) NOT NULL,
    payload_hash VARCHAR(64) NOT NULL,      -- SHA-256 of transition payload
    transitioned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    CONSTRAINT fk_state_transitions_wallet FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    INDEX idx_transitions_wallet (wallet_id, transitioned_at),
    INDEX idx_transitions_actor (actor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 4. Lifecycle States & Finite State Machine (FSM)

The lifecycle of an eCardo wallet is strictly governed. Transition rules guarantee that funds cannot be lost, trapped, or moved illegally.

```text
               +----------------------------------------------------+
               |                   PROVISIONING                     |
               +----------------------------------------------------+
                                         |
                                         | [Key Generated & Derived]
                                         v
               +----------------------------------------------------+
               |               PENDING_VERIFICATION                 |
               +----------------------------------------------------+
                                         |
                                         | [KYC & Policy Check Passed]
                                         v
               +----------------------------------------------------+
      +------->|                      ACTIVE                        |<-------+
      |        +----------------------------------------------------+        |
      |                 |                       |              |             |
      | [Clear Review]  | [AML / Risk Trigger]  | [Voluntary]  | [Breach]    | [Audit Clear]
      |                 v                       v              |             |
      |        +-----------------+     +-----------------+     |             |
      +--------|    SUSPENDED    |     |     CLOSING     |     |             |
      |        +-----------------+     +-----------------+     |             |
      |                 |                       |              |             |
      | [Escalation]    v                       | [Zero Bal]   |             |
      |        +-----------------+              v              v             |
      |        |     FROZEN      |     +-----------------+  +--------------+ |
      +--------| (Legal / Court) |     |     CLOSED      |  | COMPROMISED  |-+
               +-----------------+     +-----------------+  +--------------+
                        |                       |                  |
                        | [Zero Bal & Expire]   | [180d Inactive]  v
                        +-----------+-----------+        +-------------------+
                                    |                    | RECOVERY_PENDING  |
                                    v                    +-------------------+
                       +-------------------------+
                       |        ARCHIVED         |
                       | (Soft Tombstone Sealed) |
                       +-------------------------+
```

### 4.1 State Definitions
| State | Operational Capabilities | Financial Restrictions | Allowed Next States |
| :--- | :--- | :--- | :--- |
| **`PROVISIONING`** | Address derived, database entities allocated. | No deposits or withdrawals allowed. | `PENDING_VERIFICATION`, `CLOSED` |
| **`PENDING_VERIFICATION`** | Awaiting user KYC tier confirmation or policy binding. | Inbound transfers hold in pending; outgoing disabled. | `ACTIVE`, `SUSPENDED`, `CLOSED` |
| **`ACTIVE`** | Full operations enabled according to account limits. | Unrestricted within configured velocity limits. | `SUSPENDED`, `FROZEN`, `CLOSING`, `COMPROMISED` |
| **`SUSPENDED`** | Temporary hold triggered by risk scoring or anomaly. | Outgoing transactions blocked; incoming deposits accepted. | `ACTIVE`, `FROZEN`, `CLOSED` |
| **`FROZEN`** | Administrative / legal hold (court order, fraud, sanctions). | Complete freeze on outgoing and incoming movements. | `ACTIVE`, `CLOSING`, `ARCHIVED` |
| **`CLOSING`** | User requested closure; pending sweep/payout of residual funds. | No new deposits; outgoing limited to final settlement. | `CLOSED`, `ACTIVE` |
| **`CLOSED`** | Zero balance confirmed; address deregistered from routing. | All financial movements rejected. | `ARCHIVED`, `RECOVERY_PENDING` |
| **`ARCHIVED`** | Terminal soft tombstone state. Preserved for legal audit. | Zero financial capability. Permanent read-only archive. | None (Terminal) |
| **`COMPROMISED`** | Key leakage or security breach suspected. | Immediate halt; funds swept to cold rescue if authorized. | `RECOVERY_PENDING`, `FROZEN` |
| **`RECOVERY_PENDING`**| Identity re-verification and key rotation in progress. | In-transit re-issuance of credentials. | `ACTIVE`, `CLOSED` |

---

## 5. Zero Deletion Policy & Financial Immutability

### 5.1 The Principle of Zero Financial Deletion
Under no circumstances may a wallet, address, transaction link, or balance ledger record be subjected to SQL `DELETE`, `TRUNCATE`, or destructive `UPDATE` of financial values.

```sql
-- Database Guard Trigger: MariaDB / MySQL Trigger Example
DELIMITER $$

CREATE TRIGGER prevent_wallet_delete
BEFORE DELETE ON wallets
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'FATAL: Deletion of wallet records is strictly prohibited by eCardo Financial Invariants.';
END$$

CREATE TRIGGER prevent_address_delete
BEFORE DELETE ON wallet_addresses
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'FATAL: Deletion of wallet addresses is strictly prohibited by eCardo Financial Invariants.';
END$$

CREATE TRIGGER prevent_asset_delete
BEFORE DELETE ON wallet_assets
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'FATAL: Deletion of wallet asset records is strictly prohibited by eCardo Financial Invariants.';
END$$

DELIMITER ;
```

### 5.2 Soft Tombstoning Protocol
When a wallet reaches end-of-life:
1. `is_tombstoned` is flagged as `TRUE`.
2. `tombstoned_at` is stamped with the UTC timestamp.
3. `tombstone_reason` catalogs the formal rationale (e.g., `USER_VOLUNTARY_DEACTIVATION`, `FRAUD_TERMINATION`).
4. `lifecycle_state` transitions to `ARCHIVED`.
5. All linked addresses remain in `wallet_addresses` marked non-routable, preventing reuse by other users.
6. The entire financial ledger trail in `ecardoq192` and `walet-ecardo` remains fully queryable by compliance auditors.

### 5.3 Privacy Compliance vs. Financial Records (GDPR/AML Balance)
- **PII Storage:** Personal identifiable information (legal name, phone number, national identification, passport photos) resides exclusively in the customer profile service, completely external to the blockchain registry.
- **On-Chain Immutability:** Blockchain addresses and transaction hashes recorded on public or private chains are inherently indelible.
- **Right to Erasure Handling:** If a user exercises a Right to Be Forgotten, profile PII is scrubbed in customer databases, but financial ledger rows and wallet IDs remain preserved with pseudonymous references (`DELETED_USER_<UUID>`) as required by anti-money laundering (AML) 10-year retention laws.

---

## 6. Integration Contract (Laravel Backend & Flutter Client)

### 6.1 Eloquent Model Mapping (Laravel Backend)
```php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Wallet extends Model
{
    protected $table = 'wallets';
    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'id', 'owner_id', 'owner_type', 'custody_domain',
        'lifecycle_state', 'previous_state', 'state_reason',
        'security_tier', 'version', 'is_tombstoned'
    ];

    protected $casts = [
        'is_tombstoned' => 'boolean',
        'state_updated_at' => 'datetime',
        'tombstoned_at' => 'datetime',
        'version' => 'integer',
    ];

    public function addresses(): HasMany
    {
        return $this->hasMany(WalletAddress::class, 'wallet_id', 'id');
    }

    public function assets(): HasMany
    {
        return $this->hasMany(WalletAsset::class, 'wallet_id', 'id');
    }

    public function keyMetadata(): HasOne
    {
        return $this->hasOne(WalletKeyMetadata::class, 'wallet_id', 'id');
    }

    public function transitions(): HasMany
    {
        return $this->hasMany(WalletStateTransition::class, 'wallet_id', 'id')
            ->orderBy('transitioned_at', 'desc');
    }
}
```

### 6.2 Mobile App Serialization Guard (Flutter / GetX)
The Flutter client consumes sanitized projections:
- `key_ref`, `derivation_path`, and `private_key` fields are strictly omitted from API responses.
- Balances are received as string-encoded integer minor units alongside display decimals to eliminate floating-point truncation issues in Dart.
- The UI binds directly to `lifecycle_state` to disable transfer controls instantly when an account is `SUSPENDED` or `FROZEN`.
