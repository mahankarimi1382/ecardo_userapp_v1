# Navigation, Shell & Deep Link Audit (2026-10-20)

**Scope:** Inspection of `NavigationScreen`, route registration in `routes_handler.dart`, deep link intent filters, and notification routing.

---

## 1. Bottom Navigation Shell (`lib/src/app/navigation/navigation_screen.dart`)

### Architecture
- **Tab Setup:** 4 primary tabs via `AnimatedBottomNavigationBar`:
  1. Tab 0: Home Dashboard (`HomeScreen`)
  2. Tab 1: Transfer Money (`TransferScreen`)
  3. Tab 2: Virtual Cards (`VirtualCardScreen`)
  4. Tab 3: Account & Settings (`SettingsScreen`)
- **Central FAB Action:** Tapping central floating action button opens a frosted modal sheet with QR scanning options (Transfer, Pay Merchant, Agent Cash Out).
- **Lazy Tab Mount Optimization:**
  - Uses `_maxVisitedIndex` to defer widget instantiation of tabs 1..3 until first user visit. Once visited, pages remain keep-alive in the view hierarchy.
- **Architectural Issues:**
  - Line 60: The entire root `Scaffold` is wrapped inside an `Obx(() => ...)`. Any reactive change to `homeController` or `SettingsService` triggers a full recreation of the `Scaffold`, `AnimatedBottomNavigationBar`, and active tab body.
  - Line 349: Applies `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` unconditionally on every frame during content scroll, causing GPU compositor strain on low-end mobile devices.

---

## 2. Route Registration & Back Stack Integrity

### Route Inventory Parity
- **Declared in `BaseRoute` (`routes.dart`):** 136 constants.
- **Registered in `routes_handler.dart`:** 137 `GetPage` definitions (including `BaseRoute.noInternetConnection`).
- **Orphan Routes:** **0 orphaned routes.** Every declared route constant maps to a valid screen and is reachable either via `Get.toNamed` or the navigation shell.
- **Multi-Step Wizard Routing:** 11 complex flows (Transfer, Exchange, Withdraw, Cash Out, Add Money, Bill Payment, Gift Card, Registration, Forgot Password, KYC, Loans) use internal step state machines (`currentStep.value`) rather than push navigation, keeping the browser and mobile back stack clean.

---

## 3. Deep Linking & Notification Routing

### Android Manifest Intent Filters (`android/app/src/main/AndroidManifest.xml`)
- Custom URI scheme: `ecardo://` registered for auth redirects and payment gateway returns.
- App links host: `user.ecardo.ir` registered with `android:autoVerify="true"`.
- Launch mode: `singleTop` prevents duplicate app task creation when receiving external deep links.

### Push Payload Router (`lib/src/common/services/notification_router_helper.dart`)
- Validates payload structure before invoking navigation.
- Handled routes:
  - `transaction_details` -> routes to `BaseRoute.transactions` with highlighted reference.
  - `support_ticket` -> routes to `ReplayTicket` with `ticket_id`.
  - `kyc_update` -> routes to `BaseRoute.kycLevel`.
  - `promo` -> routes to `BaseRoute.services`.
- **Fail-Safe:** Any unrecognized payload falls back to `BaseRoute.navigation` rather than crashing the application.
