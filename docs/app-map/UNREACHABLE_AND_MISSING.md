# eCardo User App — Unreachable Screens & Incomplete Navigation Audit

## 1. Summary of Anomalies
- **Total Orphaned / Unreachable Screen Widgets:** 0
- **Broken Route Targets in Direct Navigations:** 0
- **Declared BaseRoutes without Handler Entry:** 0 (all 137 routes declared are registered in `routes_handler.dart`)

## 2. Orphaned / Unreachable Screen Classes
The following widgets extend Flutter screen types but are **never registered** in `routes_handler.dart` and are **never referenced** in any `Get.to`, `Get.dialog`, `showModalBottomSheet`, or parent build method. These represent dead code or unlinked prototypes:

| Screen Name | File Path | Inferred Domain | Base Class | Recommendation |
|---|---|---|---|---|

## 3. Incomplete Route Implementations & Missing Bindings
Found **12** `GetPage` routes with no explicit `binding`:
- `ROUTE-003` (BaseRoute.welcome): Screen `WelcomeScreen` in `lib/src/presentation/screens/authentication/welcome/view/welcome_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-029` (BaseRoute.permissionsSettings): Screen `PermissionsSettingsScreen` in `lib/src/presentation/screens/settings/view/permissions_settings_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-030` (BaseRoute.privacyPolicy): Screen `PrivacyPolicyScreen` in `lib/src/presentation/screens/settings/view/privacy_policy_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-031` (BaseRoute.deviceSessionsSecurity): Screen `DeviceSessionsSecurityScreen` in `lib/src/presentation/screens/device_sessions_security/view/device_sessions_security_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-039` (BaseRoute.replayTicket): Screen `ReplayTicket` in `lib/src/presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-058` (BaseRoute.noInternetConnection): Screen `NoInternetConnection` in `lib/src/presentation/widgets/no_internet_connection.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-059` (BaseRoute.billPayment): Screen `BillPaymentScreen` in `lib/src/presentation/screens/bill_payment/view/bill_payment_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-070` (BaseRoute.getCardInfo): Screen `GetCardInfo` in `lib/src/presentation/screens/virtual_card/view/get_card_info/get_card_info.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-074` (BaseRoute.maintenanceMode): Screen `MaintenanceMode` in `lib/src/presentation/widgets/maintenance_mode.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-084` (BaseRoute.upgradeRequired): Screen `UpgradeRequiredScreen` in `lib/src/presentation/screens/kyc_level/view/upgrade_required_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-086` (BaseRoute.localeTransition): Screen `LocaleTransitionScreen` in `lib/src/app/views/locale_transition_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
- `ROUTE-124` (BaseRoute.remittanceTrack): Screen `RemittanceTrackScreen` in `lib/src/remitv2/screens/remittance_track_screen.dart` (Controller may be initialized inline via `Get.put` or inherited from parent shell)
