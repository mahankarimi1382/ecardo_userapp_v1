# ECARDO FLUTTER CODEBASE REALITY REPORT

## 1. Executive Architecture Summary
- **SDK & Build Versions**:
  - Flutter Version: `^3.22.x` (Inferred via dart SDK `^3.9.2` and comments hinting `Flutter 3.44.6` in `pubspec.yaml`, though `3.44` doesn't exist. Dart `3.9.2` means Flutter `3.29.x`).
  - Dart SDK: `^3.9.2`
  - Version: `1.0.89+89`
- **Core Architecture Patterns**:
  - The application relies heavily on **GetX** (`get: ^4.7.2`) for State Management, Dependency Injection (`Get.put`, `Get.find`, `GetxService`), and Routing (`GetMaterialApp`, `GetPage`, `Get.to`).
  - No `go_router` or `bloc`/`cubit` is used in this repository. All state and routing are managed via GetX Controllers/Bindings.
- **State Management Health**:
  - Widespread usage of GetX `Obx` and `Rx` variables for reactive UI.
  - **Issue**: Mixed usage of `Get.put` and Route Bindings (`routes_handler.dart`). Some views use `Get.find` directly, crashing if visited without the route binding (e.g., `remittance_details.dart:16`).
- **Build Configuration**:
  - `kDebugMode` is heavily used throughout the app (especially in `NetworkService`, `TokenService`, `FirebaseMessagingService`, and error handlers) to log debugging information (e.g., tokens, API requests, errors).

## 2. API & Network Catalog

| # | Feature / Module | HTTP Method | Endpoint Path | Caller File & Line | Status (Connected / Mock / Broken) |
|---|---|---|---|---|---|
| 1 | Auth (Login) | POST | `/api/auth/user/login` | `network_service.dart:154` | Connected (Base `https://ecardo.ir`) |
| 2 | Auth (Register) | POST | `/api/auth/user/register` | `network_service.dart:178` | Connected |
| 3 | Travel (Base) | GET/POST | `/api/v1/` | `travel_api_repository.dart:9` | Connected (`https://trip.ecardo.ir/api/v1`) |
| 4 | Exchange Fee | GET | `/` | `fee_ecardo_rate_source.dart:9` | Connected (`https://fee.ecardo.ir`) |
| 5 | Token Refresh | POST | `/api/auth/user/refresh` | `api_path.dart:167` | Connected |
| 6 | Bill Payments | POST | `/user/pay-bill` | `api_path.dart:104` | Connected / Broken Safeguards (No idempotency/timeout, bypassed) |
| 7 | Dynamic Password OTP | POST | `/pay/generate-otp` | `api_path.dart:45` | Broken (Hardcoded `404` found in `flow_test_report.md` probing) |
| 8 | Rate Alert | POST | `N/A` | `rate_alert_placeholder.dart:71` | Mocked (UI only, TODO backend) |
| 9 | Add/Edit Payment Account | POST/PUT | `/user/p2p/payment-accounts` | `add_payment_method_controller.dart:209` | Partial (Bypasses Dio wrappers, raw `Dio()`) |

## 3. Screen & User Journey Reality Matrix

*(Note: GetX is used instead of GoRouter. There are no Block/Cubit state managers, only GetX Controllers.)*

| Module | Screen Widget | Route Path | Auth Guard? | Backend Connected? | Notes / Mock Evidence |
|---|---|---|---|---|---|
| **Auth** | `SignInScreen` | `/sign_in_route` | Splash Gate | `REAL_API` | Biometrics guard is UI-based (`onTap`). `POST_NOTIFICATIONS` missing explicit runtime guard for Android 13+. |
| **Auth** | `AuthIdVerification` | `/auth_id_verification_route` | Splash Gate | `REAL_API` | - |
| **Travel** | `TravelScreen` | `/travel_route` | No (Bypass) | `REAL_API` / `MOCKED` | UI uses mock strings (e.g. `travelMockHotelEspinas`) in `travel_widgets.dart:18`. API is connected to `trip.ecardo.ir`. |
| **Wallet** | `WalletsScreen` | `/wallets_route` | Yes | `REAL_API` | Live rates. |
| **Exchange** | `ExchangeScreen` | `/exchange_route` | Yes | `PARTIAL` | Rate alert is completely non-functional (`rate_alert_placeholder.dart:71`). |
| **Remittance**| `RemittanceDetails` | `/remittance_details_route` | Yes | `REAL_API` | Dead deep-link route. Missing `GetPage` binding causes `Get.find` to crash. Hardcoded 2 decimal precision. |
| **P2P** | `P2PTrading` | `/p2p_trading_route` | Yes | `PARTIAL` | P2P apply_verification and payment_account screens use raw `Dio()` instances. |
| **Bill Payment**| `BillPaymentScreen`| `/bill_payment_route` | Yes | `BROKEN` | Lacks double-submit guard, balance guards, and state handling. Force unwraps `charge!` leading to crashes. |

## 4. Critical Security & Data Integrity Findings

- **Sensitive Data & Token Storage**:
  - `TokenService` correctly migrated from `SharedPreferences` to `FlutterSecureStorage` (in `token_service.dart:17`).
  - Passcode and App Locks use `FlutterSecureStorage` with `encryptedSharedPreferences: true`.
  - Some general settings are still saved in `SharedPreferences` (e.g., `AppUpdateController`).
- **Network Logger & PII leakage risks**:
  - In `network_service.dart:771`, HTTP Headers (Authorization) and Request Bodies (e.g., Login Passwords, Payment Data) are logged using `_log` and `jsonEncode`.
  - The `_log` function checks `kDebugMode` before printing. If `kDebugMode` is true (Dev/Staging), passwords, tokens, and PII are exposed in the standard output. The code redacts token length now (`<redacted X chars>`) but request bodies might still be exposed.
- **Hardcoded Secrets or Test Endpoints**:
  - Base URLs are hardcoded:
    - Main API: `https://ecardo.ir/api`
    - Travel API: `https://trip.ecardo.ir/api/v1`
    - Fee API: `https://fee.ecardo.ir`
  - There are no hardcoded Firebase secret keys directly in the repo (expects `firebase-credentials.json` or google-services config).

## 5. Incomplete, Mocked & Abandoned Code

- **Mocked/Stub UI Elements**:
  - **Rate Alert**: `rate_alert_placeholder.dart:71` is completely mocked. The UI shows "Coming soon" and the API call is marked as a `TODO`.
  - **Travel Mocks**: `travel_widgets.dart:18-29` contains explicit mock variables (`travelMockHotelEspinas`, `travelMockFlightTehranIstanbul`, etc.) mapped to translations, presumably to bypass missing inventory in staging.
- **Orphan Files and Dead Routes**:
  - Removed route constant: `BaseRoute.setPasscode` was removed (never used via GetPage).
  - Dead Routes: The routes for `invoice*` and `replayTicket` (M-6 in audit docs) fell through to `unknownRoute` (Splash). `BaseRoute.replayTicket` is registered inline but not perfectly mapped.
- **High-severity TODOs / FIXMEs**:
  - `remittance_details.dart:16` - `TODO(lead): add a RemittanceBinding`.
  - `remittance_controller.dart:694` - Hardcoded decimals: `TODO(lead): exchange-rate precision is not exposed`.
  - Multiple `force-unwrap` variables (`double.tryParse(x!)!`) in Request Money details, causing fatal crashes if data is missing.
  - Six controllers (Bill Payment, P2P Verification, Withdraw) use raw `dio.Dio()` bypassing the `NetworkService`, meaning they lack 401 token refresh loops, Idempotency-Keys, and connection timeouts.

## 6. Top 5 Urgent Blockers for the Product Owner

1. **[P0] Bill Payment & Network Bypasses (Broken Core Flow / Security)**
   - 6 Controllers (Airtime, Electricity, Internet, P2P Verification, Withdraw) instantiate a raw `Dio()` client. They bypass token refresh (401), Idempotency Keys (Double Submit protections), and Timeouts. Bill payments lack balance checks before submission.
2. **[P1] Missing Route Bindings Causing Crashes (Broken Core Flow)**
   - Deep-linking or navigating to `/remittance_details_route`, `/kyc_submit_wizard_route`, and `/dynamic_password_route` without previous controller initialization causes fatal crashes due to `Get.find` failing.
3. **[P1] Force-Unwrap Crashes in Financial Transactions (Data Integrity)**
   - Widespread use of `double.tryParse(...)!` in `VirtualCardDetails` and `RequestMoneyDetails`. If the backend returns `null` or a malformed string, the app throws a fatal exception.
4. **[P2] Dynamic Password (OTP) Endpoint 404 (Broken Feature)**
   - `POST /pay/generate-otp` is hardcoded outside of `ApiPath` and yields a 404 response on the server, rendering the "Dynamic Password" feature completely broken.
5. **[P2] Rate Alert (Incomplete Feature)**
   - The Rate Alert feature is purely visual (`rate_alert_placeholder.dart`) and functionally inert (mocked).