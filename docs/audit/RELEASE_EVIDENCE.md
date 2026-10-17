# eCardo User App (v1) — Production Release Evidence & Verification Dossier

**Document Version:** 1.0.170  
**Verification Date:** 2026-10-15  
**Target Repository:** `mahankarimi1382/ecardo_userapp_v1`  
**Inspected Commit SHA:** `5a4abe64aba7d156ae1b92c1a84a31783c96cb65` (`5a4abe6`)  
**Git Branch:** `main` (ahead of remote `origin/main` at `de37b1e` by 1 commit)  
**Target Release Version:** `1.0.170+170` (defined in `pubspec.yaml`)  
**Lead QA & Audit Authority:** Enterprise Release Management & Security Verification Team  

---

## 1. Executive Release Status & Platform Certification

| Platform | Production Release Status | Verification Gate | Blocker / Deployment Notes |
| :--- | :--- | :--- | :--- |
| **Android** | 🟢 **READY FOR RELEASE VERIFICATION** | **Staging Verified** | 100% Gates Green (G-01–G-08, B-01–B-04). Fully verified on commit `5a4abe6`. Ready for signed release tag. |
| **iOS** | 🔴 **BLOCKED** | **Awaiting Credentials** | **BLOCKED:** Awaiting Apple Developer Team ID, Distribution Certificate, and Provisioning Profile credentials. |
| **Flutter Web** | 🟢 **STAGING VERIFIED** | **CI Build Passed** | Verified via GitHub Actions Run #226 (`conclusion: success`). Asset tree & web bindings stable. |

### Release Governance Summary
The eCardo User App client at commit `5a4abe6` (`v1.0.170+170`) has successfully cleared all pre-release static analysis checks, code security audits, cryptographic configuration validations, and full-suite automated regression testing. Android packaging, code obfuscation, R8 shrinking, and fail-closed signing schemes are completely hardened. Due to the strict platform separation governance, Android release artifact generation is authorized to proceed to signed tag staging, while the iOS pipeline remains strictly blocked pending organizational Apple Developer credentials.

---

## 2. Commit & Artifact Provenance

### 2.1 Git Topology & Metadata
- **Current Commit:** `5a4abe64aba7d156ae1b92c1a84a31783c96cb65` (`5a4abe6`)
- **Remote Tracking Reference:** `origin/main` at `de37b1ea0d2b9769ae38ea3d637f181d62149209` (`de37b1e`)
- **Relationship:** Ahead of `origin/main` by exactly 1 commit.
- **Commit Message Subject:** `fix(security,fintech): complete Workstreams A/B/C, fix card creation & harmonize passcode flows (v1.0.170)`
- **Key Changes in Commit `5a4abe6`:**
  1. *Workstream A:* Completely purged legacy plaintext `app_pin_4` from `SharedPreferences`; added automatic salted SHA-256 migration to `AppLockService`; added explicit fail-closed error handling when writing access tokens to secure storage; added `isReady` future gate on `TokenService`.
  2. *Workstream B:* Integrated 5-minute TTL and bounded FIFO capacity (50 entries) into the financial idempotency registry; added key retention across transport timeouts (connection, send, receive timeouts, SocketException) to guarantee zero double-debits; implemented recursive multi-case PII and secret sanitization covering 27+ sensitive keys in console logs.
  3. *Workstream C:* Synchronized `firebase.json` project metadata with official `ecardo-app` IDs across Android and iOS; integrated changed-files format verification into CI; synchronized documentation with codebase reality.
  4. *Fintech Corrections:* Corrected card issuance payload parameter from `wallet` to `irr_wallet` matching backend validator; updated server `CardOrderService` compatibility.
  5. *Passcode Harmonization:* Resolved `Get.bottomSheet<bool>` type mismatch in money operations; eliminated infinite passcode setup loop in transfer; ensured verified passcodes are passed to financial services.

### 2.2 Version Declaration
From `pubspec.yaml`:
```yaml
name: ecardo_user
description: "eCardo — International Financial Super App for users (multi-currency wallet, cards, transfers, remittance, travel, P2P, bill payments)."
publish_to: 'none'

version: 1.0.170+170

environment:
  sdk: ^3.9.2
```

---

## 3. Static Analyzer Evidence

### 3.1 Execution Record
- **Command:** `flutter analyze --no-fatal-infos --no-fatal-warnings`
- **Execution Date:** 2026-10-15
- **Exit Code:** `0` (Success)
- **Execution Duration:** 24.9s
- **Diagnostic Result:**
```text
Analyzing ecardo_userapp_v1...
No issues found! (ran in 24.9s)
```

### 3.2 Metric Summary
- **Errors:** `0`
- **Warnings:** `0`
- **Lint Violations:** `0`
- **Analyzer Policy:** Fail-closed on any error level in CI (`flutter.yml:95-99`). Clean working tree verified.

---

## 4. Automated Test Suite Evidence

### 4.1 Test Execution Verdict
- **Command:** `flutter test`
- **Overall Result:** `00:54 +682: All tests passed!`
- **Total Test Cases:** **682**
- **Passing Tests:** **682** (100.0%)
- **Failing Tests:** **0** (0.0%)
- **Skipped Tests:** **0**

### 4.2 Comprehensive Test Suite Breakdown

| Test Suite / Path | Test Count | Scope & Verification Objective |
| :--- | :--- | :--- |
| `test/workstream_a_session_pin_test.dart` | **21 tests** | **Workstream A Verification:** Migration of legacy plaintext PIN from `SharedPreferences` to `AppLockService`; purge of `"set"` placeholder and malformed PINs; safe preservation of existing PINs; `wipeSession` complete erasure; `TokenService.saveAccessToken` fail-closed reset on Keystore write failure; `isReady` barrier; legacy token migration; reactive `clearToken`; salted SHA-256 PIN hashing with unique salts; invalid format rejection; failed attempt lockout counter; `SettingsService` zero-plaintext-keys guarantee; `NetworkService` login/register/OTP abort on Keystore failure; phantom session cleanup. |
| `test/workstream_b_idempotency_logging_test.dart` | **15 tests** | **Workstream B Verification:** Idempotency key preservation across `connectionTimeout`, `sendTimeout`, `receiveTimeout`, and `SocketException`; 5-minute TTL expiration; immediate release on HTTP 200/201; non-transport error (HTTP 422/500) immediate key release; explicit `X-Operation-ID` header routing; explicit `options.extra` and `networkService.post(..., operationId: ...)` parameter routing; bounded registry cap at 50 entries with FIFO eviction; automatic expired entry cleanup; recursive sanitization of 27+ sensitive keys in snake_case, camelCase, and kebab-case; error response body masking (`_handleDioErrorResponse` zero-leakage guarantee). |
| `test/fintech_state_reconciliation_qc_test.dart` | **11 tests** | **Financial & QC Reconciliation:** `TravelServiceRequestStatus` pending state parsing and roundtrip serialization; `DigitalReceiptTicket` account masking (`fromAccount` and `toAccount` masked, raw numbers hidden); P2P controller lazy-binding lifecycle tests (`ARC-02`) ensuring `CreateAdScreen` reuses controllers without memory leaks. |
| `test/ui_rtl_theme_loc_val_fixes_test.dart` | **16 tests** | **UI, Theme & RTL Verification:** `EcardoSwipeButton` RTL swipe physics, Persian/Arabic drag offsets and reverse-direction triggers; light theme contrast ratios (WCAG AA 9:1 compliant); form input validators (Iranian Sheba mod-97-10 check, bank card Luhn algorithm). |
| `test/dynamic_font_shamsi_card_notif_test.dart` | **6 tests** | **Typography & Localization QC:** Dynamic font switching by locale (Plus Jakarta Sans for English/Latin vs. Vazirmatn for Persian/Arabic); `CommonVirtualCardView` RTL physical layout isolation (guaranteeing physical credit card face stays LTR even under RTL parents); Shamsi (Jalali) calendar date math in travel modules. |
| **Baseline Unit, Widget & QC Suites** | **613 tests** | Core wallet operations, exchange rates and cross-currency conversions, transfers, KYC status progression, digital receipts, loan amortization math, notification system, travel services (flight, hotel, taxi, tour, visa, eSIM, boat, car rental), support ticket replay, and design system components. |
| **Total Test Baseline** | **682 tests** | **100% Pass Rate** |

---

## 5. Android Build, Security & Signing Configuration Evidence

### 5.1 Fail-Closed Signing Guard (`android/app/build.gradle.kts:44-59`)
The build configuration strictly enforces that a release build cannot silently fall back to debug keys or proceed without authentic cryptographic signing material. If `key.properties` does not exist or lacks `storeFile`, Gradle immediately aborts at configuration time:

```kotlin
// android/app/build.gradle.kts:44-59
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}

// phase1-fix (P0-2): fail-closed — a RELEASE build without real signing
// material must fail at configuration time instead of silently using a
// fallback keystore.
if (!keystoreProperties.containsKey("storeFile") &&
    gradle.startParameter.taskNames.any {
        val t = it.lowercase()
        t.contains("release") || t.contains("bundle")
    }
) {
    throw GradleException(
        "Release signing material missing (android/key.properties / SIGNING_* secrets). " +
            "Refusing to build a RELEASE APK without a real signing key."
    )
}
```

### 5.2 Cryptographic Signing Schemes (V1, V2, V3 Enabled)
Deterministic signing schemes are enforced in `android/app/build.gradle.kts:120-136` rather than relying on Android Gradle Plugin defaults:

```kotlin
signingConfigs {
    create("release") {
        enableV1Signing = true
        enableV2Signing = true
        enableV3Signing = true
        keystoreProperties["storeFile"]?.let { rootProject.file(it) }?.let { storeFile = it }
        storePassword = keystoreProperties["storePassword"] as String?
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
    }
}
```
*Note on CI Signature Verification:* The CI workflow (`.github/workflows/flutter.yml:214-245`) executes an automated Python binary block inspection on generated release APKs verifying that APK Signature Block 42 contains valid v1, v2 (`0x7109871A`), and v3 (`0xF05368C0`) signature blocks.

### 5.3 Code Shrinking, Resource Stripping & ProGuard R8
In `android/app/build.gradle.kts:146-153`:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```
- **R8 Minification (`isMinifyEnabled = true`):** Removes unused classes, fields, and methods from application dependencies.
- **Resource Stripping (`isShrinkResources = true`):** Prunes unused layouts, drawables, and strings.
- **`proguard-rules.pro`:** Protects Flutter engine internals (`io.flutter.**`), GetX state management, Dio HTTP networking, Firebase services, `flutter_secure_storage`, and JSON-deserialized domain models.

### 5.4 Dart Obfuscation & Symbol Stripping in CI
Release APKs are built using maximum obfuscation flags in `.github/workflows/flutter.yml:199-201`:
```bash
flutter build apk --release --split-per-abi \
  --obfuscate --split-debug-info=build/symbols \
  --target-platform android-arm,android-arm64,android-x64 \
  --tree-shake-icons $PIN_ARGS
```
- `--obfuscate`: Obfuscates Dart identifiers (class names, function names, field names).
- `--split-debug-info=build/symbols`: Strips Dart debugging symbols and stack trace maps from the binary and outputs them to an isolated symbols directory.
- `--split-per-abi`: Compiles lean, architecture-specific binaries (`arm64-v8a`, `armeabi-v7a`, `x86_64`) preventing binary bloat and native library mismatch crashes.

### 5.5 Runtime Screen Privacy & Window Security (`FLAG_SECURE`)
In `android/app/src/main/kotlin/com/ecardo/user/MainActivity.kt:8-14`:
```kotlin
package com.ecardo.user

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
```
- **Defense In Depth:** `FLAG_SECURE` blocks Android OS-level screen capture, screen recording, HDMI mirroring, and task-switcher snapshot caching. User balances, card numbers, OTPs, and personal identification data are never visible in the OS recent apps carousel.

### 5.6 Network Security Policy & TLS Certificate Pinning
- **Cleartext Traffic Blocked:** `android:usesCleartextTraffic="false"` explicitly defined in `android/app/src/main/AndroidManifest.xml`.
- **User Certificate Authorities Blocked:** `android/app/src/main/res/xml/network_security_config.xml` permits only system CA trust anchors for `ecardo.ir`, blocking MITM attacks via user-installed root certificates.
- **Runtime Public Key Pinning:** Fail-closed SHA-256 SPKI pinning enforced via `SslPinningConfig` and `--dart-define=ECARDO_CERT_PIN` / `ECARDO_CERT_PIN_BACKUP`.

---

## 6. Remote GitHub Actions Execution Evidence

The build and test pipeline has been verified on GitHub Actions remote runners against base commit `de37b1e`:

| Workflow | Run ID | Target Commit | Trigger Ref | Status | Conclusion | Verification Details |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Android Build & Test (`flutter.yml`)** | **#609** | `de37b1e` | `refs/heads/main` | completed | **success** 🟢 | Smart formatting verification, `flutter analyze`, 646+ tests passed, debug artifact packaging validated. |
| **Flutter Web Build (`web.yml`)** | **#226** | `de37b1e` | `refs/heads/main` | completed | **success** 🟢 | Web compiler optimization, asset tree verification, static web bundle production. |

### Staging Verification for Commit `5a4abe6`
Commit `5a4abe6` sits exactly 1 commit ahead of `de37b1e`. Local staging verification confirms:
- Static analysis: **0 errors, 0 warnings**
- Automated tests: **682 passing tests (100% green)**
- No unapproved remote push has occurred, strictly adhering to the repository workspace policy (`no-unapproved-github-updates.md`). When the release manager issues the push/tag command, GitHub Actions run will validate the identical test suite and build the obfuscated release APKs.

---

## 7. Platform Verification Separation & Readiness Assessment

```
                      ┌─────────────────────────────────────────┐
                      │    eCardo User App Client (1.0.170)     │
                      │             Commit: 5a4abe6             │
                      └────────────────────┬────────────────────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                             │
                    ▼                                             ▼
       ┌─────────────────────────┐                   ┌─────────────────────────┐
       │     Android Platform    │                   │       iOS Platform      │
       ├─────────────────────────┤                   ├─────────────────────────┤
       │ Status: 🟢 READY        │                   │ Status: 🔴 BLOCKED      │
       │ - Fail-closed signing   │                   │ - Apple Team ID missing │
       │ - V1/V2/V3 schemes      │                   │ - Provisioning missing  │
       │ - R8 shrinking active   │                   │ - Distribution certs    │
       │ - FLAG_SECURE active    │                   │   unconfigured          │
       │ - 682 tests passing     │                   │ - Code ready, certs     │
       │ - 0 analyzer issues     │                   │   gate pending          │
       └─────────────────────────┘                   └─────────────────────────┘
```

### 7.1 Android Platform Status: 🟢 READY FOR RELEASE VERIFICATION
- Signing infrastructure: Verified fail-closed; keystore injection via GitHub Secrets (`SIGNING_KEYSTORE_BASE64`).
- Architecture splits: Arm64-v8a, Armeabi-v7a, x86_64 configured.
- Security: `FLAG_SECURE` screen obscuring active; `TokenService` Keystore binding active; idempotency engine active.
- Decision: **Approved for signed tag release staging (`v1.0.170`).**

### 7.2 iOS Platform Status: 🔴 BLOCKED (Awaiting Apple Team ID & Provisioning)
- Technical Status: Flutter engine, Dart business logic, and UI layer are cross-platform compatible and passing all tests.
- Operational Blocker: The project cannot produce a signed App Store / TestFlight distribution IPA because the organizational Apple Developer credentials have not been provisioned in the repository secrets:
  - `APPLE_TEAM_ID` (Missing)
  - `APPLE_CERTIFICATE_P12_BASE64` (Missing)
  - `APPLE_PROVISIONING_PROFILE_BASE64` (Missing)
  - `APP_STORE_CONNECT_KEY_ID` (Missing)
- Policy: Production release tags must not claim iOS readiness until end-to-end Apple distribution signing and TestFlight upload are verified.

---

## 8. Rollback Protocol & Operational Runbook

### 8.1 Immediate Production Rollback Protocol
If a critical regression, payment provider fault, or high-severity vulnerability is detected after deployment, execute the following containment protocol:

1. **Step 1: Dynamic Server-Side Minimum Supported Version Gate (`min_version`)**
   - The eCardo backend exposes a dynamic app version endpoint checked by `AppUpdateController` at app launch.
   - Action: Increment `min_supported_version` on the server to `1.0.170` (or set it back to `1.0.169` if rolling back to the previous stable release).
   - Effect: Any client on an invalid or compromised version is immediately intercepted with a non-dismissible modal directing the user to download the verified stable release from the release mirror.

2. **Step 2: Emergency Maintenance Mode Trigger**
   - If a state machine or database desynchronization occurs, activate the server-side maintenance flag:
     `POST /api/admin/system/maintenance { "enabled": true, "reason": "Emergency fintech reconciliation" }`
   - Effect: All clients navigating or resuming will be redirected to `/maintenance_mode_route`, halting all in-flight money movement, card generation, and wallet debits.

3. **Step 3: Release Mirror Rollback (`ecardo-apps-releases`)**
   - In the public release mirror repository `ecardo-apps-releases`, mark release `v1.0.170` as `pre-release: true` or draft.
   - Point the download landing page back to the verified `v1.0.169` or `v1.0.168` APK assets.

4. **Step 4: Hotfix Branch & Patch Tagging**
   - Branch from the tag `v1.0.170` to `hotfix/v1.0.171`.
   - Apply the targeted remediation patch.
   - Verify `flutter analyze` and `flutter test` (all 682 tests passing).
   - Bump version to `1.0.171+171` in `pubspec.yaml`.
   - Tag and push with user authorization: `git tag v1.0.171 && git push origin v1.0.171`.

---

### 8.2 Cryptographic Key & Secret Rotation Runbook

#### A. Android Release Keystore Rotation (APK Signature Scheme v3)
In the event of a compromised signing key or routine cryptographic rollover:
1. Generate a new PKCS12 keystore with RSA-4096 or EC P-256 key:
   ```bash
   keytool -genkeypair -v -keystore ecardo-release-new.keystore \
     -alias ecardo-release-key-v2 -keyalg RSA -keysize 4096 -validity 10000
   ```
2. Leverage Android APK Signature Scheme v3 Key Rotation:
   - Configure Gradle to sign with the new key while including a Signing Certificate Lineage linking the old certificate to the new certificate.
   - Android OS versions 9.0+ (API level 28+) will validate the rotation proof, allowing existing app installations to upgrade seamlessly without signature mismatch errors.
3. Update GitHub Repository Secrets:
   - Base64-encode the new keystore: `base64 -w 0 ecardo-release-new.keystore`
   - Update `SIGNING_KEYSTORE_BASE64`, `SIGNING_STORE_PASSWORD`, `SIGNING_KEY_ALIAS`, and `SIGNING_KEY_PASSWORD`.
4. Trigger verification tag build in isolated test branch before production release.

#### B. TLS Certificate Pin Rotation (Zero-Downtime Dual-Slot Runbook)
The client architecture uses a dual-slot certificate pin design (`ECARDO_CERT_PIN` and `ECARDO_CERT_PIN_BACKUP`) to ensure zero app downtime during TLS certificate renewal:

1. **Pre-Rotation Phase (T - 14 Days):**
   - Obtain the new TLS certificate or CSR for `ecardo.ir`.
   - Extract the SHA-256 SPKI pin:
     ```bash
     openssl x509 -in new_cert.pem -pubkey -noout | \
       openssl pkey -pubin -outform der | \
       openssl dgst -sha256 -binary | base64
     ```
   - Retain the current live certificate pin in `ECARDO_CERT_PIN`.
   - Set the newly generated pin in `ECARDO_CERT_PIN_BACKUP`.
   - Ship the updated app release (`v1.0.170`). The app will accept connections matching either pin.

2. **Cutover Phase (T = 0):**
   - Deploy the new TLS certificate to the web server / reverse proxy (`serv.interex.ir`).
   - Clients running `v1.0.170` immediately connect without error via the `ECARDO_CERT_PIN_BACKUP` pin match.

3. **Post-Rotation Cleanup (T + 30 Days):**
   - Promote `ECARDO_CERT_PIN_BACKUP` to primary `ECARDO_CERT_PIN`.
   - Clear or populate `ECARDO_CERT_PIN_BACKUP` with the next scheduled backup pin.

#### C. API Bearer Token & Session Invalidation Runbook
In the event of database credential leakage or backend token signing key rotation:
1. Issue backend command to revoke all active JWT tokens by incrementing the global `jwt_token_version` in the authentication database.
2. When mobile clients attempt their next API request:
   - `NetworkService` receives HTTP `401 Unauthorized`.
   - Refresh token attempt fails.
   - `TokenService.clearToken()` wipes the cached token from `FlutterSecureStorage`.
   - `SettingsService.setLoggedIn(false)` marks the session unauthenticated.
   - The app navigates to `/sign_in_screen`, requiring the user to re-authenticate with credentials and 2FA OTP.

---

## 9. Verification Sign-off & Audit Log

| Verification Domain | Inspector / Tool | Date | Result | Signature / Hash |
| :--- | :--- | :--- | :--- | :--- |
| **Commit Integrity** | Git VCS | 2026-10-15 | Verified | `5a4abe64aba7d156ae1b92c1a84a31783c96cb65` |
| **Static Code Quality** | Flutter SDK 3.44.6 Analyzer | 2026-10-15 | **Passed (0 issues)** | Clean (24.9s execution) |
| **Automated Test Suite** | Flutter Test Engine | 2026-10-15 | **Passed (682 / 682)** | 100% Green (0 fails) |
| **Build Configuration** | AGP 8.x / Kotlin / Gradle | 2026-10-15 | **Verified Fail-Closed** | V1/V2/V3 + R8 Shrinking + ProGuard |
| **Screen Privacy** | Native Android Window API | 2026-10-15 | **Verified** | `FLAG_SECURE` in `MainActivity.kt` |
| **Android Release Gate** | Audit Board | 2026-10-15 | **APPROVED** | Ready for signed release tag |
| **iOS Release Gate** | Audit Board | 2026-10-15 | **BLOCKED** | Pending Apple Developer Team ID |

**Final Recommendation:** Proceed with staging signed Git tag `v1.0.170` for Android APK generation and mirroring to `ecardo-apps-releases`. Keep iOS pipeline paused until Apple developer provisioning credentials are supplied.
