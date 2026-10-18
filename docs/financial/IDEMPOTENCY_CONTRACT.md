# Canonical Financial Idempotency Contract

- **Document Identifier:** ECARDO-FIN-IDEM-001
- **Domain:** Financial Core, Payment Processing, Ledger Resilience
- **Status:** APPROVED & MANDATORY
- **Applies To:** `ecardo_userapp_v1` (Flutter Mobile & Web), `ecardo_web_dev` (Laravel Core Banking & API Gateway), Microservices & Worker Daemons
- **Version:** 1.0.0
- **Effective Date:** 2026-10-18
- **Classification:** Financial Architecture Standard (Zero Tolerance for Double Debits)

---

## 1. Executive Summary & Golden Principle

Financial operations in eCardo involve high-value mutations across user balances, currency conversions, external payment gateways, and virtual card issuers. In distributed financial networks, network partitions, transport timeouts, process crashes, and concurrent requests are inevitable normal operating conditions.

### The Golden Principle of Financial Mutation

```
Request Hash != Operation ID != Authorization Credential != Financial Ledger Commit
```

These four primitives serve fundamentally different functions in the architecture:

1. **`operation_id` (Intent ID):** The unique, immutable client-generated identifier representing a single, distinct business intent conceived by the user. It is minted before any network dispatch and remains stable throughout the entire lifecycle of the intent until a terminal state is reached.
2. **`payload_fingerprint`:** The deterministic cryptographic representation (canonical SHA-256) of the mutation payload. It serves as an anti-tampering and consistency validator to verify that a client is not reusing an `operation_id` with altered parameters (e.g., modified amount or different destination). It is never used as an operation identifier on its own.
3. **Authorization Credential:** Transient credentials (transaction passcodes, OTPs, biometric signatures, Bearer tokens) required to authorize execution. Authorization credentials do not define or alter the identity of the financial intent.
4. **Financial Ledger Commit:** The authoritative, atomic double-entry journal posting executed by the backend database within strict isolation boundaries (`DB::transaction()` with ascending row locking `ORDER BY id ASC`).

Under no circumstances may a transient network error, 5xx server response, or transport timeout cause the client to generate a new `operation_id` or discard an unconfirmed financial intent.

---

## 2. Stable `operation_id` Specification

### 2.1 Format & Generation Standard

All financial mutations initiated by client applications must carry a stable `operation_id` conforming to the following specification:

- **Standard:** RFC 4122 Version 4 UUID (Universally Unique Identifier).
- **Representation:** 36-character lowercase hexadecimal string with four hyphen delimiters:
  `^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`
- **Example:** `550e8400-e29b-41d4-a716-446655440000`
- **Entropy Source:** Cryptographically secure pseudorandom number generator (`Random.secure()` in Dart / `crypto.randomUUID()` in Web / OpenSSL `CSPRNG` in backend).
- **Prohibited Patterns:** Timestamp-only IDs, auto-incrementing integers, non-cryptographic random integers, or values derived exclusively from hashing user input.

### 2.2 Lifecycle & Scope of an Intent

```
[ User Initiates Action ]
          │
          ▼
[ Mint operation_id (UUID v4) ] ──► [ Persist Intent locally (Storage) ]
          │
          ▼
[ Quote / Review Step ] ──────────► [ Lock Exchange Rate & Fee Snapshot ]
          │
          ▼
[ First Network Dispatch ]
          │
   ┌──────┴──────────────────────────┐
   │                                 │
[ Succeeded (200/201) ]    [ Transport Timeout / 5xx ]
   │                                 │
   ▼                                 ▼
[ Purge local Intent ]     [ RETAIN operation_id ]
[ Emit Balance Event ]     [ Poll Status / Idempotent Retry ]
```

1. **Minting Phase:** The `operation_id` is created at the exact moment the user transitions to the review or confirmation step, or when a rate quote is locked. It must never be generated inside the low-level HTTP transport function immediately prior to sending bytes.
2. **Persistence Guarantee:** Before the first HTTP request leaves the device, the tuple `(operation_id, endpoint, payload, created_at, state)` must be recorded in local persistent storage (`SharedPreferences` / `FlutterSecureStorage` / SQLite).
3. **Immutability:** Once minted, the `operation_id` remains strictly immutable for that logical transaction. If the network drops, times out, returns HTTP 500/502/503/504, or the mobile OS terminates the application process, the same `operation_id` is reloaded upon resume.
4. **Terminal Retirement:** The `operation_id` is purged from local pending intent storage if and only if:
   - The backend returns a deterministic success response (`HTTP 200/201` with `status: completed` or `success: true`).
   - The backend returns a deterministic non-retryable rejection (`HTTP 422` validation failure, `HTTP 403` forbidden KYC tier).
   - An explicit reconciliation worker confirms the transaction was permanently cancelled or rolled back without ledger effect.

---

## 3. Payload Fingerprinting vs Intent ID

### 3.1 Purpose & Separation

A common architectural vulnerability in fintech systems is treating the request hash as the operation key. This causes severe failure modes:

- **Case A (Passcode injection modifies hash):** The user submits a transfer. The backend demands a transaction passcode (`PASSCODE_REQUIRED`). The mobile app prompts the user, injects `"passcode": "1234"` into the payload, and re-submits. If the operation key was the payload hash, the second request appears as an entirely new operation, breaking idempotency tracking.
- **Case B (Intentional duplicate submissions):** A user legitimately sends two consecutive $20 transfers to their utility account 30 seconds apart. Because the payloads are identical, a system relying solely on payload hashing would incorrectly swallow the second payment as a duplicate, leaving the user with an unpaid utility bill.

To eliminate both vulnerabilities, eCardo mandates strict separation:

| Dimension | `operation_id` (Intent ID) | `payload_fingerprint` |
|---|---|---|
| **Origin** | Client intent layer | Computed mathematically from payload |
| **Primary Role** | Tracks logical operation identity across retries | Verifies payload integrity and parameter consistency |
| **Collision Behavior** | Must be globally unique per intent | Same payload produces identical hash |
| **Passcode Handling** | Stable across passcode collection prompts | Authorization credentials excluded from core fingerprint |

### 3.2 Canonical JSON Hashing Algorithm (FIN-IDEM-04)

The backend and client compute the `payload_fingerprint` using deterministic canonical SHA-256:

1. **Key Sorting:** All JSON object keys at all nesting depths must be sorted lexicographically by Unicode codepoint order (`A-Z`, then `a-z`).
2. **Whitespace Stripping:** Minified JSON representation without insignificant whitespace outside quoted strings.
3. **Numeric Normalization:** Floating point numbers must not be formatted with arbitrary precision. Fixed precision strings (e.g. `"150.00000000"`) or integer minor units must be used.
4. **Transient Field Exclusion:** Ephemeral fields and sensitive credentials must be stripped prior to fingerprint calculation:
   - Excluded fields: `passcode`, `pin`, `password`, `otp`, `timestamp`, `client_trace_id`, `request_id`.
5. **Hash Generation:** Compute `SHA-256` of the UTF-8 encoded canonical JSON string and format as a 64-character lowercase hexadecimal string.

```dart
// Canonical Payload Fingerprint Reference Implementation
String computePayloadFingerprint(Map<String, dynamic> data) {
  final sanitized = Map<String, dynamic>.from(data);
  // Strip transient and authorization credentials
  sanitized.removeWhere((k, _) => [
    'passcode', 'pin', 'otp', 'password', 'request_id'
  ].contains(k.toLowerCase()));
  
  final canonical = _canonicalizeJson(sanitized);
  final jsonString = jsonEncode(canonical);
  return sha256.convert(utf8.encode(jsonString)).toString();
}

dynamic _canonicalizeJson(dynamic value) {
  if (value is Map) {
    final sortedEntries = value.entries.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
    final result = <String, dynamic>{};
    for (final entry in sortedEntries) {
      result[entry.key.toString()] = _canonicalizeJson(entry.value);
    }
    return result;
  } else if (value is List) {
    return value.map(_canonicalizeJson).toList();
  }
  return value;
}
```

### 3.3 Conflict Resolution Matrix

When the backend receives a request with an existing `operation_id`:

| Existing Key State | Incoming Fingerprint Match | Action Taken by Backend | HTTP Response |
|---|---|---|---|
| In-Flight (`PROCESSING`) | Matches | Request coalescing / wait for lock or return pending status | `409 Conflict` (`Retry-After: 2`) or `202 Accepted` |
| Succeeded (`COMPLETED`) | Matches | Return stored cached response payload directly from DB | `200 OK` (with `Idempotent-Replay: true`) |
| Succeeded (`COMPLETED`) | Does NOT Match | Reject! Intent tampering or key collision detected | `409 Conflict` (`code: IDEMPOTENCY_PAYLOAD_MISMATCH`) |
| Failed (`FAILED_FINAL`) | Matches | Return original terminal error response | Original error code (`422`, `400`) |
| Expired / Unknown | Any | Process as new or route to reconciliation | Dynamic based on ledger state |

---

## 4. Dual-Header Protocol: `Idempotency-Key` vs `X-Idempotency-Key`

### 4.1 Specification & Header Contract

To ensure 100% interoperability across standard web servers, reverse proxies (Nginx, Cloudflare), Laravel HTTP middleware, and API gateways, the client and server must adhere to the dual-header specification:

```http
POST /api/user/transfer HTTP/1.1
Host: api.ecardo.com
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
X-Request-ID: req-7d3e2a1b-9c4f-4a8d-b3e1-6f8a2c4e5d6a
X-Operation-ID: 550e8400-e29b-41d4-a716-446655440000
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
X-Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

- **`Idempotency-Key`:** The standard header conforming to the IETF draft specification (`draft-ietf-httpapi-idempotency-key-header`).
- **`X-Idempotency-Key`:** The legacy de-facto header utilized by third-party middlewares (`WendellAdriel/laravel-idempotency`, Stripe compatibility layers).
- **`X-Operation-ID`:** The domain-level intent identifier matching the exact UUID v4 of the financial operation.
- **`X-Request-ID`:** Cryptographically random identifier generated per physical network dispatch for distributed telemetry and tracing (unique per HTTP attempt).

### 4.2 Middleware Extraction Precedence

Backend middleware must resolve the client idempotency key using the following deterministic cascade:

```php
// Backend Header Resolution Order
$idempotencyKey = $request->header('Idempotency-Key')
    ?? $request->header('X-Idempotency-Key')
    ?? $request->header('X-Operation-ID');
```

If multiple headers are supplied with conflicting non-empty values, the backend must immediately abort with `HTTP 400 Bad Request` (`code: CONFLICTING_IDEMPOTENCY_HEADERS`).

---

## 5. Server Persistence & Deduplication Contract

### 5.1 Storage Architecture: Two-Tier Defense

Idempotency cannot rely solely on in-memory caches or Redis. If Redis restarts or evicts keys under memory pressure, duplicate financial execution must be prevented by the database.

```
Incoming Request
       │
       ▼
[ Tier 1: Redis Distributed Lock & Cache ]
       │ - Key: idempotency:user_{id}:{key}
       │ - Atomic SET NX EX 120s
       │
       ▼
[ Tier 2: PostgreSQL Idempotency Ledger Table ]
       │ - Table: `financial_idempotency_records`
       │ - UNIQUE INDEX on `(user_id, idempotency_key)`
       │ - Evaluated INSIDE DB::transaction()
```

### 5.2 Database Schema Specification

```sql
CREATE TABLE financial_idempotency_records (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    idempotency_key VARCHAR(64) NOT NULL,
    operation_id UUID NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    payload_fingerprint CHAR(64) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'PROCESSING',
    response_status_code SMALLINT NULL,
    response_headers JSONB NULL,
    response_body JSONB NULL,
    locked_until TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_idempotency_key UNIQUE (user_id, idempotency_key)
);

CREATE INDEX idx_idempotency_lookup 
ON financial_idempotency_records (user_id, idempotency_key, payload_fingerprint);

CREATE INDEX idx_idempotency_status_aging 
ON financial_idempotency_records (status, created_at);
```

### 5.3 Deduplication Execution Algorithm

```
Step 1: Check Redis cache. If key exists and status is COMPLETED, return cached response with `Idempotent-Replay: true`.
Step 2: If key is PROCESSING in Redis, return HTTP 409 Conflict (`code: OPERATION_IN_PROGRESS`, `Retry-After: 2`).
Step 3: Begin DB::transaction().
Step 4: Execute INSERT INTO financial_idempotency_records (...) ON CONFLICT DO NOTHING.
Step 5: If insertion affected 0 rows (row already exists in DB):
         - Query existing record FOR UPDATE.
         - If payload_fingerprint != incoming_fingerprint: Rollback & throw 409 IDEMPOTENCY_PAYLOAD_MISMATCH.
         - If status == 'COMPLETED': Rollback & return stored response.
         - If status == 'PROCESSING' and locked_until > NOW(): Rollback & throw 409 OPERATION_IN_PROGRESS.
         - If status == 'PROCESSING' and locked_until <= NOW(): Claim lock, extend lock_until by 60s, proceed to recovery.
Step 6: Execute business logic and double-entry ledger mutation.
Step 7: Update financial_idempotency_records set status = 'COMPLETED', response_body = ..., locked_until = NULL.
Step 8: Commit DB::transaction().
Step 9: Sync result to Redis with TTL = 24 hours.
Step 10: Return HTTP response to client.
```

---

## 6. Fault Injection Handling & Edge Cases

### 6.1 Matrix of Fault Conditions

| Fault Scenario | Physical Root Cause | Architectural State | Client Reaction Rule | Server Recovery Rule |
|---|---|---|---|---|
| **HTTP 500 / 502 / 503 / 504** | Server crashed after ledger commit during response serialization, or upstream gateway timeout. | **AMBIGUOUS** (Ledger may or may not be debited). | **NEVER** release key. **NEVER** generate new `operation_id`. Retain intent. Transition UI to "Pending Verification". Poll status inquiry endpoint. | Idempotency record holds status `PROCESSING` or `COMPLETED`. Reconciliation worker checks orphan status after SLA timeout. |
| **Connection Timeout** | TCP handshake dropped, mobile cell tower handover, client-side offline drop before sending. | **UNEXECUTED** (Usually). | Retain `operation_id`. Retry with exponential backoff and jitter (`base: 1s, max: 16s`). | Server receives first request later; normal idempotency filter handles deduplication. |
| **Receive Timeout** | Server accepted request, processed ledger, but connection dropped while sending response back. | **AMBIGUOUS / COMMITTED**. | **NEVER** re-submit with new key. Retain exact `operation_id`. Display warning toast advising user to verify history before re-dispatching. Auto-inquire status. | If retry arrives, server recognizes `operation_id` in DB, returns stored `COMPLETED` response without re-executing. |
| **Socket Drop / Broken Pipe** | OS socket termination, VPN disconnect, NAT traversal timeout. | **AMBIGUOUS**. | Catch `SocketException` in interceptor. Retain key in in-flight cache. Surface connectivity banner. | Handled via DB row locking or completed idempotency record. |
| **App Process Killed (OOM / Crash)** | Operating system terminated app while financial request was in flight. | **PERSISTED UNCONFIRMED**. | On next app launch, Intent Recovery Manager reads unconfirmed intents from local storage, calls `/user/transactions/status-inquiry?operation_id={uuid}`. | Responds with definitive state: `SUCCEEDED`, `FAILED`, or `NOT_FOUND`. |
| **Concurrent Double-Tap** | Rapid user double-tap on submit button before UI disabled state propagated. | **RACE CONDITION**. | NetworkService `_inflightIdempotency` coalesces request. Second dispatch attaches to existing in-flight future or shares key. | Redis `SET NX` or DB unique constraint drops second submission with `409 Conflict`. Zero duplicate debit. |
| **Stale Quote Expiry** | Exchange rate expired during network lag or user delay in review step. | **BUSINESS REJECTION**. | Server rejects with `HTTP 422 QUOTE_EXPIRED`. Client releases old `operation_id`, fetches fresh quote, requires user re-confirmation. | Server commits no ledger change; marks idempotency record as `FAILED_FINAL`. |

---

## 7. Audit of the 7 Financial Controllers in eCardo User App

An audit of the existing controllers in `ecardo_userapp_v1` reveals that while the network transport layer (`NetworkService`) contains robust low-level idempotency key synthesis, the presentation controllers operate with architectural vulnerabilities:

### 7.1 Detailed Controller Audit

#### 1. Exchange Controller (`exchange_controller.dart`)
- **Current Behavior:** Submits to `ApiPath.exchangeWalletEndpoint` (`/user/exchange`).
- **Gaps Identified:** Does not instantiate a stable `operation_id` at the amount/review step. On transport timeout, catches `isTimeout` and displays a warning toast, but does not persist the intent across app restarts. When `PASSCODE_REQUIRED` is handled, `exchangeWallet(passcode: verified)` is invoked with the passcode appended to the payload. Because no explicit `operation_id` is supplied, `NetworkService` computes the payload fingerprint including the passcode, risking key divergence if not sanitized.

#### 2. Transfer Controller (`transfer_controller.dart`)
- **Current Behavior:** Submits to `ApiPath.userTransferEndpoint` (`/user/transfer`).
- **Gaps Identified:** Lacks controller-level `operation_id` generation. If the application is killed while `transferAmount()` is in flight, the pending intent is lost from memory. Retries rely on in-memory `_inflightIdempotency` map which is lost upon process restart.

#### 3. Cash Out Controller (`cash_out_controller.dart`)
- **Current Behavior:** Submits to `ApiPath.userCashOutEndpoint` (`/user/cashout`).
- **Gaps Identified:** No pre-allocated `operation_id`. If an agent transaction times out, the user has no automated recovery mechanism other than manual history review.

#### 4. Withdraw Controller (`withdraw_controller.dart`)
- **Current Behavior:** Submits to `ApiPath.withdrawEndpoint` (`/user/withdraw`).
- **Gaps Identified:** Has in-flight double-tap guard (`isWithdrawLoading`), but does not bind a stable UUID v4 intent identifier. Banking withdrawals to external IBANs are high risk for duplicate clearing if retried blindly.

#### 5. Make Payment Controller (`make_payment_controller.dart`)
- **Current Behavior:** Submits to `ApiPath.makePaymentEndpoint` (`/user/make-payment`).
- **Gaps Identified:** Merchant payments lack persistent intent tracking. A network drop during checkout can cause merchant dispute if customer re-pays under a different transaction ID.

#### 6. Create Gift Controller (`create_gift_controller.dart`)
- **Current Behavior:** Submits to `ApiPath.giftCodeEndpoint` (`/user/gifts`).
- **Gaps Identified:** Minting digital gift codes involves irrevocable digital goods generation. Double submission can generate two gift codes and double debit the balance. Needs explicit intent ID.

#### 7. Virtual Card Controller (`create_virtual_card_controller.dart`)
- **Current Behavior:** Submits to `ApiPath.postCardOrdersEndpoint` (`/user/card-orders`).
- **Gaps Identified:** Involves multi-step orchestration (wallet reservation, gateway redirect, external issuer provisioning). If the card issuer API times out, the controller polls `_fetchCardOrder`, but does not supply a stable client-side `operation_id` to prevent the backend from dispatching a duplicate card creation saga to Stripe/BSI Cards.

---

## 8. Migration Blueprint: Standardized Controller Implementation

To achieve full compliance with this contract, all seven financial controllers must adopt the canonical `FinancialIntentManager` pattern:

```dart
// Canonical Controller Pattern Blueprint
class CanonicalFinancialSubmissionPattern {
  String? _currentOperationId;

  void prepareIntent() {
    // 1. Mint stable UUID v4 when entering review/quote step
    _currentOperationId = const Uuid().v4();
  }

  Future<void> submitFinancialMutation({String? passcode}) async {
    if (_currentOperationId == null) {
      prepareIntent();
    }
    
    final operationId = _currentOperationId!;
    
    final Map<String, dynamic> requestPayload = {
      'amount': amountController.text.trim(),
      'destination': recipientController.text.trim(),
      if (passcode != null && passcode.isNotEmpty) 'passcode': passcode,
    };

    try {
      // 2. Pass explicit operationId to NetworkService
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.userTransferEndpoint,
        data: requestPayload,
        operationId: operationId, // Injects X-Operation-ID and Idempotency-Key
      );

      if (response.status == Status.completed) {
        // 3. Terminal Success: purge intent, navigate to success
        _currentOperationId = null;
        transitionToSuccess(response.data);
      } else if (response.status == Status.error) {
        if (PasscodeHelper.isPasscodeRequired(response.message)) {
          // 4. Prompt passcode: DO NOT RESET operationId
          final pin = await promptPasscodeBottomSheet();
          if (pin != null) {
            await submitFinancialMutation(passcode: pin); // Re-uses identical operationId
          }
        } else {
          // Deterministic error: purge intent
          _currentOperationId = null;
          handleBusinessError(response.message);
        }
      }
    } catch (e) {
      // 5. Ambiguous transport failure / timeout:
      // RETAIN _currentOperationId for status inquiry or user-prompted retry
      handleAmbiguousTimeout(operationId, e);
    }
  }
}
```

---

## 9. Verification & Acceptance Criteria

A flow is considered compliant with `ECARDO-FIN-IDEM-001` only when passing all the following verification criteria:

1. **Zero Duplicate Balance Debits:** Under automated fault injection with synthetic network drops, 500ms jitter, HTTP 500 injection, and sudden app process termination, balance invariants never decrease more than once for a single intent.
2. **Dual-Header Verification:** CI contract tests verify that every money-moving HTTP POST carries identical values in `Idempotency-Key` and `X-Idempotency-Key`.
3. **Passcode Retry Key Invariance:** When a mutation triggers `PASSCODE_REQUIRED`, the subsequent request carrying the verified passcode sends the exact same `operation_id` as the initial attempt.
4. **Payload Tampering Detection:** Attempting to submit the same `operation_id` with an altered amount or recipient produces HTTP 409 Conflict with `code: IDEMPOTENCY_PAYLOAD_MISMATCH`.
5. **Recovery Across App Restart:** Re-opening the app after an interrupted transaction detects the unconfirmed intent and initiates status reconciliation before unlocking user funds.
