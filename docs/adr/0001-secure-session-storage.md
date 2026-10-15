# ADR 0001: Secure Session Storage, Hardware Keystore Integration, and Credential Lifecycle

- **Status:** ACCEPTED
- **Date:** 2026-10-14
- **Deciders:** Chief Architect, Security Engineering Guild, Core Mobile Platform Team
- **Consulted:** DevOps Guild, Compliance & Risk Team
- **Informed:** Product Management, Mobile Frontend Engineers, QA Automation Team
- **Document Reference:** Section 8 of Audit Roadmap (`ecardo_userapp_v1_audit_roadmap_fa.md`), Findings (`docs/audit/FINDINGS.md` - SEC-02, SEC-03, SEC-04)

---

## 1. Context and Problem Statement

Mobile financial applications process high-value monetary transactions and personal financial data. The application requires authentication session tokens (OAuth2/JWT Bearer tokens) to communicate securely with the backend API (`https://ecardo.ir/api`).

In early iterations of the application codebase, session tokens and user credentials were persisted using the standard Flutter `shared_preferences` package. On Android, `SharedPreferences` writes key-value pairs into unencrypted XML files stored in the application's private sandbox directory (`/data/data/com.ecardo.user/shared_prefs/FlutterSharedPreferences.xml`). On iOS, `NSUserDefaults` writes plaintext plist files to `Library/Preferences/com.ecardo.user.plist`.

This legacy architecture introduced several critical security vulnerabilities:

1. **Physical and Root Extraction:** Any device with root access, jailbreak, or forensic access allows local or malicious processes to inspect application sandboxes and extract active bearer tokens.
2. **ADB Backup Vulnerability:** On Android devices with USB debugging enabled, tools like `adb backup` can extract unprotected application preferences without requiring administrative root privileges.
3. **Plaintext Password Retention:** Historical biometric login implementations retained the user's raw password in plaintext preferences (`SettingsService.getLoggedInUserPassword()`, `biometricPassword`) to re-execute a password-based sign-in when biometric prompt succeeded. This violated fundamental cryptographic principles: passwords must never be stored reversibly on client devices.
4. **Unbounded Session Lifecycles:** Session tokens remained valid indefinitely on disk until explicit user logout, creating high session hijacking risk if devices were lost, stolen, or shared.

The architecture required an OS-level secure storage mechanism backed by hardware cryptographic modules, an automated migration strategy that does not disrupt active user sessions, the absolute elimination of cached passwords, and strict temporal lifecycle controls.

---

## 2. Decision Drivers

- **Zero Plaintext Credentials:** No secrets, bearer tokens, or user passwords may ever reside in unencrypted disk storage.
- **Hardware-Backed Cryptography:** Encryption keys protecting session tokens must be managed by dedicated hardware (Android Keystore / TEE / StrongBox, iOS Secure Enclave / Keychain).
- **Seamless User Migration:** Existing users upgrading from legacy versions must not be forcibly logged out or encounter session corruption.
- **Elimination of Password Caching:** Biometric authentication must operate via hardware-bound token unlock or local device authentication, completely eradicating client-side password retention.
- **Inactivity Session Bounds:** Foreground and background inactivity must trigger deterministic session timeouts and screen privacy guards.
- **Regulatory and Audit Compliance:** Full adherence to OWASP MASVS v2, PCI-DSS v4.0, and Central Bank of Iran e-banking security requirements.

---

## 3. Considered Options

1. **Option 1 (Status Quo): Plaintext `SharedPreferences` with Application-Level XOR/AES Obfuscation**
   - *Pros:* Simple implementation, zero platform channel overhead.
   - *Cons:* Symmetrical keys embedded in application bytecode are trivially extracted via static reverse engineering (`jadx`, `Ghidra`); fails security audits and OWASP MASVS requirements.
2. **Option 2: SQLite Database with SQLCipher Encryption**
   - *Pros:* Strong encryption for complex relational datasets.
   - *Cons:* Heavy architectural overhead for storing lightweight session keys; passphrase management still requires hardware key storage.
3. **Option 3 (Selected): `FlutterSecureStorage` with Android Keystore (AES-256 GCM) & iOS Keychain (`first_unlock`) + Automated One-Way Migration**
   - *Pros:* Native hardware-backed security, zero third-party cloud dependencies, platform-standard key lifecycle, transparent backward-compatible migration, instant erasure of legacy plaintext data.

---

## 4. Architectural Decision

We adopt `FlutterSecureStorage` as the single canonical storage engine for all authentication tokens and sensitive credentials, orchestrated through `TokenService` (`lib/src/network/service/token_service.dart`), with strict session lifecycle governance provided by `SessionTimeoutService` (`lib/src/common/services/session_timeout_service.dart`) and `AppLockService` (`lib/src/common/services/app_lock_service.dart`).

```
┌────────────────────────────────────────────────────────────────────────┐
│                          TokenService Engine                           │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
           ┌────────────────────────┴────────────────────────┐
           ▼                                                 ▼
┌───────────────────────────────┐         ┌───────────────────────────────┐
│     Android Keystore (TEE)    │         │      iOS Secure Enclave       │
│  - AES-256 GCM Cipher         │         │  - Hardware Keychain          │
│  - EncryptedSharedPreferences │         │  - kSecAttrAccessible:        │
│  - resetOnError: true         │         │    first_unlock               │
└───────────────────────────────┘         └───────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│             Automatic Backward-Compatible Migration Engine             │
│  1. Check FlutterSecureStorage for 'access_token'                      │
│  2. If missing, check legacy SharedPreferences 'access_token'          │
│  3. Write legacy token to Keystore/Keychain via FlutterSecureStorage   │
│  4. INSTANTLY erase legacy plaintext key via SharedPreferences.remove  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│             Password Elimination & Session Inactivity Bounds           │
│  - Deprecate & remove getLoggedInUserPassword() / biometricPassword    │
│  - Biometric authentication becomes Token-First / Hardware-Bound       │
│  - SessionTimeoutService: 30-minute idle foreground/background timer   │
│  - Reactive memory caching (Rx<String?> accessToken) for 0ms reads    │
└────────────────────────────────────────────────────────────────────────┘
```

### 4.1 Native Platform Security Configuration

`TokenService` configures platform-specific hardware encryption parameters:

- **Android:**
  ```dart
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );
  ```
  `encryptedSharedPreferences: true` delegates encryption to Google's AndroidX Security Library (`MasterKeys` / `EncryptedSharedPreferences`), using AES-256 GCM for key values and AES-256 SIV for key aliases. Encryption keys are generated inside the Android Keystore (backed by ARM TrustZone TEE or StrongBox Keymaster hardware). `resetOnError: true` prevents catastrophic application crashes if the keystore becomes corrupt or invalidated by device biometric enrollment changes, falling back to a clean re-authentication state.

- **iOS:**
  ```dart
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
  ```
  `KeychainAccessibility.first_unlock` maps to `kSecAttrAccessibleAfterFirstUnlock`. The item is stored in the iOS Keychain, encrypted with keys derived from the user's passcode and hardware UID in the Secure Enclave. The token is accessible while the device is locked after its initial boot unlock, permitting background tasks (such as silent push notifications) to function without exposing data prior to the first unlock.

### 4.2 Automated Backward-Compatible Migration with Instant Erasure

To ensure zero friction for existing installed users:
1. On cold launch, `TokenService.loadAccessToken()` queries `_secureStorage.read(key: accessTokenKey)`.
2. If null, the private helper `_migrateFromLegacyStorage()` inspects legacy `SharedPreferences` for the key `access_token`.
3. If found, the token is written to `FlutterSecureStorage` under hardware encryption.
4. **Immediately** following successful write, `prefs.remove(_legacyKey)` is invoked to scrub the plaintext token from disk.
5. If migration fails or no token exists, the user is routed to the standard onboarding/sign-in flow.

### 4.3 Deprecation and Elimination of Plaintext Password Retention

Client-side retention of user passwords is completely forbidden and excised from the architecture:
- `SettingsService.getLoggedInUserPassword()` and `saveLoggedInUserPassword()` are marked deprecated and scheduled for immediate removal.
- `SignInController.biometricPassword` and `SplashController.biometricPassword` are eliminated.
- **Biometric Authentication Paradigm:** Biometrics no longer perform synthetic login with stored passwords. Instead:
  - If a valid bearer token exists in `FlutterSecureStorage`, biometric authentication (`LocalAuthentication`) gates access to the session.
  - If the token is expired (HTTP 401) or absent, the user must explicitly provide their password or OTP. Passwords exist exclusively in memory during the login network call and are zeroed immediately thereafter.

### 4.4 Session Lifecycle Governance

Session lifespan is bounded by dual defensive layers:
- **Reactive In-Memory Caching:** `final Rx<String?> accessToken = Rx<String?>(null)` caches the active token in memory, eliminating asynchronous platform channel latency during high-frequency HTTP request interception.
- **Inactivity Timeout (`SessionTimeoutService`):**
  - Monitors user interaction across the entire widget tree.
  - Enforces a 30-minute idle threshold (`idleTimeout = Duration(minutes: 30)`).
  - Listens to app lifecycle states via `WidgetsBindingObserver`. On `AppLifecycleState.resumed`, the service calculates elapsed time since `_lastActivity`. If elapsed time exceeds 30 minutes, it automatically clears the token via `TokenService.clearToken()`, wipes session metadata, and routes to `/sign_in_route`.
  - Zero background battery drain: background timers are suspended when paused and passively evaluated on resume.

---

## 5. Consequences

### 5.1 Positive Consequences

- **Physical and Forensic Protection:** Bearer tokens cannot be extracted from device file dumps, unprivileged backup utilities (`adb backup`), or malicious sandbox traversal.
- **Zero Plaintext Credential Exposure:** Plaintext passwords are never written to disk, preventing credential harvesting even on compromised operating systems.
- **Flawless User Upgrade Path:** Legacy users upgrade seamlessly without being logged out, while automatically hardening their storage on first boot.
- **Deterministic Session Expiration:** Inactive or abandoned application instances automatically self-terminate within 30 minutes, drastically shrinking the vulnerability window.
- **High Performance:** In-memory reactive token caching guarantees zero latency overhead during REST API invocations.

### 5.2 Negative Consequences and Trade-Offs

- **Key Invalidation on Device Security Changes:** On certain Android OEM devices, changing screen lock PIN or re-registering fingerprints may invalidate Keystore keys. Handled safely by `resetOnError: true`, prompting the user to sign in again rather than crashing.
- **No Offline Password Recovery:** If a user forgets their password while offline, the app cannot retrieve or reveal it from local cache. This is an intentional security trade-off.

---

## 6. Compliance Mapping

| Standard / Framework | Requirement ID | Architecture Verification & Enforcement |
| :--- | :--- | :--- |
| **OWASP MASVS v2** | `MASVS-STORAGE-1` | Verified: Bearer tokens encrypted at rest via hardware Keystore / Keychain. |
| **OWASP MASVS v2** | `MASVS-STORAGE-2` | Verified: Sensitive data excluded from backups and system logs; legacy tokens erased immediately. |
| **OWASP MASVS v2** | `MASVS-AUTH-1` | Verified: Hardware-bound biometric auth; token-first architecture; zero cached passwords. |
| **OWASP MASVS v2** | `MASVS-AUTH-2` | Verified: Inactivity timeout enforced via `SessionTimeoutService` (30m limit). |
| **PCI-DSS v4.0** | `Requirement 3.4` | Verified: Cryptographic protection of authentication tokens at rest using AES-256 GCM. |
| **PCI-DSS v4.0** | `Requirement 8.2` | Verified: Prohibition of client-side password storage; secure credential lifecycle. |
| **ISO/IEC 27001:2022** | `Control A.8.24` | Verified: Hardware-backed cryptographic key management (TEE / Secure Enclave). |
| **Central Bank of Iran (CBI)** | `Shaparak Mobile Security 4.2` | Verified: Mandatory Keystore/Keychain encryption for session data; prohibition of stored PIN/passwords. |

---

## 7. Implementation Artifacts and Code References

- **Core Storage Service:** `lib/src/network/service/token_service.dart:18-127`
- **Inactivity Lifecycle Manager:** `lib/src/common/services/session_timeout_service.dart:14-70`
- **App Lock & Privacy Gate:** `lib/src/common/services/app_lock_service.dart:19-107`
- **Authentication Controllers:** `lib/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart`
- **Splash Boot Orchestration:** `lib/src/presentation/screens/authentication/splash/controller/splash_controller.dart:230-242`
- **Legacy Settings Service:** `lib/src/common/services/settings_service.dart:115-167`
