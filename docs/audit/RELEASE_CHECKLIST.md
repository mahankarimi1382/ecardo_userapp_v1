# eCardo User App (v1) — Production Release Verification Checklist

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa.md` — Section 4 (Phase 9) & Section 9  
**Inspected Commit SHA:** `d56ab71d293ca1c7ec29b63863ecbc40ca9c8d67`

---

## 1. P0 Hard Release Gates (Must Pass Before Any Tag/Release)

- [x] **G-01 (Release Signing):** `android/app/build.gradle.kts` configuration-time check fails closed if `key.properties` is missing. Release build is signed using V1 + V2 + V3 schemes with dedicated release key from GitHub Secrets (`SIGNING_KEYSTORE_BASE64`). No release secrets or keystores committed to Git.
- [x] **G-02 (Secure Token Storage):** `TokenService` stores bearer tokens exclusively in `FlutterSecureStorage` (Android Keystore / iOS Keychain). Legacy SharedPreferences tokens are automatically migrated and erased.
- [ ] **G-03 (Plaintext Password Pruning):** Legacy password retrieval fallback in `splash_controller.dart:231` (`getLoggedInUserPassword()`) and `biometricPassword` in `sign_in_controller.dart` must be completely removed so zero code paths ever touch or store a password for biometric unlock.
- [x] **G-04 (App Lock & Screen Obscuring):** `AppLockService` enforces inactivity timeout on resume. Screen privacy mode obscures account balances when the app is backgrounded.
- [x] **G-05 (Network Security & SSL Pinning):** `usesCleartextTraffic="false"` verified in `AndroidManifest.xml`. `network_security_config.xml` blocks user CAs for `ecardo.ir`. SSL cert pin verified against live host in CI.
- [x] **G-06 (Financial Idempotency):** In-flight `Idempotency-Key` registry covers all 23 financial POST endpoints (`NetworkService:46-74`). Client-side buttons lock on submit.
- [x] **G-07 (Code Quality & Tests):** `flutter analyze` reports zero errors. `flutter test` executes with 100% pass rate (current baseline: 613 tests).
- [ ] **G-08 (Firebase Config Sync):** Update `firebase.json` project ID from legacy `qunzo-b2252` to match `ecardo-app` declared in `firebase_options.dart`.

---

## 2. Build & Packaging Requirements

- [x] **B-01 (ABI Split Packaging):** CI builds split-per-ABI APKs (`armeabi-v7a`, `arm64-v8a`, `x86_64`) via `flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64,android-x64` to maintain lean download sizes.
- [x] **B-02 (Code Shrinking & ProGuard):** R8 shrinking and resource stripping enabled in `android/app/build.gradle.kts:147-152`.
- [x] **B-03 (Desugaring):** Java 11 desugaring enabled with `desugar_jdk_libs:2.1.4`.
- [x] **B-04 (App Identification):** `applicationId` and `namespace` set to `com.ecardo.user`. App label is `eCardo`.

---

## 3. Localization & Regional Readiness Gate

- [x] **L-01 (Persian RTL & Shamsi):** Full Persian ARB coverage (`app_fa.arb`), Vazirmatn font bundled, Shamsi calendar support active in transactions and flight search.
- [x] **L-02 (International Locales):** Arabic, English, Russian, Turkish, and Chinese localizations compiled and verified.
- [x] **L-03 (Financial Data Masking):** 16-digit bank cards masked (`6037-99**-****-1234`), Iranian Sheba validated.

---

## 4. Release Deployment & Rollback Protocol

1. **Tag Trigger:** Releases are produced exclusively via signed Git tags (e.g., `v1.0.167`) running on GitHub Actions (`.github/workflows/flutter.yml`).
2. **Mirroring:** Build artifacts are automatically mirrored to the public release repository `ecardo-apps-releases`.
3. **In-App Update:** In-app force/flexible update gate (`AppUpdateController`) is notified via backend API.
4. **Rollback Plan:**
   - If an unexpected regression occurs in production, the minimum supported version in the server API configuration is immediately reverted, directing users to the previous stable release or displaying the maintenance screen (`/maintenance_mode_route`).
