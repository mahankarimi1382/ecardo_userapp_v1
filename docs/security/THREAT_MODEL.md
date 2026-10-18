# eCardo Mobile Client Threat Model

**Document Version:** 1.0.0  
**Effective Date:** 2026-10-18  
**Applicability:** eCardo Mobile Client (`ecardo_userapp_v1` - Flutter / Dart)  
**Security Classification:** Restricted / Internal Fintech Security Standard  
**Compliance Standards:** OWASP MASVS v2.0 / MASTG, PCI-DSS v4.0.1, Central Bank Fintech Guidelines  

---

## 1. Executive Summary & Fintech Scope

eCardo is a next-generation multi-currency fintech super-application providing personal and commercial financial services, including:
- Multi-currency digital wallets (IRR, USD, EUR, AED, TRY, etc.)
- Peer-to-peer (P2P) transfers, instant remittances, and bill payments
- Virtual card issuance, funding, top-up, and management
- Escrow transactions, consumer loans, and collateral guarantees
- Foreign exchange (FX) order booking and real-time rate tracking
- Travel and lifestyle booking services (flights, hotels, e-SIM, car rentals, visas)

Due to the critical financial nature of these operations, the mobile client runs in a zero-trust model relative to its execution host. The device operating system, local network, runtime memory, and physical storage are treated as potentially hostile or untrusted environments.

This Threat Model defines:
1. Architectural assets and trust boundaries across client, storage, transport, and gateway layers.
2. Threat actors and attack vectors specific to mobile fintech operations.
3. Security architecture and attack surface analysis of the offline request queue (`OfflineRequestQueue`) and dead-letter queue (DLQ).
4. Non-replayability guarantees for financial mutations.
5. Client-side data classification and privacy/PII protection policies.
6. Alignment with the OWASP Mobile Application Security Verification Standard (MASVS v2.0).

---

## 2. System Architecture & Component Inventory

```
+---------------------------------------------------------------------------------------------------------+
|                                        MOBILE CLIENT RUNTIME (Flutter)                                  |
|                                                                                                         |
|  +---------------------------------------------------------------------------------------------------+  |
|  |                                      Presentation Layer                                           |  |
|  |     GetX Controllers (Wallet, Transfer, Cards, Escrow, FX, Travel) | UI Screens & Widgets         |  |
|  +---------------------------------------------------------------------------------------------------+  |
|                                                  |                                                      |
|                                                  v                                                      |
|  +---------------------------------------------------------------------------------------------------+  |
|  |                                   Client Security & Core Services                                 |  |
|  |   - TokenService (Keystore/Keychain)              - SessionManager (Single-flight auth/logout)    |  |
|  |   - AppLockService (Passcode/Biometrics)          - KycErrorHandler (Level/Feature gates)         |  |
|  |   - OfflineRequestQueue (Allowlist non-financial) - DemoAccountService (kDebugMode gated mock)   |  |
|  +---------------------------------------------------------------------------------------------------+  |
|                                                  |                                                      |
|                                                  v                                                      |
|  +---------------------------------------------------------------------------------------------------+  |
|  |                                      Network & Transport Layer                                    |  |
|  |   - NetworkService (Dio Client & Global Client)                                                   |  |
|  |   - SslPinningConfig (Leaf Cert DER SHA-256 Pinning, Fail-Closed)                                 |  |
|  |   - Idempotency Engine (Idempotency-Key, X-Idempotency-Key, X-Operation-ID, 5-min TTL)           |  |
|  |   - Sanitize Interceptor & Producer-side Redactor (_sanitizePayload, _log)                        |  |
|  +---------------------------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------------------------+
       |                                           |                                      |
       | (Hardware Storage Boundary)               | (TLS 1.3 / Pinned)                  | (Unencrypted)
       v                                           v                                      v
+-------------------------------+      +-------------------------+      +---------------------------------+
|   SECURE HARDWARE STORAGE     |      |       API GATEWAY       |      |     DEVICE SHARED PREFERENCES   |
| - Android Keystore / Encrypted|      | - Cloudflare / Nginx    |      | - Non-sensitive app settings    |
|   SharedPreferences           |      | - Rate Limiting & WAF   |      | - Route / UI state cache        |
| - iOS Keychain (AfterFirst    |      | - Idempotency Validator |      | - Offline Queue (ALLOWLIST ONLY)|
|   UnlockThisDeviceOnly)       |      | - Auth Verification     |      |   (Strictly Zero Secrets/Tokens)|
+-------------------------------+      +-------------------------+      +---------------------------------+
```

---

## 3. Trust Boundaries & Security Zones

The eCardo application architecture enforces strict physical and logical boundaries between untrusted environments and secured enclaves:

```
+-----------------------------------------------------------------------------------------------+
| TB-01: Host OS Runtime Boundary (Untrusted Device vs. Flutter Dart VM)                        |
+-----------------------------------------------------------------------------------------------+
| TB-02: Ephemeral In-Memory Execution Boundary (Dart Heap, Clean Lifecycle, Garbage Collection)|
+-----------------------------------------------------------------------------------------------+
| TB-03: Storage Boundary (Hardware-Backed Keystore/Keychain vs. Public Sandbox SharedPreferences)|
+-----------------------------------------------------------------------------------------------+
| TB-04: Transport Boundary (Local Device Radio vs. Pinned Edge TLS Termination)                |
+-----------------------------------------------------------------------------------------------+
| TB-05: API Gateway Boundary (Edge Reverse Proxy / WAF vs. Internal Microservices)              |
+-----------------------------------------------------------------------------------------------+
| TB-06: Core Ledger & Financial Database Boundary (Idempotency Engine, Double-Entry Ledger)    |
+-----------------------------------------------------------------------------------------------+
```

### TB-01: Host OS Runtime Boundary
- **Description:** The boundary separating the operating system (Android/iOS), userland processes, and external applications from the eCardo process space.
- **Threat Profile:** Rooted/jailbroken operating systems, Frida/Xposed dynamic instrumentation hooks, malicious accessibility services, debuggers, screen recorders, and clipboard sniffers.
- **Enforced Controls:**
  - Code obfuscation via release builds (`--obfuscate --split-debug-info`).
  - Strict prohibition of secrets in the client codebase or APK asset bundles.
  - Compile-time isolation of demo mock routines (`kDebugMode` constants ensuring zero mock code execution in release builds).
  - Explicit platform isolation for Android Keystore and iOS Keychain.

### TB-02: Ephemeral In-Memory Execution Boundary
- **Description:** The transient Dart VM heap and runtime memory containing session variables, state controllers, and intermediate encryption objects.
- **Threat Profile:** Cold-boot memory attacks, memory dumps via OS crashes, debuggers attaching to processes, and heap inspection.
- **Enforced Controls:**
  - Passwords and passcodes are never retained in permanent state variables; they are collected via transient UI controllers and discarded immediately after use.
  - Tokens and sensitive auth objects are encapsulated inside `TokenService` with private fields.
  - Zero logging of bearer tokens: raw tokens are redacted upon emission (`_log('🔑 Token: <redacted N chars>')`).

### TB-03: Hardware-Backed Secure Storage Boundary
- **Description:** Separation between unencrypted file storage (`SharedPreferences`) and hardware-isolated cryptographic key storage.
- **Threat Profile:** Unauthorized file extraction via ADB backup, device physical theft, malicious apps reading external storage, or sandbox bypass vulnerabilities.
- **Enforced Controls:**
  - Access and refresh tokens are stored exclusively in `FlutterSecureStorage` using `AndroidOptions(encryptedSharedPreferences: true)` backed by Android Keystore, and `IOSOptions(accessibility: KeychainAccessibility.first_unlock)`.
  - Automatic legacy migration: on startup, any plaintext token found in legacy `SharedPreferences` is imported to secure storage and deleted from disk immediately.
  - Zero credentials or tokens are allowed in `SharedPreferences`.

### TB-04: Transport Boundary (TLS & Certificate Pinning)
- **Description:** The network channel traversing cellular towers, public Wi-Fi hotspots, ISPs, and international transit backbones to eCardo edge servers.
- **Threat Profile:** Man-in-the-Middle (MITM) proxies, rogue root certificates installed on user devices, DNS spoofing, BGP hijacking, and SSL stripping.
- **Enforced Controls:**
  - Strict leaf certificate DER SHA-256 fingerprint verification (`SslPinningConfig`).
  - Gated domains: `ecardo.ir` and `trip.ecardo.ir`.
  - Fail-closed invariant: if certificate fingerprints do not match or are absent, connections abort immediately.
  - The insecure `badCertificateCallback` is completely disabled in production code (`Dio.validateCertificate` runs only on certificates already trusted by the platform root store).

### TB-05: API Gateway & Service Boundary
- **Description:** The perimeter separating public internet requests from the eCardo backend server infrastructure.
- **Threat Profile:** Credential stuffing, denial-of-service floods, parameter tampering, and replay attacks.
- **Enforced Controls:**
  - Every mutating financial request requires a cryptographically random, client-minted `Idempotency-Key` and `X-Idempotency-Key`.
  - Distributed rate limiting and WAF rules.
  - Stateless JWT authentication validated on every protected endpoint.

### TB-06: Core Banking & Ledger Boundary
- **Description:** The authoritative backend system executing database state transitions and ledger postings.
- **Threat Profile:** Double spending, concurrent debit race conditions, quote expiration bypass.
- **Enforced Controls:**
  - Double-entry bookkeeping with strict database ACID transactions.
  - Atomic verification of idempotency keys in server-side storage.
  - Client state is treated as purely advisory; the backend server is the sole source of truth for balances and permissions.

---

## 4. Threat Actors & Adversary Models

| Adversary | Motivation | Capabilities & Tools | Attack Vectors |
| :--- | :--- | :--- | :--- |
| **Malicious Device Owner** | Financial fraud, double spending, fee evasion | Root/Jailbreak, Frida, Cycript, Proxy tools (Burp, Mitmproxy), local file modification | Manipulating offline queue payloads, modifying local balance cache, replaying payment submissions. |
| **Network Eavesdropper / Rogue AP** | Credential theft, session hijacking, transaction manipulation | Wi-Fi rogue access points, ARP poisoning, forged CA certificates | MITM interception, SSL stripping, DNS poisoning, traffic analysis. |
| **Malicious Co-located App / Spyware** | PII harvesting, account takeover | Android Accessibility Service abuse, clipboard monitoring, screen recording, backup extraction | Stealing OTP from clipboard, reading plaintext tokens from shared files, overlay attacks. |
| **Reverse Engineer / Hostile Competitor** | IP theft, finding API zero-days, backend enumeration | Ghidra, jadx, APKTool, IDA Pro, Frida, Dart DDC/AOT decompilation | Decompiling application bundle, extracting hidden endpoints, analyzing crypto routines. |
| **Compromised Upstream Provider** | Unauthorized data harvesting, upstream outage fraud | Control over third-party API responses, webhooks, or SDKs | Injecting malformed response structures, replaying duplicate webhooks, leaking transaction metadata. |

---

## 5. Offline Request Queue & DLQ Security Architecture

The offline request queue (`OfflineRequestQueue` in `lib/src/common/services/offline_request_queue.dart`) is a high-risk architectural component. If not restricted, an offline queue in a fintech app can become an attack vector for unauthorized transaction replays, double-spending, and persistent credential leakage.

### 5.1 The Zero-Financial-Mutation Invariant
```
+-------------------------------------------------------------------------------------------------+
|                                 CORE FINANCIAL INVARIANT (SEC-OFF-01)                           |
+-------------------------------------------------------------------------------------------------+
| Under NO circumstances shall any financial mutation, money movement, balance alteration,       |
| card operation, wallet transfer, loan commitment, or credential update be queued offline.       |
| ALL financial mutations must execute ONLINE with direct end-to-end confirmation.                 |
+-------------------------------------------------------------------------------------------------+
```

### 5.2 Strict Route & HTTP Method Allowlist
Only non-financial, non-sensitive operational requests are eligible for offline queuing. Any endpoint not explicitly matched on the allowlist is rejected immediately:

| Normalized Endpoint | Allowed HTTP Methods | Business Justification | Data Sensitivity |
| :--- | :--- | :--- | :--- |
| `/setup-fcm` | `POST` only | Registering push notification device token | Low (FCM token only; sensitive tokens excluded) |
| `/mark-as-read-notification` | `POST` only | Acknowledging notification read status | Low (Notification ID) |
| `/user/settings/profile` | `POST`, `PUT` only | User profile preferences (theme, name) | Medium (Strictly scanned for sensitive tokens) |
| `/change-language/{code}` | `GET`, `POST` only | Interface language selection | Public (Language code) |

Any request to endpoints such as `/user/transfer`, `/user/withdraw`, `/user/pay-bill`, `/user/exchange`, or `/user/virtual-card/*` returns `false` from `isRouteAllowed()` and is dropped.

### 5.3 Path Traversal & Protocol Injection Defense
`OfflineRequestQueue.normalizePath()` enforces strict URI sanitization before evaluation:
- Absolute URLs (`http://`, `https://`, `ftp://`) are rejected.
- Scheme-relative (`//`) and UNC paths (`\\`) are rejected.
- Path traversal sequences (`..` or `.`) anywhere in path segments are rejected.
- Query parameters (`?`) and URL fragments (`#`) are rejected.
- Paths are normalized to start with a single `/` and stripped of trailing slashes.

### 5.4 Recursive Deep Payload Sensitive Data Scanner
Before any payload is accepted into the offline queue, `containsSensitiveData()` performs a recursive depth-first traversal of all Map keys, Map string values, and List items.

The scanner flags and rejects any payload containing terms from `sensitiveTokens`:
```
password, passcode, pin, otp, token, secret, card, cvv, pan, national_id, kyc, amount, transfer, withdraw, wallet
```

**Scanner Defense Rules:**
1. **Word Boundary & CamelCase Extraction:** Token names like `cardNumber`, `card_pan`, `userPinCode`, or `transferAmount` are split into constituent words and matched.
2. **Specialized Handling:**
   - `national_id`: Matches `national_id`, `national-id`, `nationalid`, or any token sequence with both "national" and "id".
   - `pin`: Matches `pin`, `pins`, `pin_code`, `pincode`.
   - `pan`: Matches `pan`, `pans`, `card_pan`, `cardpan`, `pan_number`.
   - `card`: Matches `card`, `cards`, while whitelisting safe terms (`ecardo`, `wildcard`, `discard`).
   - `token`: Matches authentication tokens, while whitelisting `fcm_token` strictly on the `/setup-fcm` endpoint.

### 5.5 Queue Governance, Storage & DoS Mitigation
- **Storage Location:** `ecardo_offline_queue_v1` in `SharedPreferences`. Because of the deep scanner, the stored data is strictly free of credentials, tokens, or financial records.
- **Capacity Cap (FIFO):** Queue size is strictly capped at `maxQueueSize = 25` items. When the cap is reached, the oldest items are evicted first, preventing disk exhaustion attacks.
- **Time-to-Live (TTL):** Every item carries a `created_at` timestamp. Items older than `ttl = Duration(hours: 24)` are automatically evicted upon queue load or flush.

### 5.6 Dead-Letter Queue (DLQ) Architecture & Redaction
- When an enqueued item fails after `maxRetries = 3` retry attempts, it is moved to the Dead-Letter Queue stored in `ecardo_offline_queue_dlq_v1`.
- Every DLQ entry records: `id`, `method`, `endpoint`, `data`, `retries`, `created_at`, and `dead_letter_at`.
- DLQ entries maintain the exact same zero-secret invariant as the main queue. No payload entering the DLQ can ever contain unredacted secrets or credentials.

---

## 6. Non-Replayable Financial Actions & Idempotency Guarantees

Accidental double submissions (e.g., user double-tapping a "Transfer" button, transient mobile connection drops during HTTP receive phase) represent a critical financial hazard.

### 6.1 Idempotency Key Architecture in `NetworkService`
Every money-moving mutating request (`POST`) automatically generates and attaches unique, cryptographically random idempotency headers:
1. `Idempotency-Key: req-<random_base64url>`
2. `X-Idempotency-Key: req-<random_base64url>` (for 100% gateway compatibility)
3. `X-Operation-ID: <op_id>` (when explicitly supplied by domain workflows)

### 6.2 Idempotency Lifecycle & State Machine
The client maintains an in-flight idempotency registry (`_inflightIdempotency`) with a 5-minute TTL:

```
+---------------------------------------------------------------------------------------------------+
|                                  IDEMPOTENCY STATE MACHINE                                        |
+---------------------------------------------------------------------------------------------------+
|  [Initiate POST]                                                                                  |
|         |                                                                                         |
|         v                                                                                         |
|  Calculate Map Key: METHOD:NORMALIZED_PATH:IDENTITY                                               |
|  (Identity = explicit op_id OR canonical recursive SHA-256 fingerprint of payload)                |
|         |                                                                                         |
|         +---> If key exists & < 5 min old: REUSE existing Idempotency-Key (Retry Protection)      |
|         +---> If key absent / expired: MINT fresh unguessable Idempotency-Key                     |
|         |                                                                                         |
|  [Send Request via Dio]                                                                           |
|         |                                                                                         |
|         +---> Success (HTTP 200..299): RELEASE key immediately (next call is a fresh intent)     |
|         +---> Client Error (HTTP 400..499): RELEASE key immediately (deterministic rejection)     |
|         +---> Server Error (HTTP 500..599): RETAIN key in registry (ambiguous state; may commit) |
|         +---> Transport Timeout / SocketException: RETAIN key up to 5 min TTL for safe retry      |
+---------------------------------------------------------------------------------------------------+
```

### 6.3 Monitored Financial Endpoints
All financial operations enforce this idempotency contract:
- `/user/pay-bill`
- `/user/transfer`
- `/user/cashout`
- `/user/gifts`
- `/user/withdraw`
- `/user/exchange`
- `/user/remittance/store`
- `/user/loans/apply`, `/user/loans/repay`, `/user/loans/early-repayment`
- `/user/escrow/store`, `/user/escrow/pay`, `/user/escrow/release`
- `/user/stocks/order`
- `/user/guarantee/apply`, `/user/guarantee/deposit-margin`
- `/user/virtual-card/create`, `/user/virtual-card/fund`, `/user/virtual-card/topup`, `/user/virtual-card/balance-topup`
- `/user/p2p/create-order`, `/user/p2p/release-order`, `/user/p2p/pay-order`
- `/user/travel/book`, `/user/travel/order`
- `/user/visa/requests`
- `/user/card-orders`
- `/user/add-money`
- `/user/rentals/book`, `/user/tours/book`, `/user/licenses/order`

---

## 7. Mobile Client Threat Matrix (STRIDE & MASVS Alignment)

| STRIDE Category | Threat Description | Attack Vector | MASVS Ref | Mitigating Control in eCardo | Residual Risk |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Spoofing** | Impersonation of user via stolen Bearer JWT | Extraction from device backup or malicious application | MASVS-STORAGE-1 | `TokenService` stores tokens in Android Keystore / iOS Keychain. Never stored in `SharedPreferences`. | Low (Requires root/jailbreak with OS kernel exploit) |
| **Spoofing** | Rogue API Server impersonating `ecardo.ir` | MITM proxy with user-installed root CA | MASVS-NETWORK-1 | `SslPinningConfig` enforces leaf certificate DER SHA-256 fingerprint verification; fail-closed. | Very Low |
| **Tampering** | Balance or transaction payload tampering in memory | Frida hooking `NetworkService` methods or GetX controllers | MASVS-CODE-2 | Server-side validation of all transactions; client balance is display-only; release obfuscation. | Low (Backend strictly rejects invalid states) |
| **Tampering** | Offline queue injection of unauthorized requests | Modifying `ecardo_offline_queue_v1` in XML preferences | MASVS-STORAGE-2 | Strict route allowlist (`isRouteAllowed`) and deep recursive payload scanner re-validate on load and flush. | Negligible |
| **Repudiation** | User denies authorizing a financial transaction | Contesting duplicate submission or unverified action | MASVS-AUTH-1 | Unique `Idempotency-Key`, `X-Operation-ID`, server audit logs, and mandatory 2FA / Passcode step-up. | Very Low |
| **Information Disclosure** | Credentials leaked into application logcat / console | Plaintext logging of passwords, tokens, or card numbers | MASVS-STORAGE-3 | `NetworkService._sanitizePayload` and `_log` redact all sensitive fields; `kDebugMode` gating. | Very Low |
| **Information Disclosure** | Token exposure during token refresh race condition | Concurrent requests logging intermediate refresh tokens | MASVS-AUTH-2 | Single-flight refresh mutex (`_isRefreshing`); tokens printed only as `<redacted N chars>`. | Negligible |
| **Denial of Service** | Offline queue flooding to exhaust device disk space | Rapidly enqueueing requests while offline | MASVS-PLATFORM-1| Strict queue cap (`maxQueueSize = 25`) with FIFO eviction; 24-hour TTL expiration. | Negligible |
| **Elevation of Privilege** | Bypassing KYC verification tier requirements | Invoking restricted feature APIs directly | MASVS-AUTH-3 | Unified `KycErrorHandler` parsing 403 `KYC_LEVEL_REQUIRED`; backend authorization enforcement. | Negligible (Enforced server-side) |

---

## 8. Data Classification & Client Protection Policy

| Data Class | Data Elements | Local Storage Policy | In-Transit Protection | Logging / Telemetry Rule |
| :--- | :--- | :--- | :--- | :--- |
| **Restricted (Class 4 - Critical Secrets)** | Passwords, Passcodes, Wallet PINs, CVV/CVV2, OTP codes, Private keys | **STRICTLY PROHIBITED ON DISK.** Transient memory only, cleared immediately. | TLS 1.3 / Pinned Leaf Certificate | **STRICT ZERO-LEAKAGE:** Masked as `<redacted>` or `<redacted_*>` at producer. |
| **Restricted (Class 4 - Auth Tokens)** | OAuth/JWT Access Tokens, Refresh Tokens, Session Cookies | **Secure Storage Only:** Android Keystore / iOS Keychain. Prohibited in SharedPreferences. | TLS 1.3 / Pinned Leaf Certificate | Never logged raw. Logged only as `<none>` or `<redacted N chars>`. |
| **Confidential (Class 3 - CHD & Sensitive PII)** | Full Card PAN, Iranian National ID, Passport Number, IBAN / Sheba, Bank Account Numbers | Prohibited in plain storage. Cached only temporarily in memory when user is viewing. | TLS 1.3 / Pinned Leaf Certificate | Masked at producer (`<redacted>` or first 6 / last 4 digits for PAN if explicitly permitted). |
| **Internal (Class 2 - Financial & Account Data)** | Transaction History, Account Balances, User Full Name, Phone Number, Email, Currency Codes | Ephemeral state memory; non-sensitive UI settings in SharedPreferences. | TLS 1.3 / Pinned Leaf Certificate | Whitelisted operational fields logged only in debug builds; PII masked in release telemetry. |
| **Public (Class 1 - Public Assets)** | App Version, Static Exchange Rates, Help Articles, Language Locale Codes | Local SharedPreferences cache allowed. | Standard HTTPS / CDN | Allowed in logs and analytics streams. |

---

## 9. Security Verification & Release Exit Criteria

Prior to signing and distributing any mobile release build, the following verification gates must pass:
1. **Automated Redaction & Idempotency Unit Tests:** 100% pass rate in `test/workstream_b_idempotency_logging_test.dart` and `test/offline_request_queue_test.dart`.
2. **Static Application Security Testing (SAST):** MobSF scan on the signed release APK/AAB with zero high/critical vulnerabilities.
3. **Secret Scan:** Automated regex scanning across all assets, dart files, and configurations confirming zero hardcoded API keys or provider secrets.
4. **Certificate Pinning Validation:** Verification that `SslPinningConfig.validateCertificate` fails closed when an untrusted certificate or invalid host is provided.
5. **Debug Gate Verification:** Verification that `DemoAccountService.isDemoInterceptionAllowedNow` evaluates to `false` in release and profile modes.
