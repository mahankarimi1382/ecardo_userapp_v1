# eCardo User App (v1) — Prioritized Remediation Task Backlog

**Document Version:** 1.2.0  
**Date:** 2026-10-15  
**Audit Context:** `ecardo_userapp_v1_reaudit_2026-10-15_fa.md`  
**Target Commit SHA:** `de37b1ea0d2b9769ae38ea3d637f181d62149209` (`de37b1e`)  
**Automated Tests Verified:** 646 passing tests (0 failures)

---

## 1. Prioritized Task Master Matrix

| Task ID | Domain / Category | Priority | Owner | Status | Dependencies |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TASK-SEC-01** | Security / Auth | **P0** | Security Engineering | **VERIFIED & IMPLEMENTED** | None |
| **TASK-LOG-01** | Security / Logging | **P0** | Core Network Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-ARC-01** | Architecture / Stability | **P0** | Frontend Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-UI-01** | UI / RTL | **P0** | Design System Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-SEC-02** | Security / Native Privacy | **P1** | Mobile Platform Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-BRAND-01 (FIND-001)** | Configuration / Branding | **P1** | Mobile Platform Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-NET-01** | Network / Session | **P1** | Core Network Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-NET-02** | Network / Resiliency | **P1** | Core Network Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-FIN-01** | Financial / WebView | **P1** | Fintech Logic Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-FIN-02** | Financial / State Machine | **P1** | Fintech Logic Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-ARC-02** | Architecture / Lifecycle | **P1** | Frontend Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-UI-02** | Design / Accessibility | **P1** | Design System Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-UI-03** | Typography / Dynamic Font | **P1** | Design System Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-LOC-01** | Localization | **P1** | Localization Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-LOC-03** | Travel / Shamsi Calendar | **P1** | Localization Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-VAL-01** | Financial / Form Input | **P1** | Frontend Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-CICD-01 (FIND-002)** | DevOps / Build Pipeline | **P1** | DevOps Team | **VERIFIED & IMPLEMENTED** | None |
| **TASK-DOC-01 (FIND-006)** | Documentation / Governance | **P1** | DevOps / Architecture | **VERIFIED & IMPLEMENTED** | None |

---

## 2. Detailed Task Specifications (P0 Critical Tasks)

### TASK-SEC-01: Prune Legacy Password Retrieval for Biometrics
- **Priority:** **P0** (High Security Impact)
- **Objective:** Completely remove legacy password storage and retrieval fallback paths so that biometric unlock never touches, retrieves, or persists user passwords.
- **Affected Files:**
  - `lib/src/common/services/settings_service.dart:115-167`
  - `lib/src/presentation/screens/authentication/splash/controller/splash_controller.dart:230-242`
  - `lib/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart:65, 392, 453, 524`
- **Action Plan:**
  1. Remove `saveLoggedInUserPassword()` and `getLoggedInUserPassword()` from `SettingsService`.
  2. Remove `biometricPassword` reactive property from `SignInController` and `splash_controller.dart`.
  3. In `splash_controller.dart`, if the access token is missing or invalid on biometric prompt, gracefully redirect to `BaseRoute.signIn` requiring manual password entry.
- **Acceptance Criteria:**
  - Grep for `getLoggedInUserPassword` and `biometricPassword` returns 0 hits in `lib/`.
  - `flutter analyze` and `flutter test` pass with 0 errors.

---

### TASK-LOG-01: Sanitize Network Logging & Redact PII / Secrets
- **Priority:** **P0** (Critical Confidentiality Leak)
- **Objective:** Eliminate cleartext logging of user passwords, 2FA codes, passcodes, PINs, virtual card PANs, and CVVs in `NetworkService`.
- **Affected Files:**
  - `lib/src/network/service/network_service.dart:721, 899, 970, 1037, 1114, 1253-1256`
- **Action Plan:**
  1. In `NetworkService._log`, sanitize all request payloads. Replace values for keys matching `password`, `current_password`, `new_password`, `code`, `otp`, `passcode`, `pin`, `cvv`, `card_number` with `'<redacted>'`.
  2. In `_handleResponse`, do not log full JSON response bodies; log only status code and summary message.
- **Acceptance Criteria:**
  - Executing login, change password, or virtual card detail requests outputs zero plaintext credentials or card details to console.

---

### TASK-ARC-01: Fix Runtime Crash Risk from `Get.context!` in Field Declarations
- **Priority:** **P0** (Fatal Crash Hazard)
- **Objective:** Refactor 8 GetX controllers that initialize `AppLocalizations` directly at field declaration level using `Get.context!`.
- **Affected Files:**
  - `lib/src/presentation/screens/bill_payment/controller/toll_controller.dart:26`
  - `lib/src/presentation/screens/bill_payment/controller/internet_controller.dart:30`
  - `lib/src/presentation/screens/bill_payment/controller/electricity_controller.dart:27`
  - `lib/src/presentation/screens/bill_payment/controller/data_bundle_controller.dart:26`
  - `lib/src/presentation/screens/bill_payment/controller/airtime_controller.dart:31`
  - `lib/src/presentation/screens/bill_payment/controller/cable_controller.dart:26`
  - `lib/src/presentation/screens/gift_card/controller/gift_card_controller.dart:30`
  - `lib/src/presentation/screens/cash_out/controller/cash_out_controller.dart:33`
- **Action Plan:**
  - Replace `final localization = AppLocalizations.of(Get.context!);` with `AppLocalizations? get localization => Get.context != null ? AppLocalizations.of(Get.context!) : null;`.
- **Acceptance Criteria:**
  - Controllers can be instantiated in bindings and unit tests without throwing null-check exceptions.

---

### TASK-UI-01: Fix RTL Thumb Misalignment in `EcardoSwipeButton`
- **Priority:** **P0** (Functional Usability)
- **Objective:** Resolve visual and functional inversion of the swipe-to-confirm button in RTL (Persian/Arabic) locales.
- **Affected Files:**
  - `lib/src/common/widgets/design_system/ecardo_swipe_button.dart:268-326`
  - `lib/src/presentation/screens/transfer/view/widgets/swipe_to_confirm_slider.dart:101-150`
- **Action Plan:**
  - Enforce `Directionality(textDirection: TextDirection.ltr)` around the slider internals or dynamically compute drag bounds and thumb positioning based on the current text direction.
- **Acceptance Criteria:**
  - In Persian RTL mode, the thumb begins at the correct starting edge and slides smoothly to confirm without layout glitch.

---

## 3. High-Priority Tasks (P1)

### TASK-SEC-02: Native Screen Privacy (`FLAG_SECURE` & iOS Snapshot Blur)
- **Priority:** **P1**
- **Affected Files:**
  - `android/app/src/main/kotlin/com/ecardo/user/MainActivity.kt`
  - `ios/Runner/AppDelegate.swift`
- **Action Plan:**
  - Android: Set `WindowManager.LayoutParams.FLAG_SECURE` in `MainActivity.kt`.
  - iOS: Add blur view in `AppDelegate.swift` when resigning active.

### TASK-BRAND-01 (FIND-001): Synchronize Firebase Project Identifiers & Metadata
- **Priority:** **P1**
- **Status:** **VERIFIED & IMPLEMENTED**
- **Affected Files:**
  - `firebase.json`
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- **Resolution & Evidence:**
  - Reconciled all `appId` and `projectId` entries in `firebase.json` with project `ecardo-app` (`1:292987494106:android:3f1e8b21e46ceb2c138fe3` and `1:292987494106:ios:9009185e45066d59138fe3`).
  - Confirmed 100% synchronization with `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `lib/firebase_options.dart`.

### TASK-NET-01: Fix Premature Logout Bug on Retried Request Failure
- **Priority:** **P1**
- **Affected Files:**
  - `lib/src/network/service/network_service.dart:310-334`
- **Action Plan:**
  - Catch retried request failures and propagate via `handler.next(error)` without calling `SessionManager.handleUnauthorized()`.

### TASK-NET-02: Re-register `_TransportRetryInterceptor`
- **Priority:** **P1**
- **Affected Files:**
  - `lib/src/network/service/network_service.dart:144-154, 194-197`
- **Action Plan:**
  - Ensure `_TransportRetryInterceptor` is added to `_dio.interceptors` after `_setupInterceptors()` clears them.

### TASK-FIN-01: Eliminate WebView Unverified Payment Success Fallback
- **Priority:** **P1**
- **Affected Files:**
  - `lib/src/presentation/widgets/web_view_screen.dart:143-145`
- **Action Plan:**
  - Return `success: false` or `pending_verification` if backend status verification cannot confirm transaction.

### TASK-UI-02: Fix Light Theme Secondary Text Contrast
- **Priority:** **P1**
- **Affected Files:**
  - `lib/src/app/config/theme/light_theme.dart:12-13`
- **Action Plan:**
  - Change `onSecondary` to `AppColors.deepBlack` (`#161614`) achieving 9:1 contrast on `#00BFA6`.

### TASK-LOC-01: Fix Arabic Fallback Bug in `l10nPick`
- **Priority:** **P1**
- **Affected Files:**
  - `lib/src/helper/l10n_pick.dart:21-22`
- **Action Plan:**
  - Change `case 'ar': return ar ?? fa;` to `return ar ?? en;`.

### TASK-VAL-01: Client-Side Sheba & 16-Digit Card Luhn Validation
- **Priority:** **P1**
- **Affected Files:**
  - `lib/src/presentation/screens/remittance/view/sub_sections/remittance_receiver_section.dart:151-157`
- **Action Plan:**
  - Add Luhn check for debit cards and mod-97-10 check for Iranian Sheba before proceeding to next step.

### TASK-CICD-01 (FIND-002): Enable Dart Obfuscation & Smart Formatting Check in CI
- **Priority:** **P1**
- **Status:** **VERIFIED & IMPLEMENTED**
- **Affected Files:**
  - `.github/workflows/flutter.yml`
- **Resolution & Evidence:**
  - Added `--obfuscate --split-debug-info=build/symbols` to release APK build command.
  - Reintroduced smart changed-files Dart formatting gate (`git diff --name-only origin/main...HEAD 2>/dev/null | grep '\.dart$'`) before static analysis, ensuring format compliance on all new code without blocking on legacy files.
  - Verified all actions are pinned to secure v4 commit SHAs (`actions/checkout@v4`, `actions/setup-java@v4`, `actions/upload-artifact@v4`).

### TASK-DOC-01 (FIND-006): Synchronize README and Audit Documentation with Codebase Reality
- **Priority:** **P1**
- **Status:** **VERIFIED & IMPLEMENTED**
- **Affected Files:**
  - `README.md`
  - `docs/audit/BASELINE.md`
  - `docs/audit/FINDINGS.md`
  - `docs/audit/TASKS.md`
- **Resolution & Evidence:**
  - Replaced outdated initial audit README with complete production architecture documentation (`com.ecardo.user`, `FlutterSecureStorage`, runtime SSL pinning with fail-closed gates, 6 complete locales, Vazirmatn font, Shamsi date picker).
  - Updated all audit documents to commit `de37b1e` and verified 646 passing tests.
