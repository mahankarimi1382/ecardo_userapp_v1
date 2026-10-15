# eCardo User App (v1) — Market Readiness & Localization Matrix

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa.md` — Phase 6 & Section 7  
**Inspected Commit SHA:** `d56ab71d293ca1c7ec29b63863ecbc40ca9c8d67`

---

## 1. Regional Market Matrix & Readiness Status

| Market / Region | Locale | Primary Font | Currency | Calendar | Banking / Payment Capabilities | Readiness Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Iran (Primary Domestic)** | `fa` | `Vazirmatn` | IRT / IRR | Shamsi (Jalali) | Sheba (IBAN), 16-digit bank cards, Zarinpal/Saman gateway redirect via hardened WebView | **Production Ready** |
| **UAE & Arab Region** | `ar` | `Vazirmatn` | AED / USD | Gregorian | Multi-currency virtual cards, P2P fiat/crypto, international wire | **Ready for Beta** |
| **Turkey** | `tr` | `Plus Jakarta Sans` | TRY / USD | Gregorian | Virtual cards, P2P crypto, travel bookings | **Ready for Beta** |
| **Russia & CIS** | `ru` | `NotoSansRU` | RUB / USDT | Gregorian | P2P crypto/fiat, virtual cards, travel services | **Ready for Beta** |
| **China** | `zh` | System CJK | CNY / USDT | Gregorian | UnionPay virtual card issuance, P2P escrow | **Ready for Beta** |
| **International / Global** | `en` | `Plus Jakarta Sans` | USD / EUR | Gregorian | Visa / Mastercard virtual cards, crypto, global remittance | **Production Ready** |

---

## 2. Localization Implementation Verification

### 2.1 Language ARB Files & Code Generation
Verified files in `lib/l10n/`:
- `app_fa.arb` (184 KB — comprehensive Persian keys for financial, travel, and security flows)
- `app_en.arb` (152 KB — master English reference)
- `app_ar.arb` (178 KB — complete Arabic translations)
- `app_ru.arb` (194 KB — Russian translations)
- `app_tr.arb` (155 KB — Turkish translations)
- `app_zh.arb` (146 KB — Chinese translations)
All generated localizations are compiled into `lib/l10n/app_localizations_*.dart` and verified by `flutter gen-l10n`.

### 2.2 RTL & BiDi Layout Safety
- Font family `Vazirmatn` is embedded in `assets/fonts/Vazirmatn-Regular.ttf` and linked in `pubspec.yaml:111-113`.
- BiDi rate displays in `/exchange` (commit `6b3aab0`) and wallet carousel flip cards (`test/wallet_card_rtl_test.dart`) ensure numeric strings and currency tickers do not flip unexpectedly in RTL contexts.
- Direction-aware arrow icons invert for RTL while non-directional media icons remain fixed.

### 2.3 Shamsi (Jalali) Date Engine
- Implementation: `lib/src/helper/jalali_date_helper.dart` using the `shamsi_date` package.
- Timezone: Server UTC timestamps are accurately shifted to Asia/Tehran (+03:30).
- Relative date formatting: "امروز HH:mm" (Today), "دیروز HH:mm" (Yesterday), and "YYYY/MM/DD - HH:mm".
- Travel & Flights: Integrated modernized Shamsi date picker bottom sheet with Gregorian/Jalali toggle in `flight_search_screen.dart:2191`.

---

## 3. Payment & Banking Integrations

### 3.1 Iranian Banking Rails
- **Sheba Validation:** `lib/src/presentation/screens/withdraw/` formats and validates Sheba entries against Iranian banking standards.
- **Card Masking:** PII safety checks mask 16-digit debit cards to format `6037-99**-****-1234` in list items and receipts (`test/withdraw_modernization_qc_test.dart`).
- **Payment Gateway WebViews:** `lib/src/presentation/widgets/web_view_screen.dart` isolates hosted payment redirects, queries backend verification before releasing state, and blocks cleartext traffic.

### 3.2 Virtual Card & International Rails
- Supports multi-currency virtual card issuance (Visa, Mastercard) funded adaptively from user fiat/crypto wallets (`lib/src/presentation/screens/virtual_card/`).
- Cardholder details and CVVs are hidden by default behind an on-demand security disclosure gate.
