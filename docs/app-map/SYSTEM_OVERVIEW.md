# eCardo User App — Comprehensive System Overview & Architectural Blueprint

## 1. Architectural Topology
eCardo User App is a high-availability fintech and digital services application built on **Flutter (GetX framework)**.
- **State & Dependency Injection:** `GetX` (`GetView`, `GetxController`, `Bindings`, `Get.put/lazyPut`).
- **Navigation:** Declarative `GetPage` route tree in `routes_handler.dart` coupled with imperative `Get.to / Get.toNamed / Get.dialog / showModalBottomSheet`.
- **Networking:** REST API client via `Dio` with interceptors for token refresh, request idempotency, error normalization, and signature headers.
- **Localization:** 6 supported locales (`fa` default, `en`, `ar`, `tr`, `ru`, `zh`) with dynamic RTL/LTR support.
- **Design System:** Material 3 adaptation, high-contrast fintech tokens, custom glassmorphism, responsive screen utilities (`flutter_screenutil`), and Fluent UI system icons.

## 2. Discovered Functional Domains
| Domain | Total Accessible Screens | Architecture Responsibility |
|---|---|---|
| **Authentication & Onboarding** | 39 | Core business workflows and screen interfaces |
| **Cards Management** | 99 | Core business workflows and screen interfaces |
| **Commercial & Equity** | 27 | Core business workflows and screen interfaces |
| **Dashboard & Navigation** | 48 | Core business workflows and screen interfaces |
| **Exchange & Currency** | 26 | Core business workflows and screen interfaces |
| **General** | 39 | Core business workflows and screen interfaces |
| **Settings & Support** | 40 | Core business workflows and screen interfaces |
| **Transfers & Payments** | 171 | Core business workflows and screen interfaces |
| **Travel & Lifestyle** | 223 | Core business workflows and screen interfaces |
| **Wallets & Accounts** | 28 | Core business workflows and screen interfaces |
| **Total Accessible Surfaces** | **740** | **Full application inventory** |

## 3. High-Level Shell & Navigation Architecture
- **Root Entry:** `SplashScreen` -> checks session token & biometrics.
- **Auth Flow:** `IntroScreen` -> `LoginScreen` / `RegisterScreen` -> `OtpVerificationScreen` -> `PinSetupScreen`.
- **Main App Shell (`NavigationScreen`):** Persistent bottom navigation / quick action dock:
  1. **Home/Dashboard:** UID Pill, Quick Balance, 8-tile Quick Services Grid, Live Exchange, Recent Transactions.
  2. **Wallets:** Multi-currency balance cards, deposit, withdrawal, ledger history.
  3. **Cards:** Virtual & physical cards, PIN reveal, limits, freeze/unfreeze.
  4. **Transfers:** Internal transfers, Card-to-Card, IBAN (Paya/Satna), QR Pay.
  5. **History & Analytics:** Filterable financial statement, CSV/PDF export, receipt viewer.
  6. **Travel (eTrip):** Flights, Hotels, eSIM, Boat tours, Dining vouchers, Local experiences.
  7. **Commercial & Equity:** Investment crowdfunding projects, dividends, corporate cards.
  8. **Settings & Profile:** KYC tier status, 2FA, biometric authentication, language, support tickets.

## 4. Quality & Audit Gates
- All screens require state resilience: `Normal`, `Loading`, `Empty`, `Error`, `Offline`.
- Strict Zero-Decimal Toman formatting for IRR financial representations.
- Idempotent action dispatching on all transaction buttons.
