# eCardo User App (v1) — Production Release Verification Checklist

**Document Version:** 1.0.172  
**Date:** 2026-10-17  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa.md` & Re-Audit Remediation  
**Inspected Commit SHA:** `98e899368df43dfe0aa36dac64e5752cd0d661aa` (`98e8993`, tag `v1.0.172`, referencing `2502823` / `v1.0.171`)  
**Target Release Version:** `1.0.172+172` (in `pubspec.yaml`)  
**Evidence Dossier:** `docs/CURRENT_RELEASE.md` (active release) & `docs/audit/RELEASE_EVIDENCE.md` (historical archive)  

---

## 1. P0 Hard Release Gates (Must Pass Before Any Tag/Release)

- [x] **G-01 (Release Signing):** `android/app/build.gradle.kts:44-59` configuration-time check fails closed if `key.properties` is missing. Release build is signed using V1 + V2 + V3 schemes with dedicated release key from GitHub Secrets (`SIGNING_KEYSTORE_BASE64`). No release secrets or keystores committed to Git.
- [x] **G-02 (Secure Token Storage):** `TokenService` stores bearer tokens exclusively in `FlutterSecureStorage` (Android Keystore / iOS Keychain) with `isReady` future gate and fail-closed handling on write failure. Legacy SharedPreferences tokens are automatically migrated and erased.
- [x] **G-03 (Plaintext Password Pruning):** Legacy password retrieval fallback in `splash_controller.dart` and `biometricPassword` in `sign_in_controller.dart` are completely removed. Zero code paths ever touch or store a password for biometric unlock; bearer tokens exclusively manage session unlock.
- [x] **G-04 (App Lock & Screen Privacy):** App privacy is preserved through lifecycle-aware background obscuring in `AppLockWrapper` (`AppLockService`) with salted SHA-256 PIN authentication, failed attempt counter, and inactivity timeout on resume. Unconditional native `FLAG_SECURE` was removed in `7bce9ba`/`98e8993` to eliminate cold-start black screen on emulators, casting, and overlay devices.
- [x] **G-05 (Network Security & SSL Pinning):** `usesCleartextTraffic="false"` verified in `AndroidManifest.xml`. `network_security_config.xml` blocks user CAs for `ecardo.ir`. Dual-slot SSL cert pin (`ECARDO_CERT_PIN` & `ECARDO_CERT_PIN_BACKUP`) verified against live host in CI with fail-closed runtime checks.
- [x] **G-06 (Financial Idempotency):** In-flight `Idempotency-Key` and `X-Idempotency-Key` registry covers all 23 financial POST endpoints (`NetworkService`). Features 5-minute TTL, bounded FIFO capacity (50 entries), and retains keys across transport timeouts and HTTP 5xx responses to prevent double debits. Comprehensive recursive PII/secret redaction active. Client-side buttons lock on submit.
- [x] **G-07 (Code Quality & Tests):** `flutter analyze` reports zero errors (`No issues found!`, 0 errors, 0 warnings). `flutter test` executes with 100% pass rate (`01:41 +687: All tests passed!`, 687 tests passing across all workstreams, baseline, and re-audit security invariants).
- [x] **G-08 (Firebase Config Sync):** `firebase.json` project ID synchronized from legacy `qunzo-b2252` to match production `ecardo-app` declared in `firebase_options.dart` and real app IDs across Android and iOS.

---

## 2. Build & Packaging Requirements

- [x] **B-01 (Universal FAT APK Packaging):** CI builds a single Universal FAT release APK supporting all target ABIs (`armeabi-v7a`, `arm64-v8a`, `x86_64`) via `flutter build apk --release --target-platform android-arm,android-arm64,android-x64` to prevent ABI mismatch runtime errors across devices and emulators.
- [x] **B-02 (Code Shrinking & ProGuard R8):** R8 shrinking and resource stripping enabled in `android/app/build.gradle.kts:146-154` using standard `proguard-android.txt` with `-dontoptimize` and explicit rules in `proguard-rules.pro` (preserving Kotlin coroutine continuation methods & `SharedPreferencesApiRegistrar`). Dart obfuscation flags active in CI (`--obfuscate --split-debug-info=build/symbols`).
- [x] **B-03 (Desugaring):** Java 11 desugaring enabled with `desugar_jdk_libs:2.1.4`.
- [x] **B-04 (App Identification):** `applicationId` and `namespace` set to `com.ecardo.user`. App label is `eCardo`.

---

## 3. Localization & Regional Readiness Gate

- [x] **L-01 (Persian RTL & Shamsi):** Full Persian ARB coverage (`app_fa.arb`), Vazirmatn font bundled, Shamsi calendar support active in transactions and flight search. Dynamic font switching enabled.
- [x] **L-02 (International Locales):** Arabic, English, Russian, Turkish, and Chinese localizations compiled and verified.
- [x] **L-03 (Financial Data Masking):** 16-digit bank cards masked (`6037-99**-****-1234`), Iranian Sheba validated. Virtual card physical layout LTR-isolated under RTL parents.

---

## 4. Release Deployment & Rollback Protocol

1. **Tag Trigger:** Releases are produced exclusively via signed Git tags (e.g., `v1.0.172`, `v1.0.171`) running on GitHub Actions (`.github/workflows/flutter.yml`).
2. **Mirroring:** Build artifacts are automatically mirrored to the public release repository `ecardo-apps-releases`.
3. **In-App Update:** In-app force/flexible update gate (`AppUpdateController`) is notified via backend API.
4. **Platform Status:**
   - Android: 🟢 **READY FOR RELEASE VERIFICATION (Staging Verified)**
   - iOS: 🔴 **BLOCKED (Awaiting Apple Team ID & Provisioning)**
5. **Rollback Plan:**
   - If an unexpected regression occurs in production, the minimum supported version in the server API configuration is immediately reverted, directing users to the previous stable release or displaying the maintenance screen (`/maintenance_mode_route`). Full runbook documented in `docs/CURRENT_RELEASE.md` and `docs/audit/RELEASE_EVIDENCE.md`.
