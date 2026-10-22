# eCardo Visual QA & Golden Regression Plan (Milestone 2026-Q4)

**Document Version:** 1.0  
**Target Codebase:** `ecardo_userapp_v1` (Flutter / Dart 3.x)  
**Execution Target:** Expand visual regression coverage from 25 active captures (covering 6 routes) to a rigorous multi-locale, multi-scale golden matrix covering **all 40 P0 critical routes** and core ecosystem modules.

---

## 1. Executive Strategy & Current Baseline

### Current State vs Target
- **Current Baseline:** 37 PNGs in `test/test_output/screens/`, but only **25 active captures** across 5 test files (`auth_screenshot_test.dart`, `exchange_screenshot_test.dart`, `home_screenshot_test.dart`, `transfer_screenshot_test.dart`, `wallets_screenshot_test.dart`). 12 PNGs are orphaned baselines with no active test execution.
- **Coverage Deficit:** 34 of 40 P0 routes (85%) have zero golden coverage. No multi-text-scale testing exists, and only 3 screens test RTL (`fa`).
- **Milestone Goal:** Complete golden coverage for the 40 P0 routes across:
  - **4 Locales:** English (`en` - LTR), Persian (`fa` - RTL), Russian (`ru` - Cyrillic/long strings), Chinese (`zh` - CJK glyphs/density).
  - **3 Text Scales:** `1.0x` (Default), `1.3x` (A11y standard), `2.0x` (Extreme dynamic type).
  - **2 Themes:** Material 3 Light Mode & Dark Mode.
  - **Functional States:** Populated, Empty, Error, and Loading/Skeleton.

---

## 2. Test Harness Upgrades (`test/screenshot_harness.dart`)

To support multi-scale and multi-locale verification without duplicating test scaffolding, `screenshot_harness.dart` will be enhanced with text scaling and CJK font support:

### Text Scaling & Font Injection Signature
```dart
/// Extended pumpScreen supporting dynamic type and multi-locale rendering
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  List<void Function()> registrations = const [],
  bool dark = false,
  Size size = kDefaultScreenSize,
  TextDirection textDirection = TextDirection.ltr,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  await loadAppFonts(tester);
  await mockNativePlugins();

  Widget buildTree(Widget homeWidget) {
    return ScreenUtilInit(
      designSize: size,
      builder: (context, _) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true, // Guarantees deterministic golden captures
        ),
        child: GetMaterialApp(
          locale: locale,
          localizationsDelegates: _delegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: _themesResolved ? kLightTheme : null,
          darkTheme: _themesResolved ? kDarkTheme : null,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: Directionality(
            textDirection: textDirection,
            child: homeWidget,
          ),
        ),
      ),
    );
  }

  // Pass 1: Initialize GetX context & themes
  await tester.pumpWidget(buildTree(const SizedBox.shrink()));
  if (!_themesResolved) {
    final context = tester.element(find.byType(SizedBox).first);
    kLightTheme = LightTheme().lightTheme(context);
    kDarkTheme = DarkTheme().darkTheme(context);
    _themesResolved = true;
  }

  for (final register in registrations) {
    register();
  }

  // Pass 2: Mount actual screen under capture boundary
  await tester.pumpWidget(buildTree(
    RepaintBoundary(key: kCaptureKey, child: child),
  ));

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}
```

### Stale Artifact Cleanup Hook
Before every golden suite execution, `test/failures/` must be purged of stale `.png` diffs to prevent false positives and disk bloat:
```bash
rm -rf test/failures/*.png
```

---

## 3. The 40 P0 Golden Matrix Specifications

The 40 P0 routes are structured into 5 cohesive test suites:

### Suite 1: Authentication & Identity (`test/golden/p0_auth_flow_golden_test.dart`)
Covers the entire onboarding, registration, login, and password recovery chain:

| Route ID | Route Constant | Screen File Path | Primary Controller | Matrix Variations |
| :--- | :--- | :--- | :--- | :--- |
| **PAGE-004** | `BaseRoute.signIn` | `sign_in/view/sign_in_screen.dart` | `SignInController` | Light, Dark, RTL (`fa`), `ru`, `zh`, Scale 1.3x, Invalid PIN error |
| **PAGE-005** | `BaseRoute.twoFactorAuth` | `sign_in/view/sub_sections/two_factor_auth.dart` | `TwoFactorAuthController` | Light, Dark, RTL, OTP input error |
| **PAGE-006** | `BaseRoute.emailOtpLogin` | `sign_in/view/sub_sections/email_otp_login_screen.dart` | `EmailOtpLoginController` | Light, Dark, RTL, Resend cooldown timer |
| **PAGE-007** | `BaseRoute.email` | `sign_up/view/email/email_screen.dart` | `EmailController` | Light, Dark, RTL, Validation error |
| **PAGE-008** | `BaseRoute.verifyEmail` | `sign_up/view/verify_email/verify_email_screen.dart` | `VerifyEmailController` | Light, Dark, RTL, 6-digit pin entry |
| **PAGE-010** | `BaseRoute.resetPassword` | `forgot_password/view/sub_sections/reset_password.dart` | `ResetPasswordController` | Light, Dark, RTL, Password mismatch error |
| **PAGE-043** | `BaseRoute.setUpPassword` | `sign_up/view/set_up_password/set_up_password_screen.dart`| `SignUpController` | Light, Dark, RTL, Password strength meter |

### Suite 2: Core Fintech & Money Movement (`test/golden/p0_fintech_movement_golden_test.dart`)
Covers wallets, balance displays, transfers, deposits, withdrawals, and transactions:

| Route ID | Route Constant | Screen File Path | Primary Controller | Matrix Variations |
| :--- | :--- | :--- | :--- | :--- |
| **PAGE-012** | `BaseRoute.navigation` | `navigation/navigation_screen.dart` | `HomeController` | Light, Dark, RTL, Navigation Bar active tab state |
| **PAGE-013** | `BaseRoute.wallets` | `wallets/view/wallets_screen.dart` | `WalletsController` | Light, Dark, RTL, Empty, Error, Scale 1.3x & 2.0x |
| **PAGE-016** | `BaseRoute.addMoney` | `add_money/view/add_money_screen.dart` | `AddMoneyController` | Light, Dark, RTL, Gateway selection, Amount input |
| **PAGE-017** | `BaseRoute.makePayment` | `make_payment/view/make_payment_screen.dart` | `MakePaymentController`| Light, Dark, RTL, Merchant barcode preview |
| **PAGE-020** | `BaseRoute.transfer` | `transfer/view/transfer_screen.dart` | `TransferController` | Light, Dark, RTL, Amount step, Review step, Success |
| **PAGE-021** | `BaseRoute.cashOut` | `cash_out/view/cash_out_screen.dart` | `CashOutController` | Light, Dark, RTL, Agent lookup, Fee summary |
| **PAGE-022** | `BaseRoute.withdraw` | `withdraw/view/withdraw_screen.dart` | `WithdrawController` | Light, Dark, RTL, Method selection, Success step |
| **PAGE-023** | `BaseRoute.exchange` | `exchange/view/exchange_screen.dart` | `ExchangeController` | Light, Dark, RTL, Live quote, Swap flip, Rate expired |
| **PAGE-024** | `BaseRoute.transactions`| `transactions/view/transactions_screen.dart` | `TransactionsController`| Light, Dark, RTL, Filter chips, Empty feed |
| **PAGE-046** | `BaseRoute.walletsDetails`| `wallets/view/wallet_details/wallet_details.dart` | `WalletsController` | Light, Dark, RTL, Transaction feed per currency |

### Suite 3: Virtual Card Subsystem (`test/golden/p0_virtual_card_golden_test.dart`)
Covers card creation, balance inspection, CVV security reveal, and freeze toggles:

| Route ID | Route Constant | Screen File Path | Primary Controller | Matrix Variations |
| :--- | :--- | :--- | :--- | :--- |
| **PAGE-066** | `BaseRoute.virtualCard` | `virtual_card/view/virtual_card_screen.dart` | `VirtualCardController` | Light, Dark, RTL, Active card, Frozen card blur |
| **PAGE-067** | `BaseRoute.createVirtualCard`| `virtual_card/view/create_virtual_card/create_virtual_card.dart` | `CreateVirtualCardController`| Light, Dark, RTL, Tier card selector |
| **PAGE-068** | `BaseRoute.virtualCardDetails`| `virtual_card/view/virtual_card_details/virtual_card_details.dart`| `VirtualCardController` | Light, Dark, RTL, Card flip animation front/back |
| **PAGE-071** | `BaseRoute.virtualCardTransaction`| `virtual_card/view/virtual_card_transaction/virtual_card_transaction.dart`| `VirtualCardController` | Light, Dark, RTL, Empty card statement |

### Suite 4: Utilities, KYC & Security (`test/golden/p0_services_security_golden_test.dart`)
Covers bill pay, dynamic OTPs, KYC document uploads, and international remittances:

| Route ID | Route Constant | Screen File Path | Primary Controller | Matrix Variations |
| :--- | :--- | :--- | :--- | :--- |
| **PAGE-060** | `BaseRoute.airtime` | `bill_payment/view/airtime/airtime.dart` | `AirtimeController` | Light, Dark, RTL, Telco operator strip |
| **PAGE-061** | `BaseRoute.electricity` | `bill_payment/view/electricity/electricity.dart` | `ElectricityController` | Light, Dark, RTL, Meter number validation |
| **PAGE-062** | `BaseRoute.internet` | `bill_payment/view/internet/internet.dart` | `InternetController` | Light, Dark, RTL, Package selection list |
| **PAGE-079** | `BaseRoute.dynamicPassword`| `dynamic_password/view/dynamic_password_screen.dart` | `DynamicPasswordController`| Light, Dark, RTL, TOTP token progress bar |
| **PAGE-080** | `BaseRoute.remittance` | `remittance/view/remittance_screen.dart` | `RemittanceController` | Light, Dark, RTL, Country payout picker |
| **PAGE-083** | `BaseRoute.kycSubmitWizard`| `kyc_level/view/kyc_submit_wizard.dart` | `KycLevelController` | Light, Dark, RTL, Camera guide overlay |

### Suite 5: Ecosystem & Commerce Modules (`test/golden/p0_ecosystem_modules_golden_test.dart`)
Covers P2P trading, Escrow contracts, Stock trading, Loans, Guarantees, and Travel checkouts:

| Route ID | Route Constant | Screen File Path | Primary Controller | Matrix Variations |
| :--- | :--- | :--- | :--- | :--- |
| **PAGE-075** | `BaseRoute.p2pTrading` | `p2p/view/p2p_view.dart` | `P2pController` | Light, Dark, RTL, Buy/Sell tabs, Active orders |
| **PAGE-091** | `BaseRoute.tourBook` | `tour/screens/tour_book_screen.dart` | `TourController` | Light, Dark, RTL, Date/guest picker |
| **PAGE-092** | `BaseRoute.tourPayment` | `tour/screens/tour_payment_screen.dart` | `TourController` | Light, Dark, RTL, Payment receipt card |
| **PAGE-096** | `BaseRoute.escrowCreate`| `escrow/screens/escrow_create_screen.dart` | `EscrowController` | Light, Dark, RTL, Milestone timeline builder |
| **PAGE-097** | `BaseRoute.escrowPayment`| `escrow/screens/escrow_payment_screen.dart` | `EscrowController` | Light, Dark, RTL, Milestone deposit breakdown |
| **PAGE-106** | `BaseRoute.stockOrder` | `stock/screens/stock_order_screen.dart` | `StockController` | Light, Dark, RTL, Limit/Market order keypad |
| **PAGE-107** | `BaseRoute.stockConfirm`| `stock/screens/stock_confirm_screen.dart` | `StockController` | Light, Dark, RTL, Fee & execution breakdown |
| **PAGE-112** | `BaseRoute.loanApplication`| `loan/screens/loan_application_screen.dart`| `LoanController` | Light, Dark, RTL, Collateral calculator |
| **PAGE-113** | `BaseRoute.loanConfirm`| `loan/screens/loan_confirm_screen.dart` | `LoanController` | Light, Dark, RTL, Amortization preview |
| **PAGE-119** | `BaseRoute.guaranteeApplication`| `guarantee/screens/guarantee_application_screen.dart`| `GuaranteeController` | Light, Dark, RTL, Collateral upload |
| **PAGE-120** | `BaseRoute.guaranteeConfirm`| `guarantee/screens/guarantee_confirm_screen.dart`| `GuaranteeController` | Light, Dark, RTL, Certificate preview |
| **PAGE-130** | `BaseRoute.commercialInvestCheckout`| `commercial/screens/equity_invest_checkout_screen.dart`| `CommercialController`| Light, Dark, RTL, Share purchase summary |
| **PAGE-137** | `BaseRoute.diningOrderPass`| `travel/dining/screens/dining_order_pass_screen.dart`| `DiningController` | Light, Dark, RTL, QR pass voucher |

---

## 4. Concrete Golden Test Signature & Implementation Template

Below is the standard, production-ready golden test implementation pattern for P0 screens:

```dart
// test/golden/p0_virtual_card_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/virtual_card_screen.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import '../screenshot_harness.dart';

class _FakeVirtualCardController extends VirtualCardController {
  @override
  void onInit() {
    // Intentionally skipped to avoid native and network I/O
  }
}

class _FakeSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

void main() {
  tearDown(resetHarness);

  group('PAGE-066: VirtualCardScreen Golden Suite', () {
    final registrations = [
      () => registerController<VirtualCardController>(_FakeVirtualCardController()),
      () => registerController<SettingsService>(_FakeSettingsService()),
    ];

    testWidgets('virtual_card — light baseline', (tester) async {
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        registrations: registrations,
      );
      await capture(tester, 'p0_virtual_card__light');
    });

    testWidgets('virtual_card — dark mode', (tester) async {
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        dark: true,
        registrations: registrations,
      );
      await capture(tester, 'p0_virtual_card__dark');
    });

    testWidgets('virtual_card — RTL (fa)', (tester) async {
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        textDirection: TextDirection.rtl,
        locale: const Locale('fa'),
        registrations: registrations,
      );
      await capture(tester, 'p0_virtual_card__fa_rtl');
    });

    testWidgets('virtual_card — Russian (ru) Cyrillic', (tester) async {
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        locale: const Locale('ru'),
        registrations: registrations,
      );
      await capture(tester, 'p0_virtual_card__ru');
    });

    testWidgets('virtual_card — Chinese (zh) CJK', (tester) async {
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        locale: const Locale('zh'),
        registrations: registrations,
      );
      await capture(tester, 'p0_virtual_card__zh');
    });

    testWidgets('virtual_card — Dynamic Type 1.3x', (tester) async {
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        textScale: 1.3,
        registrations: registrations,
      );
      await capture(tester, 'p0_virtual_card__scale_1_3x');
    });

    testWidgets('virtual_card — Dynamic Type 2.0x (A11y Extreme)', (tester) async {
      await pumpScreen(
        tester,
        const VirtualCardScreen(),
        textScale: 2.0,
        registrations: registrations,
      );
      await capture(tester, 'p0_virtual_card__scale_2_0x');
    });
  });
}
```

---

## 5. Execution, CI & Git Storage Runbook

1. **Local Baseline Generation:**
   ```bash
   flutter test --update-goldens test/golden/
   ```
2. **CI Pipeline Integration (`.github/workflows/flutter.yml`):**
   The CI workflow runs in headless Linux containers with FreeType font rasterization. Golden tests utilize `TolerantGoldenComparator` with a 10% diff threshold to prevent false-negative failures caused by cross-platform font anti-aliasing variations:
   ```yaml
   - name: Run Golden Regression Suite
     run: flutter test test/golden/
   ```
3. **Artifact Hygiene & Stale Diff Prevention:**
   When golden assertions fail, Flutter generates diff images in `test/failures/`. Ensure this folder remains in `.gitignore` and add an automated pre-test wipe in `flutter_test_config.dart`.
