# Accessibility (A11Y) Audit Report

**Document Date:** 2026-10-20  
**Target Codebase:** `ecardo_userapp_v1` (Flutter, Dart)  
**Target Guidelines:** WCAG 2.1 (Level AA), Material Design 3 A11Y, Apple Human Interface Guidelines (HIG)  
**Primary Modules:** Core Banking, Design System Tokens, Navigation, Input Fields, Forms  
**Auditor:** Quality & Architecture Engineering

---

## 1. Executive Summary

This accessibility audit evaluates `ecardo_userapp_v1` across four core dimensions:
1. **Screen Reader Semantics:** 466 raw gesture detectors (`GestureDetector` + `InkWell`), but only 51 `Semantics` wrappers exist in the entire codebase (10.9% coverage). 159 out of 181 `IconButton`s (87.8%) lack `tooltip` or accessibility labels, rendering them completely unlabeled on Android TalkBack and iOS VoiceOver.
2. **Touch Target Dimensions:** Over 211 interactive elements possess touch targets smaller than the 48x48dp standard. Critical flaws include 16x16dp copy buttons and 20x20dp dismiss targets in P2P and modal sheets.
3. **Color Contrast (WCAG 2.1 AA):** 6 out of 30 core theme token pairs suffer hard contrast failures. Most critically, `darkTextSecondary` (`#656262`) on `darkSurface` (`#262625`) yields an unacceptable **2.51:1** ratio (failing both normal 4.5:1 and large 3.0:1 thresholds). In light mode, `warning` (`1.91:1`), `success` (`2.87:1`), and `mutedBlue` (`2.33:1`) fail basic readability.
4. **Dynamic Type & Font Scaling:** `app.dart` clamps `textScaler` between 0.85x and 1.8x. However, 398 containers with hardcoded heights (≤60dp) wrap text without vertical flexibility, causing critical `RenderFlex` overflow errors when assistive font scaling is enabled.

---

## 2. Screen Reader & Semantics Audit

### 2.1 Interactive Widgets Inventory

| Widget Type | Total Count | Accessible Wrappers / Labels | Compliance Rate |
|---|---|---|---|
| `InkWell` | 253 | Part of custom buttons | ~15% |
| `GestureDetector` | 213 | Raw gestures | ~8% |
| **Total Raw Tap Targets** | **466** | **51 `Semantics` widgets** | **10.9%** |
| `IconButton` | 181 | 22 with `tooltip:` | **12.2%** (87.8% unlabelled) |
| `ElevatedButton` | 94 | Built-in semantics | 100% |
| `TextButton` | 79 | Built-in semantics | 100% |
| `OutlinedButton` | 26 | Built-in semantics | 100% |

### 2.2 Critical Semantics Defects

#### Issue 2.2.1: `CommonButton` and `CommonIconButton` Lack Semantics
`CommonButton` (`lib/src/common/widgets/button/common_button.dart`) and `CommonIconButton` (`lib/src/common/widgets/button/common_icon_button.dart`) are the primary action widgets used throughout the entire app.
- Both wrap custom `Container`s in `InkWell` or `GestureDetector`.
- Neither widget provides a `Semantics(button: true, label: ..., enabled: ...)` wrapper.
- Screen readers announce them as generic containers or raw text rather than interactive buttons, failing WCAG 4.1.2 (Name, Role, Value).

#### Issue 2.2.2: 159 Unlabeled `IconButton` Widgets
In 159 locations, `IconButton` is invoked with only `icon:` and `onPressed:`, omitting `tooltip:`.
- Examples:
  * `lib/src/presentation/screens/remittance/view/remittance_screen.dart:36`: Back button has no label or tooltip.
  * `lib/src/commercial/screens/my_investments_screen.dart:32`: Back button has no label or tooltip.
  * `lib/src/presentation/screens/home/view/home_screen.dart`: Top app bar notification and search icon buttons lack tooltips.
- Screen reader output: VoiceOver and TalkBack announce "Button, unlabeled" or read out internal asset file paths.

---

## 3. Touch Target Size Audit (WCAG 2.5.5 & 2.5.8)

Material Design 3 and Android accessibility guidelines require touch targets to be at least **48x48dp**. Apple HIG mandates at least **44x44pt**.

### 3.1 Undersized Interactive Elements (< 44dp)
Across the codebase, **211 interactive elements** violate touch target size requirements. Notable critical examples:

| File Path | Line | Element | Measured Size | Guideline Violation |
|---|---|---|---|---|
| `lib/src/presentation/screens/p2p/sub_category/my_order/widgets/my_order_card.dart` | 95 | Copy Order Number tap target | 16x16 dp | Severe (WCAG 2.5.8 Fail) |
| `lib/src/presentation/screens/p2p/sub_category/my_ads/widgets/my_ads_details_bottom_sheet.dart` | 83 | Sheet Close Button (`Get.back`) | 20x20 dp | Severe |
| `lib/src/presentation/screens/p2p/sub_category/my_ads/widgets/my_ads_filter_bottom_sheet.dart` | 125 | Sheet Close Button (`Get.back`) | 20x20 dp | Severe |
| `lib/src/presentation/screens/p2p/sub_category/my_order/widgets/my_order_filter_bottom_sheet.dart` | 88 | Sheet Close Button (`Get.back`) | 20x20 dp | Severe |
| `lib/src/presentation/screens/p2p/sub_category/payment_account/widgets/payment_account_details_bottom_sheet.dart` | 64 | Sheet Close Button (`Get.back`) | 20x20 dp | Severe |
| `lib/src/presentation/screens/p2p/sub_category/my_ads/widgets/edit_my_ad_bottom_sheet.dart` | 118 | Sheet Close Button (`Get.back`) | 22x22 dp | Severe |
| `lib/src/presentation/screens/transfer/view/widgets/transfer_step_indicator.dart` | 138 | Step indicator circle tap | 28x28 dp | Moderate |
| `lib/src/common/widgets/receipt/digital_receipt_ticket.dart` | 1380, 1420 | Share receipt & export PDF action buttons | 16x16 dp icon, no padding | Severe |
| `lib/src/app/navigation/navigation_screen.dart` | 520, 553, 586 | Bottom sheet QR quick actions (Scan, Receive, Transfer) | 12x12 dp inner container | Severe |

### 3.2 Root Cause
Developers wrapped `Image.asset(..., width: 20)` directly inside `GestureDetector(onTap: ...)` without setting `behavior: HitTestBehavior.opaque` or providing an outer `SizedBox(width: 48, height: 48)` touch envelope.

---

## 4. Text-to-Surface Color Contrast Calculations (WCAG 2.1 AA)

All calculations follow the WCAG 2.1 relative luminance formula:
$$L = 0.2126 \cdot R + 0.7152 \cdot G + 0.0722 \cdot B$$
$$\text{Contrast Ratio} = \frac{L_1 + 0.05}{L_2 + 0.05}$$

Source values from `lib/src/app/constants/app_colors.dart`. Alpha blending is composited over the respective background.

### 4.1 Complete 30-Pair Color Contrast Matrix

| Pair Name | Foreground Color | Background Color | Ratio | AA Normal (≥4.5:1) | AA Large (≥3.0:1) | Result |
|---|---|---|---|---|---|---|
| **Light Theme** | | | | | | |
| Light body text on page | `0xFF161614` | `0xFFF5F7FB` | **16.89:1** | PASS | PASS | Compliant |
| Light body text on card | `0xFF161614` | `0xFFFFFFFF` | **18.12:1** | PASS | PASS | Compliant |
| Light secondary text on page | `0xFF656262` | `0xFFF5F7FB` | **5.63:1** | PASS | PASS | Compliant |
| Light secondary text on card | `0xFF656262` | `0xFFFFFFFF` | **6.04:1** | PASS | PASS | Compliant |
| Light tertiary (60%) on card | `0x99161614` | `0xFFFFFFFF` | **4.75:1** | PASS | PASS | Compliant |
| Light tertiary (60%) on page | `0x99161614` | `0xFFF5F7FB` | **4.63:1** | PASS | PASS | Compliant |
| White on primary violet | `0xFFFFFFFF` | `0xFF7445FF` | **5.20:1** | PASS | PASS | Compliant |
| Primary violet text on card | `0xFF7445FF` | `0xFFFFFFFF` | **5.20:1** | PASS | PASS | Compliant |
| Primary violet text on page | `0xFF7445FF` | `0xFFF5F7FB` | **4.85:1** | PASS | PASS | Compliant |
| Light border vs card | `0xFFD5CBC8` | `0xFFFFFFFF` | **1.59:1** | FAIL | FAIL | Non-compliant |
| Secondary accent (`mutedBlue`) on card | `0xFF00BFA6` | `0xFFFFFFFF` | **2.33:1** | **FAIL** | **FAIL** | **Hard Failure** |
| Error text on card | `0xFFDC3C22` | `0xFFFFFFFF` | **4.46:1** | FAIL (4.46 < 4.5) | PASS | Large-only |
| Error text on error container | `0xFFDC3C22` | `0xFFFDECEA` | **3.90:1** | FAIL | PASS | Large-only |
| Warning text on card | `0xFFFFAA00` | `0xFFFFFFFF` | **1.91:1** | **FAIL** | **FAIL** | **Hard Failure** |
| Success text on card | `0xFF14AE6F` | `0xFFFFFFFF` | **2.87:1** | **FAIL** | **FAIL** | **Hard Failure** |
| Info text on card | `0xFF2196F3` | `0xFFFFFFFF` | **3.12:1** | FAIL | PASS | Large-only |
| **Dark Theme** | | | | | | |
| Dark body text on page | `0xFFE7E0DE` | `0xFF161614` | **13.90:1** | PASS | PASS | Compliant |
| Dark body text on card | `0xFFE7E0DE` | `0xFF262625` | **11.62:1** | PASS | PASS | Compliant |
| Dark secondary (`softGray`) on page | `0xFF656262` | `0xFF161614` | **3.00:1** | **FAIL** | PASS | **Hard Failure** |
| Dark secondary (`softGray`) on card | `0xFF656262` | `0xFF262625` | **2.51:1** | **FAIL** | **FAIL** | **Hard Failure** |
| Dark tertiary (55%) on page | `0x8CE7E0DE` | `0xFF161614` | **4.96:1** | PASS | PASS | Compliant |
| Dark tertiary (55%) on card | `0x8CE7E0DE` | `0xFF262625` | **4.55:1** | PASS | PASS | Compliant |
| Deep black on dark primary violet | `0xFF161614` | `0xFFB79CFF` | **7.95:1** | PASS | PASS | Compliant |
| Dark primary violet text on page | `0xFFB79CFF` | `0xFF161614` | **7.95:1** | PASS | PASS | Compliant |
| Dark secondary accent on card | `0xFF00BFA6` | `0xFF262625` | **6.49:1** | PASS | PASS | Compliant |
| Dark border vs page | `0x33D5CBC8` | `0xFF161614` | **1.60:1** | FAIL | FAIL | Non-compliant |
| Error on dark card | `0xFFDC3C22` | `0xFF262625` | **3.40:1** | FAIL | PASS | Large-only |
| Warning on dark card | `0xFFFFAA00` | `0xFF262625` | **7.94:1** | PASS | PASS | Compliant |
| Success on dark card | `0xFF14AE6F` | `0xFF262625` | **5.28:1** | PASS | PASS | Compliant |
| Info on dark card | `0xFF2196F3` | `0xFF262625` | **4.85:1** | PASS | PASS | Compliant |

### 4.2 Deep Dive into Hard Failures

#### 1. Dark Mode Secondary Text (`#656262` on `#262625` = 2.51:1)
- `darkTextSecondary` uses `AppColors.softGray` (`#656262`).
- On dark card surfaces (`#262625`), the ratio is **2.51:1** (requires 4.5:1 for normal text, 3.0:1 for large text).
- On dark background (`#161614`), the ratio is **3.00:1**.
- *Impact:* Subtitles, transaction timestamps, hint text, and account descriptions are barely legible in dark mode for users with moderate visual impairments.
- *Recommended Fix:* Replace `darkTextSecondary` with `Color(0xFFA5A09F)` (yielding **5.5:1** on dark card).

#### 2. Light Mode Status Colors (`warning`, `success`, `mutedBlue` on White)
- `warning` (`#FFAA00`) on white has a ratio of **1.91:1** (catastrophic failure).
- `success` (`#14AE6F`) on white has a ratio of **2.87:1** (fails normal and large text).
- `mutedBlue` (`#00BFA6`) on white has a ratio of **2.33:1** (fails normal and large text).
- *Impact:* When used as text labels (e.g. "Pending", "Active", "Completed" transaction badges), these colors are illegible against white cards.
- *Recommended Fix:* Split tokens into surface background tints (`warningContainer`) and high-contrast text foregrounds (`warningText`: `#8C5800` [6.8:1], `successText`: `#0B7549` [4.9:1]).

---

## 5. Dynamic Type & Font Scaling Risks

### 5.1 Text Scaler Configuration
In `lib/src/app/app.dart` (lines 101-106):
```dart
final mediaQuery = MediaQuery.of(context);
final clampedTextScaler = mediaQuery.textScaler.clamp(
  minScaleFactor: 0.85,
  maxScaleFactor: 1.8,
);
body = MediaQuery(
  data: mediaQuery.copyWith(textScaler: clampedTextScaler),
  child: body,
);
```
The application allows text scaling up to **1.8x** (180% of design size).

### 5.2 Fixed-Height Container Risk (398 Occurrences)
Across the codebase, **398 containers** specify a hardcoded `height: ≤ 60` wrapping `Row` or `Column` containing `Text`.
- When font size scales by 1.8x, a standard 14sp font expands to ~25.2sp.
- In fixed 48dp or 52dp containers with 12dp top and bottom padding, the available inner height is only 24-28dp.
- A 25.2sp font with line height of 1.3 requires at least 32.7dp.
- **Result:** Flutter throws a red `A RenderFlex overflowed by X pixels on the bottom` error, truncating text or corrupting button layouts.

### 5.3 `CommonButton` Vertical Inflexibility
In `lib/src/common/widgets/button/common_button.dart` (lines 36, 192):
- Default parameter: `this.height = 48`
- Build tree: `Container(height: height?.h, child: Text(text, fontSize: fontSize.sp))`
- *Defect:* Specifying `height: 48.h` prevents the button from expanding vertically when the label wraps onto two lines or when assistive text scaling is active.
- *Fix:* Replace `height: height?.h` with:
  ```dart
  constraints: BoxConstraints(
    minHeight: (height ?? 48).h,
  )
  ```

### 5.4 Truncation of Critical Financial Data
Extensive usage of `maxLines: 1, overflow: TextOverflow.ellipsis` on:
- Account numbers (IBAN, card PAN)
- Transaction amounts in transaction cards
- Legal disclaimers in escrow and loan screens
*Risk:* Low-vision users operating with enlarged text will see truncated financial figures (e.g. `$1,2...` instead of `$1,250,000`).

---

## 6. Remediation Code Examples

### 6.1 Accessible Button Wrapper
```dart
Widget buildAccessibleButton({
  required BuildContext context,
  required String label,
  required VoidCallback? onPressed,
  required Widget child,
}) {
  return Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    excludeSemantics: true,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
      child: child,
    ),
  );
}
```

### 6.2 Accessible Minimum Touch Target Enforcer
```dart
Widget ensureMinimumTouchTarget({
  required Widget child,
  double size = 48.0,
}) {
  return SizedBox(
    width: size,
    height: size,
    child: Center(child: child),
  );
}
```

### 6.3 WCAG AA Compliant Status Badge
```dart
Widget buildStatusBadge(BuildContext context, String label, StatusType type) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  final (Color bg, Color fg) = switch (type) {
    StatusType.success => isDark 
        ? (const Color(0xFF0E3A28), const Color(0xFF4ADE80)) 
        : (AppColors.successContainer, const Color(0xFF0B7549)), // 4.9:1 PASS
    StatusType.warning => isDark 
        ? (const Color(0xFF3E2D04), const Color(0xFFFBBF24)) 
        : (AppColors.warningContainer, const Color(0xFF8C5800)), // 6.8:1 PASS
    StatusType.error => isDark 
        ? (const Color(0xFF3F1715), const Color(0xFFF87171)) 
        : (AppColors.errorContainer, const Color(0xFFB91C1C)), // 5.2:1 PASS
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
  );
}
```
