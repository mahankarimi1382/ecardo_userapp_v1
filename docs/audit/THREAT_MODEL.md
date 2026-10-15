# eCardo User App (v1) — Threat Model & Security Posture (OWASP MASVS)

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa.md` — Phase 1 & OWASP MASVS/MASTG  
**Inspected Commit SHA:** `d56ab71d293ca1c7ec29b63863ecbc40ca9c8d67`

---

## 1. Threat Profile & Target Assets

The `ecardo_userapp_v1` client is a multi-currency fintech and travel application operating in Iran and international corridors. The primary assets requiring defense-in-depth protection are:

| Asset | Sensitivity | Storage Location | Threat Exposure |
| :--- | :--- | :--- | :--- |
| **API Access / Bearer Token** | Critical | OS Secure Storage (Keystore/Keychain) | Impersonation, unauthorized API access |
| **User Password** | Critical | Transmitted in transit only (Zero local retention) | Account takeover |
| **App Lock Passcode / PIN** | High | Salted SHA-256 hash in Secure Storage | Unauthorized local access on stolen device |
| **Financial Cards & Sheba** | High | Masked in memory & UI, SSL in transit | Identity theft, card scraping |
| **KYC Identity Documents** | High | Memory / multipart stream only | PII exposure, privacy violations |
| **Release Signing Keystores** | Critical | GitHub Secrets / Offline HSM (Not in Git) | Malicious app supply chain trojanization |

---

## 2. Threat Actor Analysis & Attack Vectors

```
+-------------------------------------------------------------------------+
|                              ATTACK SURFACE                             |
+-------------------------------------------------------------------------+
| 1. Physical Device Access     --> App Lock, Inactivity Timeout, Bio Gate |
| 2. Rooted/Jailbroken OS       --> Hardware Keystore/Keychain Isolation   |
| 3. Network MITM / Rogue Wi-Fi --> SSL Pinning, Cleartext Blocked, CA Lock|
| 4. App Switcher / Shoulder    --> Balance Obscuring, Screen Privacy      |
| 5. Accidental Double-Tap      --> Client Lock + Server Idempotency Keys  |
| 6. Token Expiration Race      --> 401 Mutex Queue, Single-Flight Logout  |
+-------------------------------------------------------------------------+
```

---

## 3. Defense-in-Depth Verification (MASVS Evaluation)

### 3.1 MASVS-STORAGE (Data Storage & Privacy)
- **Token Storage:**
  - Verified in `lib/src/network/service/token_service.dart:18-36`.
  - Stored in `FlutterSecureStorage` with `AndroidOptions(encryptedSharedPreferences: true)` backed by the Android Keystore system.
  - iOS Keychain configured with `KeychainAccessibility.first_unlock`.
  - Automatic migration from legacy `SharedPreferences` deletes plaintext records immediately upon successful migration.
- **Password Exposure Audit:**
  - `saveLoggedInUserPassword()` in `SettingsService` is deprecated and no longer invoked by any login path.
  - Modern biometric auth uses `TokenService.accessToken` directly.
  - Legacy fallback code in `splash_controller.dart:231` must be pruned in Phase 1 cleanup.
- **App Switcher Privacy:**
  - `AppLockService._handleBackgroundPrivacy()` toggles `isPrivacyMode = true` and `hideBalanceOnBackground = true` the moment the app enters `paused` or `inactive` states.

### 3.2 MASVS-NETWORK (Network Communication)
- **Cleartext Traffic:**
  - `AndroidManifest.xml:37` declares `android:usesCleartextTraffic="false"`.
  - `android/app/src/main/res/xml/network_security_config.xml` blocks cleartext for all base traffic and disallows user-installed CAs for `ecardo.ir`, `trip.ecardo.ir`, and `travel-origin.ecardo.ir`.
- **TLS Certificate Pinning:**
  - Implemented in `lib/src/network/config/ssl_pinning_config.dart`.
  - CI pipeline (`.github/workflows/flutter.yml:116-160`) validates base64 SHA-256 certificate pins against the live production server before producing release builds (fail-closed).
- **Sensitive Log Redaction:**
  - Dio logger configured with `kDebugMode` guards. Authorization tokens, card numbers, and passwords are not emitted in release APK builds.

### 3.3 MASVS-AUTH (Authentication & Session Management)
- **Session Lifecycle & Inactivity Lock:**
  - Implemented via `AppLockService` using passive `WidgetsBindingObserver` (zero background battery drain).
  - Configurable auto-lock timeout. If elapsed background time exceeds the policy, `AppLockWrapper` overlays `LockScreen` on resume.
- **Concurrent 401 Refresh Handling:**
  - `NetworkService:275-334` implements an atomic queue (`_pendingRequests`) and boolean flag (`_isRefreshing`).
  - Concurrent 401 responses do not trigger duplicate refresh calls; in-flight requests are queued and replayed with the new token or cleanly rejected upon refresh failure.

### 3.4 MASVS-CODE (Code Integrity & Release Security)
- **Release Signing Configuration:**
  - Verified in `android/app/build.gradle.kts:44-59`.
  - Hard configuration-time fail-closed check: if `key.properties` is absent when running release or bundle tasks, Gradle throws a fatal `GradleException`.
  - Keystore passwords and key files are strictly excluded via `.gitignore:58-63`.
- **Code Obfuscation:**
  - R8 code shrinking and resource shrinking enabled (`isMinifyEnabled = true`, `isShrinkResources = true`).
  - Verified rules in `android/app/proguard-rules.pro`.
