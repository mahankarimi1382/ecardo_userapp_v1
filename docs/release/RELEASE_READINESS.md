# eCardo User App (v1) — Production Release Readiness Dossier

**Document Version:** 1.0.173  
**Assessment Date:** 2026-10-18  
**Canonical Release Line:** `v1.0.173+173`  
**Target Repository:** `mahankarimi1382/ecardo_userapp_v1`  
**Active Git Branch:** `main`  
**Local HEAD Commit SHA:** `d47dae08d28cfc613ad480006a6b09c4e3bdffd9` (`d47dae0`)  
**Remote origin/main SHA:** `c132c17c8ac1518599c76951f476bd05b6ffe44a` (`c132c17`)  
**Tracking Status:** 3 commits ahead of `origin/main` (retained locally per No Unapproved GitHub Updates rule)  
**Declared Version:** `1.0.173+173` (`pubspec.yaml`)  
**Release Governance Lead:** Release Governance, Enterprise Architecture & QA Lead Team  

---

## 1. Executive Platform Readiness Summary

The release readiness of `ecardo_userapp_v1` for release line `v1.0.173+173` has been assessed against the 15 formal release gates defined in `04_RELEASE_GATES.md` and `09_RELEASE_QA_SLO_FA.md`.

```
                      ┌───────────────────────────────────────────────┐
                      │        eCardo User App Client (v1)            │
                      │   Active Release Line: v1.0.173+173 (d47dae0) │
                      │   Preceding Tag Build: v1.0.172+172 (98e8993) │
                      └───────────────────────┬───────────────────────┘
                                              │
                      ┌───────────────────────┴───────────────────────┐
                      │                                               │
                      ▼                                               ▼
         ┌─────────────────────────┐                     ┌─────────────────────────┐
         │     Android Platform    │                     │       iOS Platform      │
         ├─────────────────────────┤                     ├─────────────────────────┤
         │ Status: 🟢 READY        │                     │ Status: 🔴 BLOCKED      │
         │ - Universal FAT APK     │                     │ - Apple Team ID missing │
         │ - R8 -dontoptimize fix  │                     │ - Provisioning missing  │
         │ - Passcode loop fix     │                     │ - Distribution certs    │
         │ - Fail-closed signing   │                     │   unconfigured          │
         │ - 728 tests passing     │                     │ - Code ready, certs     │
         │ - 0 analyzer issues     │                     │   gate pending          │
         └─────────────────────────┘                     └─────────────────────────┘
```

### Platform Gate Summary Table
| Platform | Target Artifact | Release Readiness Verdict | Primary Conditions / Blockers |
| :--- | :--- | :--- | :--- |
| **Android** | Universal FAT APK (`app-release.apk`) | 🟢 **READY FOR RELEASE / STAGING** | Universal FAT APK containing all ABIs (`android-arm,android-arm64,android-x64`); R8 `-dontoptimize` ProGuard fix active; fail-closed signing configured; 728 green tests; 0 analyzer issues. Production publish gated on explicit user consent. |
| **iOS** | Xcode Archive / IPA | 🔴 **BLOCKED** | Hard blocked pending organizational acquisition of Apple Developer credentials (Team ID, Distribution Certificate, App Store / Ad-Hoc Provisioning Profiles). |
| **Web** | Web Release Bundle | 🟡 **READY FOR STAGING** | Web compilation and asset pipeline verified; pending staging domain validation and browser storage review. |

---

## 2. Comprehensive 15-Gate Release Matrix (G-01 through G-15)

| Gate ID | Gate Name | Required Acceptance Criteria | Verified Current Codebase Evidence | Verdict |
| :--- | :--- | :--- | :--- | :--- |
| **G-01** | **Source Integrity & Governance** | Exact tag and commit SHA verified; clean working tree or strictly governed uncommitted modifications; branch aligned. | Local HEAD `d47dae0`, branch `main`, 3 commits ahead of `origin/main` (`c132c17`), retained locally per No Unapproved GitHub Updates rule. Working tree modifications in financial controllers tracked. | **PASS (GOVERNED)** |
| **G-02** | **Static Quality & Formatting** | `flutter analyze` reports zero errors and zero warnings; dart format compliance. | `flutter analyze` executed: **No issues found!** (0 errors, 0 warnings, ran in 8.0s). Code conforms to lint rules. | **PASS** |
| **G-03** | **Automated Test Suite** | Exact test count verified; 100% green; zero failures; zero unauthorized skips. | `flutter test` executed: **728 tests passed!** (0 failures, 0 skipped, 100% green, ran in 59s). Documented in `docs/qa/TEST_EVIDENCE.md`. | **PASS** |
| **G-04** | **Financial Core Safety** | Idempotency keys across all financial mutations; double-tap submit guards; key retention on 5xx/timeouts. | Dual header injection (`Idempotency-Key` and `X-Idempotency-Key`) across 23 endpoints; RFC 8785 canonical JSON SHA-256 fingerprinting; 5-min TTL; key retained on 5xx/timeout. | **PASS** |
| **G-05** | **Credential & Session Management** | Bearer tokens stored in secure hardware storage; zero plaintext passwords in storage; app lock on backgrounding. | `TokenService` uses `FlutterSecureStorage` (Android Keystore / iOS Keychain); legacy password retrieval in `splash_controller.dart` eliminated; `AppLockService` enforces salted SHA-256 PIN. | **PASS** |
| **G-06** | **Offline Queue Security** | Strict path/method allowlist; recursive PII scanning; 24h TTL; Dead-Letter Queue (DLQ). | 18 test blocks in `offline_request_queue_test.dart` passing; 21 sensitive keys blocked recursively; financial mutations prevented from offline storage. | **PASS** |
| **G-07** | **API Contract & Passcode Resilience** | Passcode prompt step-up recovery; infinite loop prevention invariant; typed error codes. | `PasscodeHelper.isPasscodeRequired(..., wasPasscodeProvided: true) == false` invariant verified in `test/passcode_resilience_state_machine_test.dart`; step-up fallback active across all 7 money flows. | **PASS** |
| **G-08** | **Android Signing & Packaging** | Release APK signed with dedicated production key (V1/V2/V3); fail-closed configuration; R8 Kotlin keep rules. | Fail-closed signing in `build.gradle.kts`; Universal FAT release APK (`android-arm,android-arm64,android-x64`); R8 `-dontoptimize` in `proguard-rules.pro` eliminating Kotlin Result class stripping. | **PASS** |
| **G-09** | **iOS Signing & Packaging** | macOS signed archive; valid provisioning profile; push notification entitlements; privacy manifest. | Codebase is fully compatible; build pipeline is **BLOCKED** awaiting Apple Developer Team ID, Distribution Certificates, and Provisioning Profiles. | 🔴 **BLOCKED** |
| **G-10** | **Web Platform Delivery** | Clean web build; CORS configuration; secure local storage; responsive viewport rendering. | Web build script configured in `.github/workflows/web.yml`; verified on staging; production deployment pending domain signoff. | 🟡 **READY FOR STAGING** |
| **G-11** | **Supply Chain & Dependencies** | All GitHub Actions pinned to immutable SHAs; workflow permissions follow least privilege; dependencies audited. | Build job uses `permissions: contents: read`; action SHAs pinned in `.github/workflows/flutter.yml`; zero unapproved packages. | **PASS** |
| **G-12** | **Observability & PII Redaction** | Structured logging without credential leaks; case-insensitive redaction of PII keys; graceful degradation. | Workstream B redaction active across snake_case, camelCase, and kebab-case; zero authorization tokens or response bodies leaked in Dio error logs. | **PASS** |
| **G-13** | **Release Documentation** | Canonical release pointer matches `pubspec.yaml`, tag, SHA, artifact checksum, and QA reports. | `CURRENT_RELEASE.md`, `BASELINE.md`, `COMPETITOR_GAP_ANALYSIS.md`, `TEST_EVIDENCE.md`, and `RELEASE_READINESS.md` fully synchronized and verified via `verify_release_metadata.py`. | **PASS** |
| **G-14** | **Rollback Protocol** | Immediate rollback procedure documented; server-driven minimum version enforcement; maintenance mode fallback. | Server-side min-version killswitch (`/api/app-update/status`) and maintenance screen (`/maintenance_mode_route`) operational; rollback runbook defined. | **PASS** |
| **G-15** | **Human Governance & Approval** | Explicit human sign-off required prior to remote repository push or production artifact distribution. | Strictly enforced per No Unapproved GitHub Updates rule (`MEMORY.md`). All commits and changes retained locally until explicit user authorization. | **PASS** |

---

## 3. Detailed Technical Assessment of P0 Pillars

### 3.1 Passcode Resilience State Machine (G-07)
A previous resilience concern in automated financial operations was the possibility of prompt/retry loops when backend services return HTTP 422 with passcode messages after the user already provided a transaction PIN.

The state machine implemented in `PasscodeHelper` and validated in `test/passcode_resilience_state_machine_test.dart` guarantees the following:
```
                               ┌───────────────────────────┐
                               │ Financial Mutation Dispatched│
                               └─────────────┬─────────────┘
                                             │
                                             ▼
                               ┌───────────────────────────┐
                               │ Server Returns HTTP 422?  │
                               └─────────────┬─────────────┘
                                             │
                      ┌──────────────────────┴──────────────────────┐
                      ▼                                             ▼
        [wasPasscodeProvided == false]                [wasPasscodeProvided == true]
                      │                                             │
                      ▼                                             ▼
       ┌─────────────────────────────┐               ┌─────────────────────────────┐
       │ isPasscodeRequired == true  │               │ isPasscodeRequired == false │
       │ Open Passcode BottomSheet   │               │ HARD BRAKE: NO RETRY LOOP   │
       │ Prompt User for PIN         │               │ Surface Error Directly      │
       └─────────────────────────────┘               └─────────────────────────────┘
```
This hard brake terminates the recovery flow immediately if the passcode was already provided, eliminating infinite prompt loops.

### 3.2 Android Universal FAT APK & R8 Optimization Fix (G-08)
- **Universal FAT APK:** The release build generates a single universal APK supporting `android-arm`, `android-arm64`, and `android-x64` ABIs, guaranteeing runtime execution on legacy ARMv7 devices, modern 64-bit phones, and x86_64 emulator environments.
- **R8 `-dontoptimize` Fix:** ProGuard configuration in `android/app/proguard-rules.pro` applies `-dontoptimize` and explicitly preserves `kotlin.**` and `kotlin.coroutines.Continuation`. This resolves the `ClassNotFoundException: kotlin/Result` crash encountered on Android 14+ release builds when R8's optimizer strips Kotlin standard library metadata.

### 3.3 iOS Credential Blocker (G-09)
The iOS application build remains **BLOCKED** on administrative credential provisioning:
1. **Apple Developer Team ID:** Missing from organization configuration.
2. **Distribution Certificate:** Missing private key and `.p12` distribution certificate in CI secrets.
3. **Provisioning Profiles:** App Store and Ad-Hoc provisioning profiles (`com.ecardo.user`) unconfigured.
4. **Resolution Path:** Upon receipt of Apple Developer credentials from organization administration, configure `APPLE_CERTIFICATE_BASE64`, `APPLE_CERTIFICATE_PASSWORD`, and `PROVISIONING_PROFILE_BASE64` in GitHub Secrets.

---

## 4. Rollback Protocol & Operational Runbook

In the event of an unforeseen regression in production:

1. **Immediate Server-Driven Killswitch:**
   - The backend `/api/user/app-update` endpoint maintains the minimum supported client version (`min_version: "1.0.173"`).
   - If an issue is identified, the backend configuration is updated to set `min_version` to the previous stable release, or `maintenance_mode: true`.
   - The app's `AppUpdateController` and `SplashController` intercept this payload and route all users to `/maintenance_mode_route` or `/app_update_route`, preventing any further financial mutations.
2. **Financial Mutation Reconciliation:**
   - Transactions in `pending` or `reconciling` states are handled by scheduled backend reconciliation workers. Client-side rollbacks never replay mutations without server state inquiry.
3. **Artifact Rollback:**
   - The preceding verified release build (`v1.0.172+172`, commit `98e8993`) remains archived and deployable from the release repository.

---

## 5. Release Governance Final Verdict

- **Android Platform:** 🟢 **APPROVED FOR RELEASE VERIFICATION & STAGING**
- **iOS Platform:** 🔴 **BLOCKED AWAITING APPLE DEVELOPER CREDENTIALS**
- **Web Platform:** 🟡 **APPROVED FOR STAGING**
- **Release Version:** **1.0.173+173**
- **Local HEAD Commit:** **`d47dae08d28cfc613ad480006a6b09c4e3bdffd9`**
- **GitHub Policy:** **No Unapproved GitHub Updates enforced; all changes retained locally.**
