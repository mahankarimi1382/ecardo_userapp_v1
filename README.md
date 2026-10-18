# eCardo User App (v1)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.44.6-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.12.2-blue.svg)](https://dart.dev)
[![Application ID](https://img.shields.io/badge/Application%20ID-com.ecardo.user-green.svg)](android/app/build.gradle.kts)
[![Tests Passing](https://img.shields.io/badge/Tests-731%20Passing-brightgreen.svg)](test/)
[![Static Analysis](https://img.shields.io/badge/Analyze-0%20Issues-brightgreen.svg)](analysis_options.yaml)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

Production-grade Flutter fintech mobile application for the **eCardo** platform (domain `ecardo.ir`), engineered with GetX state management and dependency injection, Dio HTTP client with retry and mutex token refresh, runtime SSL certificate pinning, secure keystore storage, full Persian/RTL localization, Shamsi calendar support, and integrated commercial and travel services.

---

## 1. Executive Summary & Current State

The `ecardo_userapp_v1` codebase represents a fully rebranded, hardened, and localized fintech user application. All legacy artifacts, identifiers, and security risks from early development versions have been systematically resolved:

| Dimension | Legacy / Initial State | Current Production Reality |
| :--- | :--- | :--- |
| **Brand Identity** | Qunzo / `com.qunzo.user` | **eCardo** / `com.ecardo.user` / Dart package `ecardo_user` |
| **Application ID** | `com.qunzo.user` | `com.ecardo.user` (Android & iOS) |
| **Firebase Project** | Legacy project `qunzo-b2252` | **`ecardo-app`** (Android `1:292987494106:android:3f1e8b21e46ceb2c138fe3`, iOS `1:292987494106:ios:9009185e45066d59138fe3`) |
| **Credential Storage** | Plaintext `SharedPreferences` | **`FlutterSecureStorage`** (Android Keystore / iOS Keychain) with automatic migration from legacy storage |
| **Biometric Auth** | Stored plaintext password | Biometric challenge & secure bearer token; zero plaintext password persistence |
| **Network Security** | No certificate pinning | **Runtime SSL certificate pinning** (`SslPinningConfig`) with fail-closed gates for `ecardo.ir` and `trip.ecardo.ir` |
| **Screen Privacy** | App switcher exposes data | **`AppLockService` background privacy protection** and balance obscuring with zero-freeze cold start |
| **Financial Safety** | Unprotected mutations | **Idempotency keys** (`Idempotency-Key` & `X-Idempotency-Key`) across 23 financial endpoints with 5xx error retention |
| **Localization** | English & Arabic only | **6 complete locales**: Persian (`fa`), Arabic (`ar`), English (`en`), Russian (`ru`), Turkish (`tr`), Chinese (`zh`) |
| **Typography** | Latin-only Plus Jakarta Sans | **`Vazirmatn`** (Persian & Arabic), **`Plus Jakarta Sans`** (Latin), **`NotoSansRU`** (Cyrillic) |
| **Calendar Support** | Gregorian only | **Shamsi (Jalali)** solar calendar (`shamsi_date`) with Shamsi date picker + Gregorian for international locales |
| **Build & CI/CD** | Debug-signed APKs | **Fail-closed release signing**, R8 minification with coroutine preservation, Universal FAT APK (arm64/arm32/x64), automated 731 test suite |

---

## 2. Core Architecture & Technology Stack

- **Framework**: Flutter `3.44.6` (Channel stable) / Dart SDK `3.12.2`
- **Architecture Pattern**: Clean Feature-Driven GetX Architecture
  - **State Management**: Reactive state (`RxBool`, `RxString`, `RxList`, `Obx`)
  - **Dependency Injection**: Route-scoped `Bindings` with lazy controllers
  - **Navigation**: GetX declarative routing with 99 defined application routes (`lib/src/app/routes/routes.dart`)
  - **Responsive UI**: `flutter_screenutil` (baseline 376 × 812 dp)
- **Networking**:
  - `Dio` HTTP client with custom interceptor pipeline
  - Concurrent request mutex queue for automatic 401 token refresh (`NetworkService`)
  - Transport retry interceptor with exponential backoff for network blips
  - PII and credential sanitization on all debug loggers
  - Strict connection and response timeouts (15s / 20s)
- **Local Storage**:
  - `FlutterSecureStorage`: Encrypted token, session, and PIN salt/hash storage
  - `SharedPreferences`: Non-sensitive UI preferences (language selection, theme mode)

---

## 3. Security & Compliance Architecture

### 3.1 Secure Credential & Session Management
- **Token Security**: Authentication bearer tokens are stored in hardware-backed keystores via `FlutterSecureStorage` (`AndroidOptions(encryptedSharedPreferences: true)` on Android and `IOSOptions(accessibility: KeychainAccessibility.first_unlock)` on iOS).
- **Automated Migration**: `TokenService` automatically detects legacy tokens in unencrypted preferences, transfers them into secure storage, and purges the legacy entry.
- **Session Timeout**: `SessionTimeoutService` enforces a 30-minute idle session timeout, expiring stale sessions and returning users to the secure authentication gate.
- **Biometric Security**: Biometric authentication unlocks the existing secure bearer token directly; user passwords are never stored, logged, or cached for biometric re-entry.

### 3.2 Network Security & Runtime SSL Certificate Pinning
- **Fail-Closed SSL Pinning**: `SslPinningConfig` enforces cryptographic SHA-256 certificate pinning on all outbound connections to `ecardo.ir` and `trip.ecardo.ir`.
- **Zero-Tolerance Pin Failure**: In release builds, if certificate pins are missing or fail cryptographic validation, the HTTP pipeline fails closed immediately, protecting users against malicious proxying and rogue Certificate Authorities.
- **Dynamic Pin Rotation Support**: CI workflows support dual primary (`ECARDO_CERT_PIN`) and backup (`ECARDO_CERT_PIN_BACKUP`) pins to facilitate seamless server certificate rotation.

### 3.3 Screen Privacy & Anti-Tampering
- **Native Screen Privacy**: `MainActivity.kt` enforces `WindowManager.LayoutParams.FLAG_SECURE` on Android, blocking screen recording, screen capture, and blurring app contents in the OS recent applications overview.
- **Code Obfuscation**: Production builds compile with `--obfuscate --split-debug-info=build/symbols` and Gradle R8 code shrinking to prevent reverse engineering.
- **Release Signing Fail-Closed**: Release Gradle configuration rejects builds if release signing credentials or keystores are missing.

### 3.4 Financial Safety & Idempotency
- **Idempotency Keys**: All financial mutation endpoints (transfers, exchange, top-up, withdraw, bill payment) generate unique UUIDv4 `X-Idempotency-Key` headers.
- **Duplicate Prevention**: In-flight requests are cached to prevent accidental double-submits on network retries or multi-tap UI interactions.

---

## 4. Internationalization, Localization & Calendars

### 4.1 Multi-Language Support (6 Complete Locales)
The application provides full native localization across 6 complete locales:
- 🇮🇷 **Persian (`fa`)** — Complete RTL translation, Vazirmatn typography, Persian digit conversion
- 🇦🇪 **Arabic (`ar`)** — Complete RTL translation, Vazirmatn typography
- 🇬🇧 **English (`en`)** — Default LTR international locale
- 🇷🇺 **Russian (`ru`)** — Complete Cyrillic localization and typography
- 🇹🇷 **Turkish (`tr`)** — Complete Turkish localization
- 🇨🇳 **Simplified Chinese (`zh`)** — Complete Simplified Chinese localization

### 4.2 RTL Engine & Directionality
- Directionality is dynamically bound to the selected locale (`fa` and `ar` activate RTL mode).
- Interactive components like `EcardoSwipeButton` automatically adapt their gesture tracking, drag bounds, and animations to RTL orientation.

### 4.3 Typography
- **Persian & Arabic**: Bundled `Vazirmatn` font family (`assets/fonts/Vazirmatn-*.ttf`), ensuring consistent metrics and baseline alignment.
- **Latin & Turkish**: Bundled `Plus Jakarta Sans` family.
- **Cyrillic**: Bundled `NotoSansRU` family.

### 4.4 Shamsi (Jalali) Calendar & Date Pickers
- Persian locale integrates the Solar Hijri (Shamsi/Jalali) calendar powered by `shamsi_date`.
- Custom Shamsi date pickers (`JalaliDatePicker`) provide native year, month, and day selection for domestic travel and financial filters, with automatic bidirectional conversion to Gregorian ISO-8601 timestamps for backend communication.

---

## 5. Domain & Feature Inventory

The application encompasses **31 presentation screen modules** and **9 core financial domains** (`lib/src/`):

1. **Authentication & Identity**: Multi-factor authentication, email OTP verification, biometric sign-in, KYC verification wizard.
2. **Multi-Currency Wallets**: Real-time balances in Fiat and Crypto, multi-wallet carousel, 3D flip card balance visualization.
3. **P2P Currency Exchange**: Live rate calculation with cross-rate math, dynamic slippage protection, and countdown timer rate locking.
4. **Domestic & International Transfers**: Internal user transfers, IBAN/Sheba account validation with Luhn and mod-97-10 verification.
5. **Deposit & Withdrawal**: Integrated payment gateways, Sheba bank transfers, agent cash-out, and crypto withdrawals.
6. **Virtual Cards**: Issuance and management of virtual Visa/Mastercard cards, instant freeze/unfreeze, and card funding.
7. **Travel Services**: Complete booking flow for Domestic & International Flights, Hotels, VIP Airport CIP Lounges, City Taxis, and Experiences.
8. **Bill Payment & Utilities**: Electricity, water, internet, mobile recharge, and road toll payment with carrier auto-detection.
9. **Merchant Payment Links & QR**: Instant scan-to-pay and personalized QR code receiving.
10. **Ticketing & Customer Support**: In-app ticketing system with file attachments and threaded replies.

---

## 6. Firebase Infrastructure

Firebase configuration is fully reconciled with the production Google Cloud project **`ecardo-app`**:

- **Project ID**: `ecardo-app`
- **Project Number**: `292987494106`
- **Android App ID**: `1:292987494106:android:3f1e8b21e46ceb2c138fe3`
- **iOS App ID**: `1:292987494106:ios:9009185e45066d59138fe3`
- **Storage Bucket**: `ecardo-app.firebasestorage.app`
- **Configuration Files**:
  - `firebase.json`
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

---

## 7. Quality Assurance & Testing Suite

### 7.1 Automated Test Suite (731 Tests)
The repository contains **731 passing automated tests** verifying financial logic, state machines, and UI components:
```bash
$ flutter test
01:05 +731: All tests passed!
```
- **Financial Math & Idempotency**: Rounding rules, fee deductions, balance debit/credit idempotency, 5xx key retention (`money_math_helper_test.dart`, `workstream_b_idempotency_logging_test.dart`, `reaudit_security_invariants_test.dart`).
- **Base58Check Cryptographic Validation**: Validates authentic TRON TRC-20 addresses with double-SHA256 checksum verification and fail-closed security (`tron_address_validator_test.dart`).
- **Passcode State Machine**: Loop-prevention invariants across all 6 financial operations (`passcode_resilience_state_machine_test.dart`).
- **Exchange Logic**: Cross-rate calculations, rate inversion safety, rate lock timeouts (`exchange_controller_test.dart`).
- **RTL & Widget Geometry**: Directionality mirroring, swipe slider limits, wallet card flipping (`wallet_card_rtl_test.dart`).
- **Input Validation**: Sheba mod-97-10 checksums, card Luhn validation (`withdraw_modernization_qc_test.dart`).
- **Session & Security**: Token migration, offline request queue hardening, app lock timeouts, persistent PIN hashing (`app_lock_service_test.dart`, `workstream_a_session_pin_test.dart`).

### 7.2 Static Code Analysis
```bash
$ flutter analyze
Analyzing ecardo_userapp_v1...
No issues found! (ran in 7.1s)
```
The codebase maintains **0 analyzer errors** and adheres to strict linting rules.

---

## 8. CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/flutter.yml`) automates build, test, and release verification:

1. **Smart Changed-Files Formatting Gate**:
   ```bash
   BASE_REF=""
   if [ "${{ github.event_name }}" = "pull_request" ]; then
     BASE_REF="origin/${{ github.base_ref }}"
   elif [ -n "${{ github.event.before }}" ] && [ "${{ github.event.before }}" != "0000000000000000000000000000000000000000" ]; then
     BASE_REF="${{ github.event.before }}"
   else
     BASE_REF="HEAD~1"
   fi
   CHANGED_DART_FILES=$(git diff --name-only "$BASE_REF"...HEAD 2>/dev/null | grep '\.dart$' || true)
   if [ -n "$CHANGED_DART_FILES" ]; then
     dart format --output=none --set-exit-if-changed $CHANGED_DART_FILES
   fi
   ```
2. **Localization Generation**: Executes `flutter gen-l10n` to ensure all 6 ARB catalogs compile cleanly.
3. **Static Analyzer Gate**: Runs `flutter analyze` with failure on any compiler or analysis error.
4. **Automated Test Gate**: Executes the complete 731-test suite via `flutter test`.
5. **Signed Release Pipeline**:
   - Compiles release APK with `--obfuscate --split-debug-info=build/symbols --split-per-abi`.
   - Injects runtime SSL certificate pins (`ECARDO_CERT_PIN`).
   - Verifies APK cryptographic signature (V1, V2, V3 APK signature scheme).
   - Generates GitHub release, mirrors artifacts to `mahankarimi1382/ecardo-apps-releases`, and notifies the server deploy webhook.

---

## 9. Developer Setup & Workflow

### Prerequisites
- **Flutter SDK**: `3.44.6` (Dart `3.12.2`)
- **JDK**: Java 17 (Temurin recommended)
- **Android SDK**: `compileSdk 36`, `minSdk 24`, `targetSdk 36`

### Installation & Run Commands
```bash
# Clone the repository
git clone https://github.com/mahankarimi1382/ecardo_userapp_v1.git
cd ecardo_userapp_v1

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run static analysis
flutter analyze

# Run all automated tests
flutter test

# Run app in debug mode
flutter run
```
