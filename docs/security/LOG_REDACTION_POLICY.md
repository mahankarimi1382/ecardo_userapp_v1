# eCardo Log Redaction & Data Sanitization Policy

**Document Version:** 1.0.0  
**Effective Date:** 2026-10-18  
**Applicability:** Mobile Application (`ecardo_userapp_v1`), Telemetry Pipelines, Logging & Crash Reporting  
**Security Classification:** Restricted / Internal Security & Compliance Standard  
**Regulatory Standards:** PCI-DSS v4.0.1 (Req 3.3, 3.4), OWASP MASVS-STORAGE / MASVS-NETWORK  

---

## 1. Policy Charter & Zero-Leakage Invariant

### 1.1 Purpose
This policy establishes mandatory data sanitization, masking, and redaction controls across the eCardo client application and network services. Its primary objective is to guarantee that no authentication credentials, payment cardholder data (CHD), one-time passwords (OTP), personal identification numbers (PIN), or sensitive personally identifiable information (PII) are ever emitted to:
- Mobile operating system logs (`logcat` on Android, `NSLog`/`os_log` on iOS)
- Developer console outputs (`debugPrint`, `print`)
- Crash report breadcrumbs and stack traces (Crashlytics, Sentry, or OTel)
- Analytics or performance telemetry payloads
- Unencrypted local storage or offline queues

### 1.2 Zero-Leakage Mandate
```
+-------------------------------------------------------------------------------------------------+
|                                 ZERO-LEAKAGE COMPLIANCE INVARIANT                               |
+-------------------------------------------------------------------------------------------------+
| 1. Producer-Side Redaction: All sensitive data MUST be intercepted and transformed into         |
|    `<redacted>` or `<redacted_*>` masks AT THE SOURCE before logging or queueing occurs.        |
| 2. Zero-Tolerance Assertion: The presence of even a SINGLE unredacted secret, PAN, PIN, OTP,   |
|    or credential in logs, debug outputs, or offline persistence is a P0 release-blocking bug.   |
| 3. Debug Gating: Detailed request/response logging must be strictly gated by `kDebugMode`.     |
|    In profile and release builds, operational logging is minimized and strictly sanitized.      |
+-------------------------------------------------------------------------------------------------+
```

---

## 2. Redaction Denylist: Comprehensive Field & Token Inventory

The client application enforces redaction across all request bodies, headers, error objects, and offline queues. Field matching is **case-insensitive** and accounts for **snake_case**, **camelCase**, **kebab-case**, and concatenated variations.

### 2.1 Passwords & Master Credentials
Any field representing a primary user secret, password, or confirmation:
- `password`
- `current_password`, `currentPassword`, `current-password`
- `new_password`, `newPassword`, `new-password`
- `password_confirmation`, `passwordConfirmation`, `password-confirmation`
- `pass`, `passwd`, `user_password`, `old_password`
- **Mask Replacement:** `<redacted>` or `<redacted_password>`

### 2.2 PINs & Passcodes
Numeric security codes used for transaction authorization, wallet unlocking, or device security:
- `pin`, `pins`, `pin_code`, `pincode`, `pinCode`
- `passcode`, `passcodes`, `pass_code`, `passCode`
- `wallet_passcode`, `walletPasscode`
- `security_pin`, `securityPin`
- `atm_pin`, `card_pin`
- **Mask Replacement:** `<redacted>` or `<redacted_pin>`

### 2.3 Payment Cardholder Data (CHD) & Sensitive Authentication Data (SAD)
Full Primary Account Numbers (PAN), verification codes, and expiration metadata governed by PCI-DSS:
- `pan`, `card_pan`, `cardpan`, `pan_number`
- `card_number`, `cardNumber`, `card-number`
- `cvv`, `cvv2`, `cvc`, `cvc2`, `cid`, `security_code`
- `exp_date`, `expiry_date`, `expiration_date`, `exp_month`, `exp_year`
- `track_data`, `track1`, `track2`, `magnetic_stripe`
- **Mask Replacement:** `<redacted>` or `<redacted_pan>`, `<redacted_cvv>`  
*(Note: In UI screens where card display is legally permissible, only masked PANs showing the first 6 and last 4 digits, e.g., `5022 29** **** 1234`, may be presented).*

### 2.4 One-Time Passwords (OTP) & Verification Codes
Transient multi-factor authentication codes transmitted via SMS, email, or authenticator apps:
- `otp`, `otps`, `otp_code`, `otpCode`
- `code`, `verification_code`, `verificationCode`, `sms_code`, `smsCode`
- `login_code`, `auth_code`, `email_otp`, `two_factor_code`
- **Mask Replacement:** `<redacted>` or `<redacted_otp>`

### 2.5 Authentication Tokens & Cryptographic Secrets
Bearer tokens, refresh tokens, session keys, and provider secrets:
- `access_token`, `accessToken`, `access-token`
- `refresh_token`, `refreshToken`, `refresh-token`
- `token`, `tokens` *(except `fcm_token` when specifically handling push registration)*
- `bearer`, `authorization`, `auth_header`
- `secret`, `client_secret`, `clientSecret`, `api_secret`
- `private_key`, `privateKey`, `certificate_key`
- `session_id`, `sessionId`, `cookie`
- **Mask Replacement:** `<redacted>` or `Bearer <redacted_jwt>`

### 2.6 National Identifiers & Banking Coordinates (PII)
Government identification numbers and banking coordinates:
- `national_id`, `nationalId`, `national-id`, `nationalid`
- `passport_number`, `passportNumber`, `ssn`, `tax_id`
- `iban`, `sheba`, `sheba_number`, `account_number`, `accountNumber`, `account-number`
- `identity_document`, `kyc_document_data`
- **Mask Replacement:** `<redacted>` or `<redacted_iban>`, `<redacted_id>`

### 2.7 Offline Request Queue Prohibited Terms
In addition to the above, `OfflineRequestQueue` rejects any payload containing financial mutation concepts:
- `amount`, `transfer`, `withdraw`, `wallet`, `kyc`, `card`
- **Action:** Request is completely blocked from the queue; returns `false` from `enqueue()`.

---

## 3. Allowed Telemetry Fields (Operational Allowlist)

The following metadata fields are safe for operational diagnostics, performance tracking, and debugging, provided they contain no embedded credentials:

| Field Name | Type | Purpose / Description | Example Value |
| :--- | :--- | :--- | :--- |
| `request_id` / `X-Request-ID` | String | Cryptographically random end-to-end tracing ID | `req-k8v2m9x4b1` |
| `app_version` / `X-App-Version` | String | Shipped application version resolved from pubspec | `1.0.41` |
| `platform` / `X-Platform` | String | Operating system platform | `android`, `ios`, `web` |
| `endpoint` / `path` | String | Normalized API path (stripped of query credentials) | `/user/settings/profile` |
| `method` | String | HTTP method | `POST`, `GET`, `PUT` |
| `status_code` | Integer | HTTP response status code | `200`, `401`, `422`, `500` |
| `elapsed_ms` | Integer | Request duration in milliseconds | `245ms` |
| `status` | String | API high-level outcome status | `success`, `error` |
| `error_code` | String | Structured application error code | `KYC_LEVEL_REQUIRED` |
| `currency` | String | ISO-4217 currency code | `USD`, `EUR`, `IRR` |
| `email` | String | User email for authentication initiation | `user@example.com` |

---

## 4. Technical Redaction Architecture in `ecardo_userapp_v1`

The redaction engine is integrated directly into `NetworkService` (`lib/src/network/service/network_service.dart`) and `OfflineRequestQueue` (`lib/src/common/services/offline_request_queue.dart`).

```
+---------------------------------------------------------------------------------------------------+
|                                  CLIENT-SIDE REDACTION PIPELINE                                   |
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|  Outgoing Request Payload / Headers                                                               |
|         |                                                                                         |
|         v                                                                                         |
|  +---------------------------------------------------------------------------------------------+  |
|  | Interceptors & Sanitizers                                                                   |  |
|  | - Token Redactor: Bearer tokens logged as `<redacted N chars>`                              |  |
|  | - Header Filter: Sensitive headers stripped from debug emissions                            |  |
|  | - _sanitizePayload(): Recursive Map and List tree-walker replacing denylist keys           |  |
|  +---------------------------------------------------------------------------------------------+  |
|         |                                                                                         |
|         +---> Emitted to Console / Telemetry: Completely Sanitized Payload Only                   |
|         |                                                                                         |
|         v                                                                                         |
|  Encrypted TLS Transmission to Gateway                                                            |
|         |                                                                                         |
|         v                                                                                         |
|  Incoming Response / Error Handling                                                               |
|         |                                                                                         |
|         v                                                                                         |
|  +---------------------------------------------------------------------------------------------+  |
|  | _handleDioErrorResponse(): Extracts sanitized message strings only                         |  |
|  | - Raw error response bodies containing tokens/secrets are NEVER dumped to debugPrint        |  |
|  | - Friendly user messages mapped via l10nPick                                                |  |
|  +---------------------------------------------------------------------------------------------+  |
+---------------------------------------------------------------------------------------------------+
```

### 4.1 Recursive Payload Sanitization (`_sanitizePayload`)
The static method `NetworkService.sanitizePayload(dynamic data)` recursively walks dynamic JSON objects:
1. When encountering a `Map`:
   - Inspects each key using `_isSensitiveKey(keyStr)`.
   - If sensitive: sets `sanitized[key] = '<redacted>'`.
   - If non-sensitive: recursively calls `_sanitizePayload(value)`.
2. When encountering a `List`:
   - Maps each item through `_sanitizePayload(item)`.
3. Strips casing, hyphens, and underscores:
   - Evaluates `key.replaceAll(RegExp(r'[-_\s]'), '')` against `_sensitivePayloadKeys`.

### 4.2 Error Response Protection (`_handleDioErrorResponse`)
When backend endpoints return `400`, `401`, `403`, `422`, `500`, or `503`:
- The raw `response.data` object is **never** printed to the console.
- Only the specific `message`, `error`, or `detail` string is extracted.
- Extracted error messages are scrubbed for database exceptions, internal path disclosures (e.g., `app/models/page`), or user enumeration hints via `_friendlyServerMessage()`.

### 4.3 Offline Queue Deep Scanner (`containsSensitiveData`)
`OfflineRequestQueue` validates all pending data structures before enqueueing:
- Recursively inspects every Map key and string value.
- Tokenizes string values into words via regex `extractWords()`.
- Detects partial matches such as `pin_code`, `card_pan`, `nationalid`.
- Immediately aborts enqueueing if any sensitive token is found.

---

## 5. Verification & Automated Test Suites

The log redaction and sanitization controls are validated by automated unit test suites in `test/workstream_b_idempotency_logging_test.dart` and `test/offline_request_queue_test.dart`.

### 5.1 Test Suite 1: Payload Sanitization & Casing Tests
**Location:** `test/workstream_b_idempotency_logging_test.dart`  
**Group:** `Workstream B — Comprehensive PII & Secret Redaction in Logging`

1. **Test Case: Multi-Casing Redaction (`Sanitizes all sensitive keys in snake_case, camelCase, and kebab-case`)**
   - Injects a synthetic payload with 36 sensitive keys in multiple casings:
     `password`, `current_password`, `currentPassword`, `current-password`, `new_password`, `newPassword`, `new-password`, `password_confirmation`, `passwordConfirmation`, `password-confirmation`, `code`, `otp`, `passcode`, `pin`, `cvv`, `card_number`, `cardNumber`, `card-number`, `pan`, `access_token`, `accessToken`, `access-token`, `refresh_token`, `refreshToken`, `refresh-token`, `authorization`, `iban`, `account_number`, `accountNumber`, `account-number`, `national_id`, `nationalId`, `national-id`, `secret`, `bearer`.
   - Asserts that 100% of these keys have value `'<redacted>'`.
   - Asserts that whitelisted keys (`email`, `amount`, `currency`, `status`, `description`) remain unmasked.

2. **Test Case: Deeply Nested Hierarchy Sanitization (`Sanitizes deeply nested Maps and Lists recursively`)**
   - Injects a deeply nested data structure:
     `{'batch': [{'user': {'nationalId': '...', 'cards': [{'cardNumber': '...', 'cvv': '...'}]}, 'auth': {'accessToken': '...'}}]}`
   - Asserts that all sensitive attributes in nested objects and arrays are replaced with `'<redacted>'`.

3. **Test Case: Case-Insensitive Scrubbing (`Case-insensitive sensitive key redaction`)**
   - Injects uppercase keys: `PASSWORD`, `PIN`, `CVV`, `IBAN`, `PAN`, `CardNumber`, `National_Id`, `Access_Token`.
   - Asserts that every uppercase key is redacted.

### 5.2 Test Suite 2: Console & Log Leakage Negative Tests
**Location:** `test/workstream_b_idempotency_logging_test.dart`  
**Group:** `Workstream B — Error Response Sanitization & Log Protection`

1. **Test Case: Error Response Log Suppression (`_handleDioErrorResponse does NOT log raw response bodies or credentials`)**
   - Intercepts Flutter's `debugPrint` callback to capture all console emissions.
   - Triggers simulated HTTP 400, 401, 422, and 500 error responses carrying sensitive synthetic payloads:
     - `access_token: 'SUPER_SECRET_LEAKED_ACCESS_TOKEN'`
     - `refresh_token: 'SUPER_SECRET_REFRESH_TOKEN'`
     - `secret_dump: 'PRIVATE_KEY_BYTES_12345'`
     - `errors: {'pin': ['Wrong PIN entered: 9988'], 'cardNumber': ['Card 5022291012345678 is invalid']}`
   - Asserts that none of the secret tokens, private keys, or raw JSON keys appear anywhere in `capturedLogs`.
   - Asserts that logs contain only sanitized HTTP status codes and friendly error messages.

2. **Test Case: Transport Timeout Authorization Leak Prevention (`Transport timeout logging does not leak authorization tokens`)**
   - Triggers transport timeout exceptions on requests carrying `Authorization: Bearer my-sensitive-token`.
   - Asserts that captured log lines do not contain the raw token string.

### 5.3 Test Suite 3: Offline Queue Sanitization Tests
**Location:** `test/offline_request_queue_test.dart`  
**Group:** `SEC-OFF-02: Deep payload sensitive-data scanner`

1. **Test Case: Sensitive Key Rejection in Queue**
   - Tests payloads containing `password`, `pin`, `cvv`, `pan`, `amount`, `transfer`, `withdraw`, `wallet`.
   - Asserts `queue.isQueueable()` returns `false`.

2. **Test Case: String Value Scanner**
   - Injects payloads where keys are benign but string values contain sensitive terms (e.g., `{'notes': 'my card_pan is 5022'}`).
   - Asserts that payloads are flagged as sensitive and rejected from the offline queue.

---

## 6. Continuous Integration & Pipeline Security Gates

1. **Automated Unit Test Gate:**
   - Every pull request and commit to main runs `flutter test test/workstream_b_idempotency_logging_test.dart` and `test/offline_request_queue_test.dart`.
   - Any assertion failure blocks the build immediately.

2. **Synthetic Vector Negative Scan:**
   - Pre-release CI runs automated pattern scanners using synthetic test corpora (valid Luhn credit card numbers, ISO 13616 Mod-97 IBANs, high-entropy test passwords, valid base64url JWTs).
   - Scans verify that test output logs and artifact reports contain zero raw synthetic vectors.

3. **Code Review Invariant:**
   - Any addition of new endpoints or models must register new sensitive keys in `_sensitivePayloadKeys` and `sensitiveTokens`.
   - Direct calls to `print()` or un-sanitized `debugPrint()` are prohibited and rejected by static analysis rules.
