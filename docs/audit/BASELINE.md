# eCardo User App (v1) — Audit Baseline & Environment Report

**Audit Date:** 2026-10-18  
**Target Repository:** `mahankarimi1382/ecardo_userapp_v1`  
**Inspected Branch:** `main`  
**Local HEAD SHA:** `d47dae08d28cfc613ad480006a6b09c4e3bdffd9` (`d47dae0`)  
**Remote origin/main SHA:** `c132c17c8ac1518599c76951f476bd05b6ffe44a` (`c132c17`)  
**Tracking Status:** 3 commits ahead of `origin/main` (retained locally per No Unapproved GitHub Updates rule)  
**Declared Version:** `1.0.173+173` (`pubspec.yaml`)  
**Audit Mode:** Complete Release Governance, Financial Resilience & QA Baseline Verification  
**Lead Authority:** Release Governance, Enterprise Architecture & QA Lead Team  

---

## 1. Executive Summary & Audit Baseline

This document establishes the verified baseline of `ecardo_userapp_v1` as required by the release governance and re-audit framework. Every metric, gate status, and invariant in this report was verified directly by executing diagnostic commands on the live codebase, running the comprehensive test suite, and evaluating platform configurations.

### Key Baseline Findings at a Glance
| Metric / Check | Baseline Value | Status / Verdict |
| :--- | :--- | :--- |
| **Active Version** | `1.0.173+173` (`pubspec.yaml`) | Canonical Active Target |
| **Git Branch** | `main` | Active |
| **Local HEAD SHA** | `d47dae08d28cfc613ad480006a6b09c4e3bdffd9` (`d47dae0`) | Verified |
| **Remote origin/main SHA** | `c132c17c8ac1518599c76951f476bd05b6ffe44a` (`c132c17`) | Verified |
| **Git Tracking Delta** | Branch is ahead of `origin/main` by 3 commits (retained locally per No Unapproved GitHub Updates rule) | Governed & Documented |
| **Working Tree State** | Working directory contains financial step-up fallback improvements & test additions; unpushed per rule | Verified & Governed |
| **Flutter Toolchain** | `Flutter 3.44.6 • channel stable • Tools • Dart 3.12.2` | Supported & Verified |
| **Static Analyzer** | `flutter analyze` — **No issues found!** (0 errors, 0 warnings, ran in 8.0s) | Clean (100% Pass) |
| **Automated Tests** | `flutter test` — **728 tests passed!** (0 failures, 0 skipped, 100% green) | 100% Green |
| **Passcode State Machine** | Loop prevention invariants implemented & tested in `test/passcode_resilience_state_machine_test.dart` | Verified & Passing |
| **Android Packaging** | Universal FAT release APK (`target-platform android-arm,android-arm64,android-x64`) with R8 `-dontoptimize` fix | Ready for Release / Staging |
| **iOS Packaging** | Apple Developer Team ID, distribution certificate, and provisioning profiles unconfigured | 🔴 BLOCKED (Awaiting Credentials) |
| **Defined Routes** | **99 distinct routes** (`lib/src/app/routes/routes.dart`) | Complete inventory |
| **Screen Modules** | **31 presentation modules + 9 root service domains (40 total)** | Complete inventory |
| **Languages Supported** | 6 locales: `fa` (Persian), `en` (English), `ar` (Arabic), `ru` (Russian), `tr` (Turkish), `zh` (Chinese) with 100% key parity (2,700 keys) | All generated & synced |
| **Primary Fonts** | `Vazirmatn` (Persian/Arabic), `Plus Jakarta Sans` (Latin), `NotoSansRU` (Cyrillic) | Verified in pubspec.yaml |
| **Target SDKs** | Android (minSdk 24, compileSdk 36, targetSdk 36), iOS (13.0+) | Configured |

---

## 2. Environment & Tooling Verification

### 2.1 Git Topology & Commit History
```bash
$ git branch -vv
* main d47dae0 [origin/main: ahead 3] fix(financial): generalize passcode step-up fallback & wallet balance validation across all money operations

$ git rev-parse HEAD
d47dae08d28cfc613ad480006a6b09c4e3bdffd9

$ git rev-parse origin/main
c132c17c8ac1518599c76951f476bd05b6ffe44a
```

#### Commit History Ahead of `origin/main` (3 Commits):
1. **`18cf06a`** `fix(exchange,cards): eliminate passcode prompt drop & regional card provider crash`
   - Exchange: enforce transaction passcode prompt whenever user has set a passcode on their account or feature is active; auto-fallback to `VerifyPasscodeBottomSheet` on server passcode 422.
   - Virtual Cards: filter out regional-restricted Stripe provider from client catalog; surface localized error toast if legacy provider rejects country; ensure primary eCardo IRR card order flow is prioritized.
2. **`43b7c9d`** `docs: sync AGENTS.md project instructions`
   - Synchronize workspace instruction set.
3. **`d47dae0`** `fix(financial): generalize passcode step-up fallback & wallet balance validation across all money operations`
   - Passcode: add automatic `VerifyPasscodeBottomSheet` step-up fallback across Transfer, CashOut, Withdraw, MakePayment, and CreateGift controllers whenever server returns passcode 422.
   - Virtual Card Order: validate funding wallet balance before order submission; surface localized Persian error message if wallet balance is insufficient for initial load + creation fee.

*Note on Local Retention:* All three commits and subsequent working tree updates are retained locally in accordance with the project's strict **No Unapproved GitHub Updates** rule (`MEMORY.md`). Zero unauthorized pushes or remote updates are executed without explicit user consent.

### 2.2 Flutter & Dart Diagnostics
```bash
$ flutter --version
Flutter 3.44.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision ee80f08bbf • 2026-07-08 15:02:06 -0700
Engine • hash d3a3293399556a85388faf8c6f0723a7a5597aa8
Tools • Dart 3.12.2 • DevTools 2.57.0
```

### 2.3 Static Analysis Output
```bash
$ flutter analyze
Analyzing ecardo_userapp_v1...
No issues found! (ran in 8.0s)
```
Zero lint errors, zero warnings, zero dead code issues across all 40 modules and 99 routes.

### 2.4 Automated Test Suite Execution
```bash
$ flutter test
00:59 +728: All tests passed!
```
The automated test suite consists of **728 comprehensive unit, widget, screenshot, QC, and resilience tests** (100% green, 0 failures, 0 skipped):
- **Passcode Resilience & Loop Prevention Invariants (6 tests in `test/passcode_resilience_state_machine_test.dart`)**
- **Financial Math & Fee Calculation tests** (`money_math_helper_test.dart`)
- **Offline Request Queue, Security & DLQ tests** (`offline_request_queue_test.dart`)
- **Workstream B Idempotency Lifecycle & PII Redaction tests** (`workstream_b_idempotency_logging_test.dart`)
- **Workstream A Session & PIN Migration tests** (`workstream_a_session_pin_test.dart`)
- **Re-Audit Security Invariant tests** (`reaudit_security_invariants_test.dart`)
- **Exchange Cross-Rate, Inversion & Validation tests** (`exchange_modular_services_test.dart`, `exchange_screen_qc_test.dart`)
- **Virtual Card Modernization & Regional Provider tests** (`virtual_card_modernization_test.dart`, `card_product_model_test.dart`)
- **Withdraw Sheba, Card Masking & Bank Payout tests** (`withdraw_modernization_qc_test.dart`)
- **Multi-Currency Wallet Carousel & RTL Rendering tests** (`wallet_card_rtl_test.dart`, `wallets_creative_ui_test.dart`, `wallets_screenshot_test.dart`)
- **Travel Suite & Subservices tests** (Flights, Hotels, Car Rental, Taxi, Tour, Visa, eSIM, Boat, Dining, Jalali Date Helper)
- **Localization Parity & RTL Quality tests** (`ux_i18n_catalog_qc_test.dart`, `locale_language_switch_qc_test.dart`)
- **Security & Network Interception tests** (`ssl_pinning_config_test.dart`, `demo_mode_network_interception_test.dart`, `demo_mode_release_gate_test.dart`)

---

## 3. Financial Core & Passcode Resilience Invariants

### 3.1 Passcode Loop Prevention Invariants (`test/passcode_resilience_state_machine_test.dart`)
A critical resilience vulnerability identified in automated financial recovery flows was the potential for infinite retry loops if the server returns an HTTP 422 containing passcode keywords even after a passcode was already submitted.

The state machine in `PasscodeHelper` enforces four hard invariants:
1. **Challenge Detection (`isPasscodeRequired`):** Returns `true` if and only if the server response indicates a passcode challenge AND `wasPasscodeProvided == false`.
2. **Infinite Loop Hard Brake (Critical Invariant):** When `wasPasscodeProvided == true`, `isPasscodeRequired(...)` strictly evaluates to `false`. This terminates all automatic prompt/retry cascades regardless of error payload text.
3. **Negative Signal Discrimination:** Errors indicating invalid/incorrect passcodes (`PASSCODE_INVALID`, "رمز اشتباه است") or account lockouts (`PASSCODE_LOCKED`, "مسدود شد") evaluate to `false` in `isPasscodeRequired`, routing directly to dedicated alerts and lockout gates rather than prompt loops.
4. **Digit Normalization & Validation:** `PasscodeHelper.normalize()` transparently converts Persian/Arabic numerals (e.g. `۱۲۳۴` -> `1234`) via `DigitNormalizationFormatter`, ensuring clean bcrypt verification on the backend.

### 3.2 Step-Up Fallback across Financial Operations
The automatic `VerifyPasscodeBottomSheet` step-up fallback has been generalized and implemented across all money-moving controllers:
- `TransferController` (`lib/src/presentation/screens/transfer/controller/transfer_controller.dart`)
- `CashOutController` (`lib/src/presentation/screens/cash_out/controller/cash_out_controller.dart`)
- `WithdrawController` (`lib/src/presentation/screens/withdraw/controller/withdraw_controller.dart`)
- `MakePaymentController` (`lib/src/presentation/screens/make_payment/controller/make_payment_controller.dart`)
- `CreateGiftController` (`lib/src/presentation/screens/gift_code/controller/create_gift_controller.dart`)
- `ExchangeController` (`lib/src/presentation/screens/exchange/controller/exchange_controller.dart`)
- `CreateVirtualCardController` (`lib/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart`)

### 3.3 Funding Wallet Pre-Validation
Before any virtual card order is dispatched to the network, `CreateVirtualCardController` pre-validates that the user's selected funding wallet balance is greater than or equal to `cardCreationFee + initialLoadAmount`. If balance is insufficient, a localized Persian error toast is immediately surfaced without sending an unprocessable mutation over the wire.

---

## 4. Platform Packaging & Build Architecture

### 4.1 Android Packaging: Universal FAT Release APK with R8 `-dontoptimize` Fix
- **Universal FAT APK:** Build command in `.github/workflows/flutter.yml:209-211` targets all primary ABIs simultaneously:
  ```bash
  flutter build apk --release \
    --obfuscate --split-debug-info=build/symbols \
    --target-platform android-arm,android-arm64,android-x64 \
    --tree-shake-icons $PIN_ARGS
  ```
  This eliminates ABI mismatch errors across all physical ARMv7, ARM64, and x86_64 emulator devices.
- **R8 / ProGuard Optimization Fix:** In `android/app/proguard-rules.pro:14-16`, the `-dontoptimize` directive and explicit Kotlin standard library rules are configured:
  ```proguard
  # ---------- Kotlin Standard Library, Coroutines & Pigeon Plugins ----------
  -dontoptimize
  -keep class kotlin.** { *; }
  -keepclassmembers class kotlin.** { *; }
  -keep class io.flutter.plugins.sharedpreferences.** { *; }
  -keepclassmembers class io.flutter.plugins.sharedpreferences.** { *; }
  -keepclassmembers class * {
      *** *(kotlin.coroutines.Continuation);
  }
  ```
  This prevents R8 aggressive dead-code elimination from stripping coroutine continuations and Kotlin standard library classes, eliminating `ClassNotFoundException: kotlin/Result` on Android 14+ release builds.
- **Release Signing:** Fail-closed release signing configured via `android/app/build.gradle.kts` using V1, V2, and V3 signing schemes.

### 4.2 iOS Status: Hard Blocked Awaiting Credentials
- **Status:** 🔴 **BLOCKED**
- **Root Cause:** Absence of Apple Developer Team ID, distribution signing certificates, and App Store / Ad-Hoc provisioning profiles in build environment.
- **Technical Readyness:** Flutter Dart codebase, iOS configuration, `GoogleService-Info.plist`, and Runner Xcode project are fully prepared; build gate is gated purely on organization credential provisioning.

---

## 5. Codebase Inventory & Routes

### 5.1 Presentation Modules (31 Screen Domains in `lib/src/presentation/screens/`)
1. `add_money` — Deposit & payment gateway top-up flows
2. `app_update` — In-app force/flexible update gate
3. `authentication` — Sign-in, sign-up, email OTP, 2FA, biometric, forgot password
4. `beneficiary` — Management of transfer recipients (internal user & external)
5. `bill_payment` — Utility bills, mobile top-up, packages, operators
6. `cash_out` — Agent cash-out & payout points
7. `device_sessions_security` — Multi-device management, active session revoke, PIN setup
8. `dynamic_password` — Time-based dynamic OTP tokens
9. `exchange` — Live multi-currency swap with rate locking & drift detection
10. `gift_card` — Digital gift cards & external merchants
11. `gift_code` — Peer-to-peer redeemable vouchers
12. `home` — Dashboard, balance cards, quick actions, service catalog drawer
13. `kyc_level` — Multi-tier KYC submission wizard & identity verification
14. `make_payment` — Merchant payments via QR code, payment links, and accounts
15. `not_found` — Fallback error screen for unknown routes
16. `notifications` — Push & in-app notification center with action routing
17. `p2p` — Peer-to-peer crypto/fiat trading orders, escrow chat, release flow
18. `payment_links` — Merchant link generation, shareable payment requests
19. `qr_code` — Scan-to-pay & personal receive QR generator
20. `referral` — Referral program, rewards, multi-level tree visualization
21. `remittance` — International cross-border money transfer
22. `request_money` — P2P invoice and payment request creation
23. `services` — Categorized hub of all platform financial and travel services
24. `settings` — User preferences, security, language, theme, biometric toggles
25. `support_tickets` — In-app ticketing system with file attachments & threaded replies
26. `transactions` — Infinite scrolling transaction history with filters & detail receipts
27. `transfer` — Internal wallet-to-wallet and user-to-user transfers
28. `travel` — Comprehensive travel suite (flights, hotels, CIP lounges, taxi, dining, boat)
29. `virtual_card` — Multi-currency Visa/Mastercard virtual card issuance & funding
30. `wallets` — Multi-currency wallet portfolio (Fiat & Crypto) with flip-card details
31. `withdraw` — Bank transfer, Iranian Sheba payout, crypto withdrawal

### 5.2 Root Feature Domains (9 Specialized Financial & Service Domains in `lib/src/`)
1. `commercial` — Equity investment & commercial development project funding
2. `escrow` — Safe transaction escrow with milestone payments & dispute resolution
3. `guarantee` — Bank and platform guarantee certificates & margin deposit
4. `license` — Commercial software and business license store
5. `loan` — Micro-loans, installment schedules, early repayment calculator
6. `rental` — Vehicle and equipment rental with digital vouchers
7. `stock` — International stock market quotes, order placement & tracking
8. `tour` — Group and customized travel tour booking & voucher generation
9. `visa` — Tourist and business visa application processing

### 5.3 Route Registry
Defined in `lib/src/app/routes/routes.dart`:
- Total declared constants: **99 routes**
- All registered in GetX page router (`lib/src/app/routes/routes_config.dart`)
- Pre-auth routes exempted from app lock: 11 routes (`root`, `splash`, `signIn`, `welcome`, `emailOtpLogin`, `twoFactorAuth`, `email`, `verifyEmail`, `signUpStatus`, `setUpPassword`, `forgotPassword`, `appUpdate`)

---

## 6. Current State vs. Security & Roadmap Findings

| Finding ID | Domain | Verified Codebase State | Status |
| :--- | :--- | :--- | :--- |
| **SEC-01** | Release Signing | `android/app/build.gradle.kts` enforces fail-closed signing. Dedicated release keystore via CI secrets with V1+V2+V3 schemes. | **RESOLVED** |
| **SEC-02** | Secure Token Storage | Bearer tokens stored exclusively in `FlutterSecureStorage` (Android Keystore / iOS Keychain). Legacy SharedPreferences queries completely eliminated. | **RESOLVED** |
| **SEC-03** | Plaintext Password Pruning | Password retrieval fallback in `splash_controller.dart` and `sign_in_controller.dart` eliminated. Biometric unlock uses secure token. | **RESOLVED** |
| **SEC-04** | App Lock & Privacy | Passive lifecycle tracking (`WidgetsBindingObserver`), salted SHA-256 PIN hashing, and balance obscuring when backgrounded. Unconditional native `FLAG_SECURE` removed to prevent cold-start black screen. | **RESOLVED** |
| **FIN-01** | Financial Idempotency | Dual header emission (`Idempotency-Key` and `X-Idempotency-Key`), RFC 8785 canonical JSON SHA-256 fingerprinting, 5-minute TTL, key retention on 5xx/timeout. | **RESOLVED** |
| **FIN-02** | Passcode Resilience | `PasscodeHelper` loop prevention invariant (`wasPasscodeProvided=true -> false`), negative signal classification, and step-up fallback across all 7 money flows. | **RESOLVED** |
| **FIN-03** | Card Provider Isolation | Regional Stripe card provider filtered out of client catalog; wallet balance pre-validated before virtual card order submission. | **RESOLVED** |
| **NET-01** | SSL Pinning | Dual-slot certificate pinning (`ECARDO_CERT_PIN` & `ECARDO_CERT_PIN_BACKUP`) with live server pin verification in CI. User CAs blocked. | **RESOLVED** |
| **NET-02** | Offline Request Queue | Exact route/method allowlist, 21 sensitive keys blocked recursively, 24h TTL, 25-item max capacity, Dead-Letter Queue (DLQ). | **RESOLVED** |
| **LOC-01** | Localization & BiDi | 100% key parity (2,700 keys) across 6 languages (fa, en, ar, ru, tr, zh). Vazirmatn font bundled. Shamsi Jalali date conversion. LTR isolation for card numbers under RTL parents. | **RESOLVED** |
| **REL-01** | Packaging & R8 | Universal FAT release APK with `-dontoptimize` Kotlin standard library keep rules in ProGuard. | **RESOLVED** |

---

## 7. Baseline Verification Artifacts
- Static analyzer report: `No issues found! (ran in 8.0s)`
- Automated test report: `00:59 +728: All tests passed!`
- Release metadata check: `scripts/verify_release_metadata.py -> PASS`
- Active build version: `1.0.173+173` (`pubspec.yaml`)
- Verification date: `2026-10-18`
