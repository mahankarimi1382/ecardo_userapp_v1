# eCardo User App (v1) — Production Release Verification Checklist

**Document Version:** 1.0.170  
**Date:** 2026-10-15  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa.md` — Section 4 (Phase 9) & Section 9  
**Inspected Commit SHA:** `5a4abe64aba7d156ae1b92c1a84a31783c96cb65` (`5a4abe6`, ahead of remote `de37b1e` by 1 commit)  
**Target Release Version:** `1.0.170+170` (in `pubspec.yaml`)  
**Evidence Dossier:** `docs/audit/RELEASE_EVIDENCE.md`  

---

## 1. P0 Hard Release Gates (Must Pass Before Any Tag/Release)

- [x] **G-01 (Release Signing):** `android/app/build.gradle.kts:44-59` configuration-time check fails closed if `key.properties` is missing. Release build is signed using V1 + V2 + V3 schemes with dedicated release key from GitHub Secrets (`SIGNING_KEYSTORE_BASE64`). No release secrets or keystores committed to Git.
- [x] **G-02 (Secure Token Storage):** `TokenService` stores bearer tokens exclusively in `FlutterSecureStorage` (Android Keystore / iOS Keychain) with `isReady` future gate and fail-closed handling on write failure. Legacy SharedPreferences tokens are automatically migrated and erased.
- [x] **G-03 (Plaintext Password Pruning):** Legacy password retrieval fallback in `splash_controller.dart` and `biometricPassword` in `sign_in_controller.dart` are completely removed. Zero code paths ever touch or store a password for biometric unlock; bearer tokens exclusively manage session unlock.
- [x] **G-04 (App Lock & Screen Obscuring):** Native Android `FLAG_SECURE` in `MainActivity.kt` obscures screen and prevents OS-level screen capture. `AppLockService` enforces salted SHA-256 PIN authentication with unique salts, failed attempt counter, and inactivity timeout on resume.
- [x] **G-05 (Network Security & SSL Pinning):** `usesCleartextTraffic="false"` verified in `AndroidManifest.xml`. `network_security_config.xml` blocks user CAs for `ecardo.ir`. Dual-slot SSL cert pin (`ECARDO_CERT_PIN` & `ECARDO_CERT_PIN_BACKUP`) verified against live host in CI with fail-closed runtime checks.
- [x] **G-06 (Financial Idempotency):** In-flight `Idempotency-Key` registry covers all 23 financial POST endpoints (`NetworkService`). Features 5-minute TTL, bounded FIFO capacity (50 entries), and retains keys across transport timeouts (connection, send, receive timeouts, SocketException) to prevent double debits. Comprehensive recursive PII/secret redaction active. Client-side buttons lock on submit.
- [x] **G-07 (Code Quality & Tests):** `flutter analyze` reports zero errors (`No issues found!`, 0 errors, 0 warnings). `flutter test` executes with 100% pass rate (`00:54 +682: All tests passed!`, 682 tests passing across all workstreams and baseline).
- [x] **G-08 (Firebase Config Sync):** `firebase.json` project ID synchronized from legacy `qunzo-b2252` to match production `ecardo-app` declared in `firebase_options.dart` and real app IDs across Android and iOS.

---

## 2. Build & Packaging Requirements

- [x] **B-01 (ABI Split Packaging):** CI builds split-per-ABI APKs (`armeabi-v7a`, `arm64-v8a`, `x86_64`) via `flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64,android-x64` to maintain lean download sizes.
- [x] **B-02 (Code Shrinking & ProGuard):** R8 shrinking and resource stripping enabled in `android/app/build.gradle.kts:147-152` with active rules in `proguard-rules.pro`. Dart obfuscation flags active in CI (`--obfuscate --split-debug-info=build/symbols`).
- [x] **B-03 (Desugaring):** Java 11 desugaring enabled with `desugar_jdk_libs:2.1.4`.
- [x] **B-04 (App Identification):** `applicationId` and `namespace` set to `com.ecardo.user`. App label is `eCardo`.

---

## 3. Localization & Regional Readiness Gate

- [x] **L-01 (Persian RTL & Shamsi):** Full Persian ARB coverage (`app_fa.arb`), Vazirmatn font bundled, Shamsi calendar support active in transactions and flight search. Dynamic font switching enabled.
- [x] **L-02 (International Locales):** Arabic, English, Russian, Turkish, and Chinese localizations compiled and verified.
- [x] **L-03 (Financial Data Masking):** 16-digit bank cards masked (`6037-99**-****-1234`), Iranian Sheba validated. Virtual card physical layout LTR-isolated under RTL parents.

---

## 4. Release Deployment & Rollback Protocol

1. **Tag Trigger:** Releases are produced exclusively via signed Git tags (e.g., `v1.0.170`) running on GitHub Actions (`.github/workflows/flutter.yml`).
2. **Mirroring:** Build artifacts are automatically mirrored to the public release repository `ecardo-apps-releases`.
3. **In-App Update:** In-app force/flexible update gate (`AppUpdateController`) is notified via backend API.
4. **Platform Status:**
   - Android: 🟢 **READY FOR RELEASE VERIFICATION (Staging Verified)**
   - iOS: 🔴 **BLOCKED (Awaiting Apple Team ID & Provisioning)**
5. **Rollback Plan:**
   - If an unexpected regression occurs in production, the minimum supported version in the server API configuration is immediately reverted, directing users to the previous stable release or displaying the maintenance screen (`/maintenance_mode_route`). Full runbook documented in `docs/audit/RELEASE_EVIDENCE.md`.
