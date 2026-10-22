# RTL & BiDi Layout Audit

**Document Date:** 2026-10-20  
**Target Codebase:** `ecardo_userapp_v1` (Flutter, Dart)  
**Target Locales:** Persian (`fa`, RTL), Arabic (`ar`, RTL), English (`en`, LTR), Turkish (`tr`, LTR), Russian (`ru`, LTR), Chinese (`zh`, LTR)  
**Primary Focus:** Financial, Core Banking, and Checkout Screens  
**Auditor:** Quality & Architecture Engineering

---

## 1. Executive Summary

Flutter provides first-class support for Right-to-Left (RTL) locales through direction-aware primitives (`EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`, `Icons.adaptive`). However, our comprehensive audit reveals substantial inconsistencies across the application:

1. **Directional Insets vs Physical Insets:**
   - 218 usages of `EdgeInsetsDirectional.only` and 64 usages of `EdgeInsetsDirectional.fromSTEB` demonstrate awareness of RTL.
   - However, **36 instances of physical `EdgeInsets.fromLTRB`** remain (11 in financial screens), and **3 instances of `EdgeInsets.only(left: ..., right: ...)`** break directional mirroring.
2. **Back Arrow & Chevron Mirroring Failures (Critical UX Flaw):**
   - While `CommonAppBar` correctly mirrors its back arrow via `Transform.scale(scaleX: isRtl ? -1 : 1)`, **12 standalone screens and app bars** bypass `CommonAppBar` and use raw `Icons.arrow_back` or `Icons.arrow_back_ios_new_rounded`.
   - In Persian and Arabic, these unmirrored back buttons sit on the **right** edge of the screen but point **leftward into the screen** rather than outward/backward.
   - Furthermore, **45 asset-based directional icons** (`PngAssets.reviewArrowBackCommonIcon`, etc.) are rendered without RTL reflection.
3. **Hardcoded `TextDirection.ltr` (105 Occurrences):**
   - 63 instances represent legitimate BiDi isolation for exchange rate formulas (`1 EUR = 1.08 USD`), OTP/PIN digits, and currency symbols.
   - However, several instances wrap compound text widgets where the forced LTR directionality breaks the natural reading flow of adjacent Persian/Arabic labels and distorts text alignment.
4. **Positioning Workarounds:**
   - Instead of adopting `PositionedDirectional(start: ..., end: ...)`, developers in multiple modules wrote manual ternary conditions (`left: isRtl ? null : 12.w, right: isRtl ? 12.w : null`).

---

## 2. Insets & Padding Audit

### 2.1 Codebase Inset Distribution
- `EdgeInsets.symmetric`: 1,213 occurrences (direction-neutral, horizontally symmetric)
- `EdgeInsets.all`: 830 occurrences (direction-neutral)
- `EdgeInsetsDirectional.only`: 218 occurrences (RTL-safe)
- `EdgeInsetsDirectional.all`: 123 occurrences (RTL-safe)
- `EdgeInsetsDirectional.fromSTEB`: 64 occurrences (RTL-safe)
- `EdgeInsets.fromLTRB`: 36 occurrences (physical, potential RTL risk)
- `EdgeInsets.only` with `left` or `right`: 3 occurrences

### 2.2 Physical `EdgeInsets.fromLTRB` Analysis
Of the 36 `EdgeInsets.fromLTRB` instances, 11 reside directly in financial and checkout screens:
1. `lib/src/presentation/screens/virtual_card/view/create_virtual_card/create_virtual_card.dart:85`:
   `EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 30.h + viewInsets)`
2. `lib/src/presentation/screens/virtual_card/view/virtual_card_details/virtual_card_details.dart:91`:
   `EdgeInsets.fromLTRB(18.w, 0, 18.w, canTopUp ? 90.h : 30.h)`
3. `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart:984`:
   `EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 30.h + viewInsets)`
4. `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart:1418`:
   `EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 30.h + viewInsets)`
5. `lib/src/commercial/screens/commercial_projects_screen.dart:181`:
   `EdgeInsets.fromLTRB(AppSpacing.lg.w, AppSpacing.lg.h, AppSpacing.lg.w, AppSpacing.xxl.h)`
6. `lib/src/commercial/screens/commercial_projects_screen.dart:341`:
   `EdgeInsets.fromLTRB(AppSpacing.lg.w, AppSpacing.sm.h, AppSpacing.lg.w, AppSpacing.xxl.h)`
7. `lib/src/commercial/widgets/equity_project_card.dart:133`:
   `EdgeInsets.fromLTRB(AppSpacing.lg.w, AppSpacing.lg.h, AppSpacing.lg.w, AppSpacing.sm.h)`
8. `lib/src/commercial/widgets/investment_calculator_sheet.dart:71`:
   `EdgeInsets.fromLTRB(AppSpacing.xl.w, AppSpacing.lg.h, AppSpacing.xl.w, bottomPadding)`
9. `lib/src/presentation/screens/bill_payment/view/widgets/bill_review_receipt_card.dart:99`:
   `EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h)`
10. `lib/src/presentation/screens/bill_payment/view/widgets/bill_review_receipt_card.dart:224`:
    `EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h)`
11. `lib/src/presentation/screens/settings/view/transaction_pin/transaction_pin_screen.dart:112`:
    `EdgeInsets.fromLTRB(18, 8, 18, 0)`

**Assessment:** In all 11 financial instances, the horizontal parameters `left` and `right` are numerically identical (e.g., 20.w and 20.w). Thus, no asymmetric layout clipping occurs in practice. However, as an architectural standard, these should be refactored to `EdgeInsetsDirectional.fromSTEB` or `EdgeInsets.symmetric(horizontal: ..., vertical: ...)` to prevent future regressions.

### 2.3 Asymmetric `EdgeInsets.only(left/right)`
- `lib/src/common/widgets/design_system/ecardo_balance_hero.dart:141`:
  Uses `left: 4, right: 4` (symmetric).
- `lib/src/presentation/screens/settings/view/notifications/notifications.dart:525`:
  `EdgeInsets.only(top: 14, bottom: 8, left: 4, right: 4)` (symmetric).
- `lib/src/presentation/screens/settings/view/notifications/notifications.dart:1096`:
  `EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: ...)` (symmetric).

---

## 3. Alignment & Gradients Audit

Across the entire `lib/` directory, there are **158 occurrences of physical `Alignment.*`**:
- `Alignment.topLeft` (79)
- `Alignment.bottomRight` (79)
- `Alignment.centerLeft` (2)
- `Alignment.centerRight` (2)

**Critical Finding:**
100% of these 158 occurrences reside exclusively inside `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight)` or `LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight)`.
- Zero instances of physical `Alignment.centerLeft` / `Alignment.centerRight` are used on layout containers (`Align`, `Container(alignment:)`, `Positioned`).
- For brand aesthetic consistency, diagonal shading (135-degree angle from top-left to bottom-right) is preserved uniformly across all locales in banking hero cards and balance displays.

---

## 4. Navigation & Back Arrow Icons Audit (High Severity)

### 4.1 The Two App Bar Paradigms
The codebase contains two contrasting patterns for screen headers:

**Pattern A: Compliant Header (`CommonAppBar`)**
In `lib/src/common/widgets/app_bar/common_app_bar.dart` (lines 75-84):
```dart
IconButton(
  onPressed: () => _handleBack(context),
  icon: Transform.scale(
    scaleX: Directionality.of(context) == TextDirection.rtl ? -1 : 1,
    child: Image.asset(
      PngAssets.arrowLeftCommonIcon,
      width: 25.w,
      color: primaryTextColor,
    ),
  ),
)
```
In RTL, `scaleX: -1` flips the left arrow into a right arrow pointing backward out of the screen.

**Pattern B: Non-Compliant Raw `AppBar` (12 Screens)**
In multiple screens, developers constructed an inline `AppBar(leading: IconButton(...))` without mirroring:

1. `lib/src/presentation/screens/remittance/view/remittance_screen.dart:37`:
   ```dart
   appBar: AppBar(
     leading: IconButton(
       icon: Icon(Icons.arrow_back, color: ...),
       onPressed: () => ...,
     ),
     title: Text(l.remittanceTitle),
   )
   ```
2. `lib/src/presentation/screens/remittance/view/remittance_details/remittance_details.dart:38`:
   Raw `Icon(Icons.arrow_back)`.
3. `lib/src/presentation/screens/remittance/view/remittance_history/remittance_history.dart:52`:
   Raw `Icon(Icons.arrow_back)`.
4. `lib/src/commercial/screens/my_investments_screen.dart:34`:
   Raw `Icon(Icons.arrow_back_ios_new_rounded)`.
5. `lib/src/commercial/screens/equity_project_detail_screen.dart:64`:
   Raw `Icon(Icons.arrow_back_ios_new_rounded)`.
6. `lib/src/commercial/screens/equity_invest_checkout_screen.dart:86`:
   Raw `Icon(Icons.arrow_back_ios_new_rounded)`.
7. `lib/src/remitv2/screens/remittance_track_screen.dart:202`:
   Raw `Icon(Icons.arrow_back_ios_rounded)`.
8. `lib/src/rental/screens/rental_voucher_screen.dart:54`:
   Raw `Icon(Icons.arrow_back_ios_rounded)`.
9. `lib/src/presentation/screens/travel/boat/screens/boat_voucher_screen.dart:93`:
   Raw `Icon(Icons.arrow_back_ios_new_rounded)`.
10. `lib/src/presentation/screens/travel/local/screens/local_voucher_screen.dart:42`:
    Raw `Icon(Icons.arrow_back_ios_new_rounded)`.
11. `lib/src/presentation/screens/kyc_level/view/kyc_submit_wizard.dart:87`:
    Raw `Icon(Icons.arrow_back)`.
12. `lib/src/presentation/screens/authentication/sign_up/view/set_passcode/set_passcode_screen.dart:67`:
    Raw `Icon(Icons.arrow_back)`.

**User Experience Defect:**
In Persian or Arabic mode, the `AppBar` correctly places `leading` on the top-right of the screen. However, `Icons.arrow_back` points to the **left** (toward the screen title). The user sees a back button that points into the content instead of outward.

### 4.2 List Item Disclosure Chevrons
In list tiles and settings cards:
- `lib/src/presentation/screens/cash_out/view/sub_sections/cash_out_amount_step_section.dart:563`:
  Uses `Icon(Icons.arrow_forward_ios_rounded, size: 14)`. In RTL, the chevron sits on the left edge of the tile but points to the right (into the tile text), rather than pointing to the left (forward drill-down).
- `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart:686`:
  Raw `Icons.arrow_forward_ios_rounded` without mirroring.
- `lib/src/loan/screens/loan_home_screen.dart:439`:
  Raw `Icons.arrow_forward_ios_rounded` without mirroring.

Contrast this with the compliant implementation in `lib/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart:1114`:
```dart
icon: Transform.flip(
  flipX: isRtl,
  child: const Icon(Icons.arrow_forward_rounded, size: 13),
)
```

### 4.3 Asset Directionality in `CommonIconButton`
In `lib/src/common/widgets/button/common_icon_button.dart`:
- The widget accepts a string asset path `icon: PngAssets.reviewArrowBackCommonIcon`.
- In `cash_out_review_step_section.dart:420` and `exchange_review_step_section.dart:430`, it is used for the secondary "Back" button:
  ```dart
  CommonIconButton(
    text: localizations.cashOutReviewBack,
    icon: PngAssets.reviewArrowBackCommonIcon,
    ...
  )
  ```
- In `CommonIconButton.build`:
  `Row(children: [iconWidget, SizedBox(...), textWidget])`.
- In RTL, Flutter's `Row` automatically places the icon on the right and text on the left. But `PngAssets.reviewArrowBackCommonIcon` is a PNG image of an arrow pointing left. Consequently, in RTL, the back arrow sits on the right side and points leftward into the button label.

---

## 5. Hardcoded `TextDirection.ltr` Audit

There are **105 occurrences** of `TextDirection.ltr` across the codebase. Analysis shows these fall into two distinct categories:

### 5.1 Category 1: Legitimate BiDi Mathematical & Numeric Isolation (63 Occurrences)
1. **Exchange Rates:**
   `exchange_review_step_section.dart:148` and `live_rate_badge.dart:132`:
   ```dart
   Directionality(
     textDirection: TextDirection.ltr,
     child: Text('1 ${controller.fromWallet.value!.code} = ${controller.exchangeReviewRate.value.toStringAsFixed(toDecimals)} ${controller.toWallet.value!.code}'),
   )
   ```
   *Rationale:* Without `TextDirection.ltr`, the Unicode Bidirectional Algorithm (UBA) reorders `1 EUR = 1.08 USD` into `USD 1.08 = EUR 1` or misplaces equal signs when embedded in Persian sentences.
2. **Tabular Financial Figures:**
   `money_display_text.dart:119, 121` and `recent_transactions_section.dart:566`:
   Forces LTR so currency signs and minus prefixes (`-$1,250.00`) maintain consistent order regardless of locale.
3. **Authentication PIN & OTP Inputs:**
   `sign_in_screen.dart:787`, `email_otp_login_screen.dart:223`, `two_factor_auth.dart:126`, `verify_email_screen.dart:253`:
   Forces LTR digit entry so boxes fill from left to right.
4. **Shamsi Solar Calendar (`flight_search_screen.dart:2267`):**
   Explicitly forces `TextDirection.rtl` so the Saturday-Friday Persian solar grid lays out correctly even when the app is operated in English or Turkish.

### 5.2 Category 2: Problematic Container-Level LTR Wrapping (42 Occurrences)
In `lib/src/presentation/screens/home/view/sub_sections/user_profile_section.dart:177, 282`:
The entire UID row is wrapped in `Directionality(textDirection: TextDirection.ltr)`.
- *Issue:* This forces the label (`UID:`) to the left and the value to the right, reversing the visual column alignment compared to all other cards on the home screen in Persian mode.
- *Fix:* Isolate ONLY the alphanumeric UID value inside `Directionality(textDirection: TextDirection.ltr)`, while allowing the label and row container to follow the ambient RTL directionality.

---

## 6. Financial Screens Deep Dive

| Screen / Module | File Path | RTL Compliance | Identified Issues | Recommended Fix |
|---|---|---|---|---|
| **Remittance Main** | `lib/src/presentation/screens/remittance/view/remittance_screen.dart` | FAIL | Unmirrored `Icons.arrow_back` in AppBar leading; hardcoded Persian tooltip `'رهگیری حواله'` | Replace with `CommonAppBar` or add `Transform.scale(scaleX: isRtl ? -1 : 1)`; localize tooltip |
| **Remittance Details** | `lib/src/presentation/screens/remittance/view/remittance_details/remittance_details.dart` | FAIL | Unmirrored `Icons.arrow_back` in AppBar | Replace leading with direction-aware back button |
| **Remittance History** | `lib/src/presentation/screens/remittance/view/remittance_history/remittance_history.dart` | FAIL | Unmirrored `Icons.arrow_back` in AppBar | Replace leading with direction-aware back button |
| **Remittance Track (V2)** | `lib/src/remitv2/screens/remittance_track_screen.dart` | FAIL | Unmirrored `Icons.arrow_back_ios_rounded` | Add `scaleX: isRtl ? -1 : 1` |
| **Commercial Portfolio** | `lib/src/commercial/screens/my_investments_screen.dart` | FAIL | Unmirrored `Icons.arrow_back_ios_new_rounded` | Add `scaleX: isRtl ? -1 : 1` |
| **Commercial Project Detail** | `lib/src/commercial/screens/equity_project_detail_screen.dart` | FAIL | Unmirrored `Icons.arrow_back_ios_new_rounded` | Add `scaleX: isRtl ? -1 : 1` |
| **Commercial Checkout** | `lib/src/commercial/screens/equity_invest_checkout_screen.dart` | FAIL | Unmirrored `Icons.arrow_back_ios_new_rounded` | Add `scaleX: isRtl ? -1 : 1` |
| **Exchange Review** | `lib/src/presentation/screens/exchange/view/sub_sections/exchange_review_step_section.dart` | WARNING | `PngAssets.reviewArrowBackCommonIcon` unmirrored in `CommonIconButton` | Wrap icon asset with `Transform.scale` inside `CommonIconButton` |
| **Cash Out Review** | `lib/src/presentation/screens/cash_out/view/sub_sections/cash_out_review_step_section.dart` | WARNING | `PngAssets.reviewArrowBackCommonIcon` unmirrored in `CommonIconButton` | Wrap icon asset with `Transform.scale` inside `CommonIconButton` |
| **Cash Out Amount Step** | `lib/src/presentation/screens/cash_out/view/sub_sections/cash_out_amount_step_section.dart` | FAIL | Unmirrored `Icons.arrow_forward_ios_rounded` disclosure chevron | Add `Transform.scale` or flip based on `isRtl` |
| **Transfer Confirmation** | `lib/src/presentation/screens/transfer/view/widgets/swipe_to_confirm_slider.dart` | PASS | Fully RTL-aware (`AlignmentDirectional`, `isRtl` delta calculation, chevron flipping) | Benchmark implementation |
| **Multi-Currency Cards** | `lib/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart` | PASS | Uses `Transform.flip(flipX: isRtl)` on action icons | Benchmark implementation |
| **Virtual Card Security** | `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart` | WARNING | Unmirrored `Icons.arrow_forward_ios_rounded` on settings rows | Add direction-aware flipping |

---

## 7. Standardized RTL Recipes & Remediation Code

### Recipe 1: Direction-Aware Back Button Widget
Create a centralized, reusable widget `DirectionalBackButton`:
```dart
class DirectionalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const DirectionalBackButton({super.key, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final iconColor = color ?? (theme.brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      icon: Transform.scale(
        scaleX: isRtl ? -1.0 : 1.0,
        child: Icon(Icons.arrow_back_ios_new_rounded, color: iconColor, size: 20),
      ),
    );
  }
}
```

### Recipe 2: Auto-Mirroring for `CommonIconButton`
In `lib/src/common/widgets/button/common_icon_button.dart`:
```dart
final isRtl = Directionality.of(context) == TextDirection.rtl;
final shouldMirror = autoMirror && isRtl;

final iconWidget = Transform.scale(
  scaleX: shouldMirror ? -1.0 : 1.0,
  child: Image.asset(
    icon,
    width: iconWidth.w,
    height: iconHeight.h,
    color: isIconColor == true ? iconColor : null,
  ),
);
```

### Recipe 3: BiDi Safe Number/Rate Display
```dart
Widget buildRateText(BuildContext context, String base, double rate, String target) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Text(
      '1 $base = ${rate.toStringAsFixed(4)} $target',
      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
    ),
  );
}
```
