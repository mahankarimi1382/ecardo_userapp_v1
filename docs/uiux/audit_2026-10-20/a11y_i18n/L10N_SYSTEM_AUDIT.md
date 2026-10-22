# Localization System Audit (ARB vs l10nPick)

**Document Date:** 2026-10-20  
**Target Codebase:** `ecardo_userapp_v1` (Flutter, Dart)  
**Target Version:** 1.0.174+174  
**Auditor:** Quality & Architecture Engineering

---

## 1. Executive Summary

The application currently operates under two diverging, uncoordinated localization architectures:

1. **System A (Official Flutter ARB Architecture):**
   - Source catalogs: `lib/l10n/app_{en,fa,ar,tr,ru,zh}.arb`
   - Generated classes: `lib/l10n/app_localizations*.dart`
   - Scope: Exactly 2,700 keys per locale across all 6 supported languages (`en`, `fa`, `ar`, `tr`, `ru`, `zh`).
   - Parity: 100% key parity across all 6 locales (0 missing keys vs `en`).

2. **System B (Ad-Hoc `l10nPick` / `l10nPickAuto` Architecture):**
   - Source helper: `lib/src/helper/l10n_pick.dart`
   - Call sites: 3,057 invocations across 261 Dart files.
   - Design flaw: Only `en` and `fa` parameters are `required`. The arguments `ar`, `tr`, `ru`, and `zh` are optional and silently fallback to `en` via null-coalescing operators (`ar ?? en`, `tr ?? en`, `ru ?? en`, `zh ?? en`).
   - Resulting translation gaps:
     * **Turkish (`tr`):** 2,476 call sites missing (81.0% silent fallback to English)
     * **Russian (`ru`):** 2,476 call sites missing (81.0% silent fallback to English)
     * **Chinese (`zh`):** 1,464 call sites missing (47.9% silent fallback to English)
     * **Arabic (`ar`):** 1,039 call sites missing (34.0% silent fallback to English)
     * **Persian / English only:** 1,039 call sites (34.0% of all calls offer no other language)
     * **Fully translated (all 6 locales):** Only 483 call sites (15.8%)

The coexistence of both systems introduces severe UX regressions for non-English/non-Persian users, inconsistent terminology, memory bloat, and maintenance overhead.

---

## 2. Root Cause Analysis: How Two Parallel Systems Emerged

### 2.1 The Misleading Comment in `l10n.yaml`
In `l10n.yaml` (lines 6-12), the configuration states:
```yaml
# In Flutter 3.44+ synthetic-package is deprecated and ignored —
# generated files always go to output-dir (defaults to lib/l10n).
# The checked-in app_localizations*.dart files in this repo are STALE
# (last regenerated in commit 056a6e5, before the exchange redesign
# added new .arb keys). The CI runs flutter gen-l10n on every build,
# which regenerates them in-place. New code should NOT rely on
# AppLocalizations getters added after 056a6e5 — use a hardcoded
# locale-aware helper instead until the localizations are regenerated
# and re-checked-in.
```

### 2.2 Chronological Timeline
1. **Commit `056a6e5` (v1.0.18 era):** Remittance module introduced 50+ ARB keys. The warning note was placed in `l10n.yaml` warning developers not to commit broken builds if `flutter gen-l10n` was not run locally.
2. **Introduction of `l10nPick`:** To bypass running `flutter gen-l10n` on developer workstations, `l10nPick` was authored in `lib/src/helper/l10n_pick.dart`. It allowed inline strings without code generation.
3. **Subsequent Commits:** Multiple integration commits (e.g. `93988fb`, `5b8acdc`, `5130211`, `560eb7a`, `fa65138`, `1ffc4c7`, `9039fa5`, `540d470`) DID run code generation and committed updated `app_localizations*.dart` files up to 2,700 keys.
4. **Current State:** The checked-in `app_localizations*.dart` files are **NOT stale**. All 2,700 keys in `app_en.arb` match `app_localizations.dart` and each locale-specific implementation file (`app_localizations_fa.dart`, etc.) exactly. However, because the warning in `l10n.yaml` remained, developers continued creating new features (travel, commercial projects, device security, loans, escrow) exclusively using `l10nPick`.

---

## 3. System A Audit: ARB Catalogs & Generated Files

### 3.1 Key Metrics
- **Catalog Directory:** `lib/l10n/`
- **Total Keys:** 2,700 per locale
- **Key Completeness:**

| Locale | ARB File | Key Count | Missing vs EN | Extra vs EN | Status |
|---|---|---|---|---|---|
| English (`en`) | `app_en.arb` | 2,700 | 0 (template) | 0 | Base |
| Persian (`fa`) | `app_fa.arb` | 2,700 | 0 | 0 | 100% Synced |
| Arabic (`ar`) | `app_ar.arb` | 2,700 | 0 | 0 | 100% Synced |
| Turkish (`tr`) | `app_tr.arb` | 2,700 | 0 | 0 | 100% Synced |
| Russian (`ru`) | `app_ru.arb` | 2,700 | 0 | 0 | 100% Synced |
| Chinese (`zh`) | `app_zh.arb` | 2,700 | 0 | 0 | 100% Synced |

### 3.2 Generated Dart Files
- `lib/l10n/app_localizations.dart`: 2,622 property getters, 78 parameterized methods = 2,700 total members.
- `lib/l10n/app_localizations_en.dart`: 2,700 implementations.
- `lib/l10n/app_localizations_fa.dart`: 2,700 implementations.
- `lib/l10n/app_localizations_ar.dart`: 2,700 implementations.
- `lib/l10n/app_localizations_tr.dart`: 2,700 implementations.
- `lib/l10n/app_localizations_ru.dart`: 2,700 implementations.
- `lib/l10n/app_localizations_zh.dart`: 2,700 implementations.
- **Dart to ARB synchronization error:** 0 keys missing, 0 keys extra.

### 3.3 Untranslated Keys in ARB Catalogs
While all keys exist, several keys contain identical English values across foreign catalogs. Excluding 240+ section markers (`comment_*`) and standard financial acronyms (`CVV`, `PIN`, `OTP`, `USD`), the following user-facing strings remain in English:

1. **Persian (`app_fa.arb`):**
   - `cashOutAid`: `'AID:'` (Agent ID label)
   - `userProfileUid`: `'UID:'` (User ID label)
   - `makePaymentAmountStepSectionMidLabel`: `'MID:'` (Merchant ID label)
   - `transferAmountStepSectionUidLabel`: `'UID:'`
   - `travelTitle`: `'eCardo Travel'`
   - `travelEsim`: `'eSIM'`
   - `travelMockAirlineOne`: `'eCardo Air'`
   - `travelMockAirlineTwo`: `'Atlas Airways'`

2. **Turkish (`app_tr.arb`):**
   - `invoiceDetailsReference` / `invoicePdfReference`: `'Ref:'`
   - `idVerificationScreenTitle`: `'KYC'` (instead of `'Kimlik Doğrulama'`)
   - `p2pLimit`: `'Limit'`
   - `p2pFiat`: `'Fiat'`
   - `travelBusiness`: `'Business'` (instead of `'İş'`)
   - `kycFeatureTransfer` / `kycLimitGroupTransfer`: `'Transfer'` (instead of `'Havale / Transfer'`)
   - `travelMockCurrency`: `'Toman'`

3. **Russian (`app_ru.arb`):**
   - `forgotPasswordEmail` / `emailScreenEmail` / `createCardHolderLabelEmail` / `giftCardEmailLabel`: `'Email'` (instead of `'Электронная почта'`)
   - `idVerificationScreenTitle`: `'KYC'` (instead of `'Верификация личности'`)

4. **Chinese (`app_zh.arb`):**
   - `invoiceDetailsReference` / `invoicePdfReference`: `'Ref:'`
   - `idVerificationScreenTitle`: `'KYC'` (instead of `'身份认证'`)

---

## 4. System B Audit: `l10nPick` & `l10nPickAuto`

### 4.1 Implementation Flaw in `lib/src/helper/l10n_pick.dart`
```dart
String l10nPick(
  BuildContext context, {
  required String en,
  required String fa,
  String? ar,
  String? tr,
  String? ru,
  String? zh,
}) {
  final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  switch (locale) {
    case 'fa':
      return fa;
    case 'ar':
      return ar ?? en; // SILENT FALLBACK TO ENGLISH
    case 'tr':
      return tr ?? en; // SILENT FALLBACK TO ENGLISH
    case 'ru':
      return ru ?? en; // SILENT FALLBACK TO ENGLISH
    case 'zh':
      return zh ?? en; // SILENT FALLBACK TO ENGLISH
    case 'en':
    default:
      return en;
  }
}
```

Because `ar`, `tr`, `ru`, and `zh` default to `null` and fallback to `en`, the compiler never enforces translation completeness. Developers writing new UI features repeatedly provide only `en:` and `fa:`.

### 4.2 Codebase Scan Results (3,057 Total Call Sites in 261 Files)

| Metric | Count | Percentage |
|---|---|---|
| Total `l10nPick` / `l10nPickAuto` call sites | 3,057 | 100.0% |
| Calls providing English (`en`) | 3,057 | 100.0% |
| Calls providing Persian (`fa`) | 3,057 | 100.0% |
| Calls providing Arabic (`ar`) | 2,018 | 66.0% |
| Calls providing Chinese (`zh`) | 1,593 | 52.1% |
| Calls providing Turkish (`tr`) | 581 | 19.0% |
| Calls providing Russian (`ru`) | 581 | 19.0% |
| **Calls providing ALL 6 locales** | **483** | **15.8%** |
| **Calls missing at least one locale** | **2,574** | **84.2%** |
| **Calls providing ONLY `en` + `fa`** | **1,039** | **34.0%** |

### 4.3 Breakdown of Missing Arguments Across 2,574 Incomplete Calls
- **Missing `tr` and `ru` (while having en, fa, ar, zh):** 1,110 call sites
- **Missing `ar`, `tr`, `ru`, and `zh` (en + fa only):** 1,039 call sites
- **Missing `tr`, `ru`, and `zh` (en, fa, ar only):** 327 call sites
- **Missing `zh` only:** 98 call sites

### 4.4 Top 20 Files with Incomplete `l10nPick` Calls
1. `lib/src/presentation/screens/settings/view/settings_screen.dart` — 91 incomplete calls
2. `lib/src/rental/screens/rental_detail_screen.dart` — 70 incomplete calls
3. `lib/src/presentation/screens/travel/insurance/insurance_screens.dart` — 68 incomplete calls
4. `lib/src/guarantee/screens/guarantee_detail_screen.dart` — 47 incomplete calls
5. `lib/src/presentation/screens/travel/flights/flight_search_screen.dart` — 46 incomplete calls
6. `lib/src/presentation/screens/device_sessions_security/view/device_sessions_security_screen.dart` — 44 incomplete calls
7. `lib/src/presentation/screens/kyc_level/view/kyc_level_roadmap.dart` — 39 incomplete calls
8. `lib/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart` — 37 incomplete calls
9. `lib/src/remitv2/screens/remittance_track_screen.dart` — 37 incomplete calls
10. `lib/src/loan/widgets/loan_status_stepper.dart` — 36 incomplete calls
11. `lib/src/loan/widgets/loan_amortization_schedule.dart` — 35 incomplete calls
12. `lib/src/presentation/screens/travel/flights/flight_detail_screen.dart` — 35 incomplete calls
13. `lib/src/presentation/screens/travel/taxi/taxi_voucher_screen.dart` — 35 incomplete calls
14. `lib/src/visa/screens/visa_detail_screen.dart` — 30 incomplete calls
15. `lib/src/presentation/screens/travel/esim/esim_detail_screen.dart` — 28 incomplete calls
16. `lib/src/presentation/screens/travel/insurance/insurance_claim_screen.dart` — 28 incomplete calls
17. `lib/src/rental/screens/rental_home_screen.dart` — 28 incomplete calls
18. `lib/src/loan/screens/loan_collateral_warning_screen.dart` — 27 incomplete calls
19. `lib/src/guarantee/screens/guarantee_called_screen.dart` — 26 incomplete calls
20. `lib/src/stock/screens/stock_home_screen.dart` — 26 incomplete calls

---

## 5. Architectural Comparison: System A vs System B

| Dimension | System A (`AppLocalizations` / ARB) | System B (`l10nPick` / Helper) |
|---|---|---|
| **Compilation Safety** | High (missing keys in ARB fail codegen; Dart analyzer warns on missing getters) | Zero (optional arguments compile cleanly; missing strings fail at runtime silently) |
| **Translation Parity** | 100% across all 6 locales (2,700 keys) | 15.8% (Turkish/Russian missing in 81% of call sites) |
| **Memory Footprint** | Low (singleton lookup via `Localizations.of`) | High (inline string literals embedded in widget trees and closures) |
| **Tooling & Linter** | Supported by standard Flutter `gen-l10n` | Custom regex required to audit completeness |
| **RTL / BiDi Support** | Handled natively by Material / Cupertino localizations delegates | Relies entirely on outer widget tree directionality |
| **Maintenance Burden** | Single point of truth per language file | 3,057 scattered occurrences across 261 source files |

---

## 6. Migration and Remediation Plan

### Step 1: Update `l10n.yaml` Documentation
Remove the outdated comment regarding commit `056a6e5`. Clarify that the checked-in `lib/l10n/app_localizations*.dart` files are fully updated and synchronized with the ARB files, and establish ARB as the canonical source.

### Step 2: Enforce Strict Compilation in `l10nPick` (Immediate Defense)
In `lib/src/helper/l10n_pick.dart`, make all 6 locales `required`:
```dart
String l10nPick(
  BuildContext context, {
  required String en,
  required String fa,
  required String ar,
  required String tr,
  required String ru,
  required String zh,
});
```
This converts silent translation failures into compile-time errors during development and CI.

### Step 3: Automated Migration Script (`l10nPick` -> ARB)
Run a script to:
1. Extract all 3,057 `l10nPick` calls into unique keys.
2. Append new keys to `app_{en,fa,ar,tr,ru,zh}.arb`.
3. Run `flutter gen-l10n`.
4. Replace `l10nPick(context, ...)` calls with `AppLocalizations.of(context)!.keyName`.

### Step 4: Machine Translation Fill for Incomplete Call Sites
For the 2,574 incomplete calls, generate Turkish, Russian, Arabic, and Chinese translations via professional glossary and banking terminology before migration to ARB.
