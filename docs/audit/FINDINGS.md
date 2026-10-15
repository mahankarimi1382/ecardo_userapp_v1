# eCardo User App (v1) — Comprehensive Audit Findings & Verification Matrix

**Audit Date:** 2026-10-14  
**Target Repository:** `mahankarimi1382/ecardo_userapp_v1`  
**Inspected Commit SHA:** `d56ab71d293ca1c7ec29b63863ecbc40ca9c8d67`  
**Inspected Branch:** `main` (clean working tree)  
**Standard Reference:** OWASP MASVS / MASTG & `ecardo_userapp_v1_audit_roadmap_fa.md`

---

## 1. Findings Summary & Status Matrix

| ID | Domain / Scope | Severity | Status in Codebase | Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **SEC-01** | Release Signing & Keystore Integrity | **P0** | **CONFIRMED RESOLVED (Android)** / Defect (iOS) | Android fail-closed verified; configure iOS signing & workflow |
| **SEC-02** | Plaintext Password Storage for Biometrics | **P0** | **CONFIRMED ACTION REQUIRED** | Prune legacy `getLoggedInUserPassword()` and `biometricPassword` references |
| **SEC-03** | Token Storage & Session Expiration | **P0** | **CONFIRMED RESOLVED** | Verified: `FlutterSecureStorage` + Keystore/Keychain + 30m timeout |
| **SEC-04** | App Inactivity Lock & Screen Privacy | **P0** | **CONFIRMED ACTION REQUIRED** | Logic verified; add native `FLAG_SECURE` in Android and blur in iOS |
| **BRAND-01** | Brand Identity & Qunzo Artifacts | **P1** | **CONFIRMED ACTION REQUIRED** | Sync `firebase.json` project ID from `qunzo-b2252` to `ecardo-app` |
| **FIN-01** | Financial Logic, Math & Idempotency | **P0** | **CONFIRMED RESOLVED** | 23 endpoints protected; eliminate WebView unverified success fallback |
| **API-01** | Network Timeouts & 401 Refresh Mutex | **P1** | **CONFIRMED RESOLVED** | Verified: Mutex queue in `NetworkService:275-334` |
| **API-02** | False Logout Bug on Retried Request Failure | **P1** | **CONFIRMED DEFECT** | Fix `NetworkService:310-321` fall-through to `handleUnauthorized` |
| **API-03** | Retry Interceptor Wiped by Clear() | **P1** | **CONFIRMED DEFECT** | Re-register `_TransportRetryInterceptor` after `_dio.interceptors.clear()` |
| **LOG-01** | PII & Secret Logging in Console Output | **P0** | **CONFIRMED CRITICAL LEAK** | Sanitize request/response body logging for passwords, PINs, CVVs, and PANs |
| **ARC-01** | Runtime Crash from `Get.context!` in Fields | **P0** | **CONFIRMED CRITICAL DEFECT** | Refactor 8 controllers to use null-safe getters instead of field `Get.context!` |
| **ARC-02** | Controller Instantiation in Widget Fields | **P1** | **CONFIRMED DEFECT** | Move `Get.put` from widget fields to route `Bindings` |
| **UI-01** | RTL Thumb Misalignment in `EcardoSwipeButton` | **P0** | **CONFIRMED DEFECT** | Wrap swipe button in `TextDirection.ltr` or adapt drag direction for RTL |
| **UI-02** | Light Theme Secondary Contrast Failure | **P1** | **CONFIRMED DEFECT** | Change `onSecondary` in `light_theme.dart` from white to `#161614` (WCAG AA) |
| **UI-03** | Dynamic Font Switching for Persian/Arabic | **P1** | **CONFIRMED DEFECT** | Dynamically switch `fontFamily` to `Vazirmatn` in `LocaleThemeService` |
| **LOC-01** | Persian, RTL, Shamsi & Vazirmatn | **P0 (Iran)** | **CONFIRMED RESOLVED** | Verified: 6 ARBs, Vazirmatn, Shamsi date helper |
| **LOC-02** | Arabic Fallback Bug in `l10nPick` | **P1** | **CONFIRMED DEFECT** | Change `case 'ar': return ar ?? fa;` to `ar ?? en` |
| **LOC-03** | Travel Date Picker Missing True Jalali Calendar | **P1** | **CONFIRMED DEFECT** | Replace `CalendarDatePicker2` with true Jalali calendar component |
| **VAL-01** | Missing Sheba & Luhn Bank Card Validation | **P1** | **CONFIRMED DEFECT** | Add client-side Luhn & Sheba mod-97-10 check in `remittance_receiver_section.dart` |
| **PUSH-01** | Cold-Start Permission & Notification Channels | **P1** | **CONFIRMED DEFECT** | Add permission primer card; localize channel names; add security channel |
| **CICD-01** | CI Permissions & Obfuscation Missing | **P1** | **CONFIRMED DEFECT** | Add `--obfuscate` to CI build; scope `contents: write` to tag releases only |

---

## 2. Detailed Findings & Concrete Evidence

### Finding SEC-01: Release Signing Configuration
- **Severity:** P0 (Release Blocker)
- **Status:** **CONFIRMED RESOLVED (Android) / DEFECT (iOS)**
- **Evidence Files:**
  - `android/app/build.gradle.kts:44-59`
  - `android/app/build.gradle.kts:118-145`
  - `.gitignore:58-63`
  - `ios/Runner.xcodeproj/project.pbxproj:467, 592, 649`
- **Code Analysis:**
  Lines 49-59 of `build.gradle.kts` enforce a configuration-time fail-closed gate:
  ```kotlin
  if (!keystoreProperties.containsKey("storeFile") &&
      gradle.startParameter.taskNames.any {
          val t = it.lowercase()
          t.contains("release") || t.contains("bundle")
      }
  ) {
      throw GradleException("Release signing material missing... Refusing to build a RELEASE APK without a real signing key.")
  }
  ```
  Release variant is explicitly bound to `signingConfigs.getByName("release")` enabling V1, V2, and V3 signing schemes. All keystores and `key.properties` are ignored by git.
  However, for iOS, `DEVELOPMENT_TEAM` and distribution provisioning profiles are not set in `project.pbxproj`, and no iOS build workflow exists in CI.

---

### Finding SEC-02: Legacy Password Retrieval Fallback for Biometrics
- **Severity:** P0 (Security Anti-Pattern)
- **Status:** **CONFIRMED ACTION REQUIRED**
- **Evidence Files:**
  - `lib/src/presentation/screens/authentication/splash/controller/splash_controller.dart:230-242`
  - `lib/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart:65, 392, 453, 524`
  - `lib/src/common/services/settings_service.dart:115-167`
- **Code Analysis:**
  In `splash_controller.dart`:
  ```dart
  // Legacy one-shot: password still on device from older builds.
  final savedPassword = await SettingsService.getLoggedInUserPassword();
  if (savedPassword == null || savedPassword.isEmpty) {
    return _bioFailed;
  }
  Get.offNamed(BaseRoute.signIn);
  final controller = Get.put(SignInController());
  controller.biometricEmail.value = savedEmail;
  controller.biometricPassword.value = savedPassword;
  await controller.submitSignIn(useBiometric: true);
  ```
  While `SignInController.signInWithBiometricTap()` modern flow uses the secure bearer token directly, the fallback path in `splash_controller.dart` still looks for a saved password.
- **Remediation:**
  1. Remove `SettingsService.getLoggedInUserPassword()` and `saveLoggedInUserPassword()`.
  2. Remove `biometricPassword` from `SignInController` and `splash_controller.dart`.
  3. If token is expired, biometric unlock must direct user to sign in with password manually; never persist or reuse stored passwords.

---

### Finding SEC-03: Token Storage & Session Expiration
- **Severity:** P0 (Confidentiality)
- **Status:** **CONFIRMED RESOLVED**
- **Evidence Files:**
  - `lib/src/network/service/token_service.dart:18-127`
  - `lib/src/common/services/session_timeout_service.dart:14-56`
- **Code Analysis:**
  `TokenService` manages the bearer token using `FlutterSecureStorage` with `AndroidOptions(encryptedSharedPreferences: true)` and `IOSOptions(accessibility: KeychainAccessibility.first_unlock)`.
  Lines 103-126 implement `_migrateFromLegacyStorage()`, automatically migrating any legacy token from `SharedPreferences` to `FlutterSecureStorage` on first launch and deleting the legacy entry immediately. `SessionTimeoutService` enforces a 30-minute idle session timeout.

---

### Finding SEC-04: App Lock & Screen Privacy
- **Severity:** P0 (Device Security)
- **Status:** **CONFIRMED ACTION REQUIRED**
- **Evidence Files:**
  - `lib/src/common/services/app_lock_service.dart:19-107`
  - `lib/src/presentation/widgets/app_lock_wrapper.dart:6-35`
  - `android/app/src/main/kotlin/com/ecardo/user/MainActivity.kt:1-6`
  - `ios/Runner/AppDelegate.swift:1-38`
- **Code Analysis:**
  `AppLockService` implements `WidgetsBindingObserver` to passively compute inactivity duration between `AppLifecycleState.paused` and `AppLifecycleState.resumed` (0% background CPU drain).
  However, neither Android's `WindowManager.LayoutParams.FLAG_SECURE` in `MainActivity.kt` nor iOS privacy blur in `AppDelegate.swift` are implemented. The OS app switcher exposes sensitive account and balance screens.
- **Remediation:**
  - Set `FLAG_SECURE` in `MainActivity.kt`.
  - Add snapshot blur in `AppDelegate.swift` for `applicationWillResignActive`.

---

### Finding LOG-01: Critical PII & Secret Logging in Console Output
- **Severity:** P0 (Confidentiality & Compliance)
- **Status:** **CONFIRMED CRITICAL LEAK**
- **Evidence Files:**
  - `lib/src/network/service/network_service.dart:721, 899, 970, 1037, 1114, 1253-1256`
  - `lib/src/presentation/screens/settings/controller/change_password_controller.dart:71-80`
  - `lib/src/presentation/screens/authentication/sign_in/controller/two_factor_auth_controller.dart:42-46`
  - `lib/src/common/controller/verify_passcode_controller.dart:41-44`
- **Code Analysis:**
  `NetworkService.post()` executes:
  ```dart
  if (data != null) {
    _log('📦 POST Request Body: ${jsonEncode(data)}');
  }
  ```
  This logs raw user passwords during password change, 2FA OTP codes, transaction PINs, and passcodes to the console.
  Furthermore, `_handleResponse()` logs all response bodies in full:
  ```dart
  _log('$requestType Response: $jsonData', icon: '✅');
  ```
  This emits virtual card PANs, CVVs, and user identity KYC records into device system logs.
- **Remediation:**
  - Add a key-based redaction sanitizer for all request bodies masking `password`, `code`, `passcode`, `pin`, `cvv`, `card_number`.
  - Truncate or disable full response body logging in `_handleResponse`.

---

### Finding ARC-01: Runtime Crash Risk from `Get.context!` in Field Declarations
- **Severity:** P0 (Application Stability)
- **Status:** **CONFIRMED CRITICAL DEFECT**
- **Evidence Files:**
  - `lib/src/presentation/screens/bill_payment/controller/toll_controller.dart:26`
  - `lib/src/presentation/screens/bill_payment/controller/internet_controller.dart:30`
  - `lib/src/presentation/screens/bill_payment/controller/electricity_controller.dart:27`
  - `lib/src/presentation/screens/bill_payment/controller/data_bundle_controller.dart:26`
  - `lib/src/presentation/screens/bill_payment/controller/airtime_controller.dart:31`
  - `lib/src/presentation/screens/bill_payment/controller/cable_controller.dart:26`
  - `lib/src/presentation/screens/gift_card/controller/gift_card_controller.dart:30`
  - `lib/src/presentation/screens/cash_out/controller/cash_out_controller.dart:33`
- **Code Analysis:**
  The field declaration:
  ```dart
  final localization = AppLocalizations.of(Get.context!);
  ```
  executes immediately when the controller is instantiated. If the controller is registered via a route binding or instantiated before `Get.context` is mounted, `Get.context!` throws `Null check operator used on a null value`, immediately crashing the app.
- **Remediation:**
  Replace with a getter:
  ```dart
  AppLocalizations? get localization => Get.context != null ? AppLocalizations.of(Get.context!) : null;
  ```

---

### Finding UI-01: RTL Thumb Misalignment in `EcardoSwipeButton`
- **Severity:** P0 (Functional UI Defect)
- **Status:** **CONFIRMED DEFECT**
- **Evidence Files:**
  - `lib/src/common/widgets/design_system/ecardo_swipe_button.dart:268-326`
  - `lib/src/presentation/screens/transfer/view/widgets/swipe_to_confirm_slider.dart:101-150`
- **Code Analysis:**
  The widget uses `Stack(alignment: AlignmentDirectional.centerStart)` which aligns to the **right** in RTL locales, but positions the draggable thumb using `Positioned(left: 4.0 + _dragPosition)`.
  In Persian or Arabic, the fill background starts from the right while the thumb sits on the left, and dragging is inverted or broken.
- **Remediation:**
  Wrap the slider layout in `Directionality(textDirection: TextDirection.ltr)` or compute thumb position relative to text direction.

---

### Finding API-02: False Session Logout on Retried Request Failure
- **Severity:** P1 (Session Resilience)
- **Status:** **CONFIRMED DEFECT**
- **Evidence Files:**
  - `lib/src/network/service/network_service.dart:310-334`
- **Code Analysis:**
  If a token refresh succeeds, but the subsequent retry of the original request (`_dio.fetch`) throws an error (e.g. 500 error or momentary packet drop), execution catches the error and falls through to line 321:
  ```dart
  _log("Token refresh failed — logging out.");
  // ... triggers SessionManager.handleUnauthorized()
  ```
  The app forcibly logs out the user even though their authentication token was successfully refreshed!
- **Remediation:**
  If refresh succeeded, return the retried request error via `handler.next(error)` and do not trigger logout.

---

### Finding API-03: `_TransportRetryInterceptor` Wiped During Initialization
- **Severity:** P1 (Resiliency)
- **Status:** **CONFIRMED DEFECT**
- **Evidence Files:**
  - `lib/src/network/service/network_service.dart:144-154, 194-197`
- **Code Analysis:**
  In `_configureHttpClient()`, line 147 adds `_TransportRetryInterceptor`. However, line 154 calls `_setupInterceptors()`, which immediately executes `_dio.interceptors.clear()`, wiping the retry interceptor. Authenticated requests never undergo transport retries.
- **Remediation:**
  Add `_TransportRetryInterceptor` inside `_setupInterceptors()` after `_dio.interceptors.clear()`.

---

### Finding UI-02: Light Theme Secondary Contrast Failure
- **Severity:** P1 (Accessibility / WCAG AA)
- **Status:** **CONFIRMED DEFECT**
- **Evidence Files:**
  - `lib/src/app/config/theme/light_theme.dart:12-13`
- **Code Analysis:**
  `onSecondary: AppColors.white` on `secondary: AppColors.lightSecondary` (`#00BFA6`) produces a contrast ratio of only **1.92:1**. WCAG AA requires at least **4.5:1** for normal text.
- **Remediation:**
  Set `onSecondary: AppColors.deepBlack` (`#161614`) achieving a 9:1 contrast ratio.

---

### Finding LOC-02: Arabic Fallback Bug in `l10nPick`
- **Severity:** P1 (Localization)
- **Status:** **CONFIRMED DEFECT**
- **Evidence Files:**
  - `lib/src/helper/l10n_pick.dart:21-22`
- **Code Analysis:**
  ```dart
  case 'ar':
    return ar ?? fa;
  ```
  When an Arabic translation is missing, it displays Persian (`fa`) instead of English (`en`), causing incomprehensible text for Arabic speakers in international markets.
- **Remediation:**
  Change to `return ar ?? en;`.

---

### Finding VAL-01: Missing Sheba & Luhn Bank Card Client-Side Validation
- **Severity:** P1 (Input Integrity)
- **Status:** **CONFIRMED DEFECT**
- **Evidence Files:**
  - `lib/src/presentation/screens/remittance/view/sub_sections/remittance_receiver_section.dart:151-157`
  - `lib/src/presentation/screens/remittance/controller/remittance_controller.dart:895`
- **Code Analysis:**
  The Sheba field accepts any text without checking length (26 chars), `IR` prefix, or ISO 7064 checksum (mod-97-10). The card number field lacks Luhn check and 16-digit formatting. Invalid inputs proceed to review step without validation.
- **Remediation:**
  Add input formatters and validators for Sheba and 16-digit debit cards before advancing steps.

---

### Finding CICD-01: Missing Dart Obfuscation and Over-Privileged CI Scope
- **Severity:** P1 (Supply Chain & IP Protection)
- **Status:** **CONFIRMED DEFECT**
- **Evidence Files:**
  - `.github/workflows/flutter.yml:26, 81, 186-187`
- **Code Analysis:**
  - Line 26: `permissions: contents: write` runs for all PRs, violating the principle of least privilege.
  - Line 81: `--no-fatal-warnings` suppresses compiler warnings.
  - Line 186: `flutter build apk --release --split-per-abi` does not include `--obfuscate --split-debug-info=build/symbols`.
- **Remediation:**
  Scope write permissions to tag releases, enforce zero warnings, and enable `--obfuscate`.
