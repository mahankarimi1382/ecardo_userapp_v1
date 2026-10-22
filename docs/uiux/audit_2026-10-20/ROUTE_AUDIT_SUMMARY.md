# Route & CTA Audit Summary (Top 10 Findings)

| Rank | Sev | File:Line | Issue | Remediation Fix |
| :---: | :---: | :--- | :--- | :--- |
| **1** | **P0** | `android/app/src/main/AndroidManifest.xml:53` | No OS deep links (`intent-filter`); external links fail to launch app. | Add `VIEW` intent-filter for `https://ecardo.ir` and `ecardo://` scheme. |
| **2** | **P0** | `lib/src/app/navigation/navigation_screen.dart:84` | Missing `PopScope` on shell; pressing back on tabs 1..3 exits app. | Wrap Scaffold in `PopScope` resetting `homeController.selectedIndex` to 0. |
| **3** | **P0** | `lib/src/app/routes/routes_config.dart:282` | 44 route constants bypassed via direct `Get.to(() => ...)` closures. | Refactor direct screen pushes to `Get.toNamed(BaseRoute.<constant>)`. |
| **4** | **P1** | `lib/src/presentation/screens/home/view/sub_sections/drawer/end_drawer_section.dart:266` | Biometric switch tile row has dead `onPressed: () {}`. | Bind `onPressed` to `await homeController.toggleBiometric()`. |
| **5** | **P1** | `lib/src/presentation/screens/travel/flights/flight_screens.dart:1621` | Outbound flight offer card has dead `onTap: () {}`. | Bind `onTap` to push flight details and fare breakdown sheet. |
| **6** | **P1** | `lib/src/commercial/widgets/investment_calculator_sheet.dart:387` | Equity crowdfunding "Register Interest" runs client-only toast simulation. | Wire to backend lead capture API `/user/commercial/register-interest`. |
| **7** | **P1** | `lib/src/presentation/screens/travel/boat/controllers/boat_controller.dart:386` | Boat bookings execute local mock simulation (`// DATA: MOCK`). | Wire travel domain endpoints on `trip.ecardo.ir` / `TravelApiRepository`. |
| **8** | **P1** | `lib/src/presentation/screens/travel/dining/controllers/dining_controller.dart:365` | In-transit dining orders simulate bookings on mock dataset (`// DATA: MOCK`). | Register dining domain on `trip.ecardo.ir` or gate behind coming-soon state. |
| **9** | **P1** | `lib/src/presentation/screens/travel/insurance/insurance_service.dart:194` | Insurance claims generate deterministic mock claim ID (`// DATA: MOCK`). | Implement real claim submission endpoint in `ApiPath` with receipt upload. |
| **10** | **P1** | `lib/src/presentation/screens/home/view/sub_sections/balance_hero_section.dart:62` | Multi-currency hero falls back to hardcoded `95000.0` when rates missing. | Render `≈ -- Toman` instead of hardcoded fallback when rate is null/zero. |

**Audit Totals:** 137 routes audited; 137 screen files verified; 44 bypassed route constants; 2 dead handlers; 4 mock travel domains; 0 broken `Get.toNamed` targets.
