# eCardo — Neo-Fintech Component Catalog & State Matrix (DX-007)

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa (2).md` — Sections 14, 20 & Task DX-007  
**Design System Standard:** Atomic Design Hierarchy, WCAG 2.2 AA, Apple HIG, Material 3  
**Implementation Source:** `lib/src/common/widgets/` & `lib/src/presentation/`

---

## 1. Overview & Architectural Principles

The eCardo Component Catalog provides standardized, production-ready UI components across domestic and international banking, travel, remittance, escrow, and digital asset modules. Every component adheres to:
1. **Deterministic State Coverage:** Every interactive element must account for Idle, Focused, Pressed, Loading, Disabled, and Error states.
2. **RTL & LTR Native Parity:** Components do not assume left-to-right flow; touch gestures, sliders, icons, and badges mirror gracefully based on `Directionality.of(context)`.
3. **Adaptive Dark & Light Tokens:** Zero hardcoded colors; every component binds directly to `ECardoTokens` and `AppColors`.
4. **Tactile Haptic Integration:** Haptic triggers are built directly into interaction lifecycles via `AppHaptics`.

---

## 2. Component 1: `EcardoSwipeButton` / `SwipeToConfirmSlider`

High-consequence financial confirmation slider used across crypto transfers, remittance orders, fiat withdrawals, and escrow releases to eliminate accidental taps.

- **Primary Source Files:**
  - `lib/src/common/widgets/design_system/ecardo_swipe_button.dart`
  - `lib/src/presentation/screens/transfer/view/widgets/swipe_to_confirm_slider.dart`
- **Primary Class:** `EcardoSwipeButton` (`StatefulWidget`)

### 2.1 State Matrix

| State | Visual Manifestation (Dark / Light) | Interaction & Physics | Haptics & Sound | Semantics & Accessibility |
| :--- | :--- | :--- | :--- | :--- |
| **Idle / Default** | Sunken track (`#0E0E0C` / `#EBEDF4`), 1px border (`#262624` / `#D2D5E0`), glowing thumb (`#7445FF`), directional chevron shimmer hint (`Curves.easeInOutSine`). | Drag thumb rests at origin ($x = 0$). Listens for horizontal pan gestures. | None | Role: `Slider`. Label: «برای تایید نهایی به راست/چپ بکشید». Value: 0%. |
| **Dragging ($<50\%$)** | Dynamic fill expands behind thumb with `LinearGradient` (`#7445FF` to `#5A35CC`). Text cross-fades out proportionally. | 1:1 finger tracking clamped between $0$ and `maxDrag`. | Light touch feedback on pan start. | Updated percentage value: «$x$ درصد کشیده شد». |
| **Dragging ($50\% - 84\%$)** | Glow aura intensifies around thumb; track fill reaches halfway point; text almost transparent. | Free drag with inertia dampening. Snaps back to 0 on release. | **`AppHaptics.selection()`** fires exactly once when crossing the 50% milestone. | Updated percentage value. |
| **Threshold Crossed ($\ge 85\%$)** | Thumb snaps automatically to right/left terminus. Shimmer disabled. | Drag locks; animation controller snaps to 100% via `Curves.fastOutSlowIn`. | **`AppHaptics.medium()`** fired on threshold crossover. | «آماده تایید». |
| **Loading / In-Flight** | Thumb morphs into circular progress spinner or `LoadingAnimationWidget`. Text reads «در حال پردازش...» / «Processing...». | All drag gestures blocked (`AbsorbPointer`). | None | Live region announces: «در حال ارسال تراکنش به سرور». |
| **Completed / Success** | Track turns solid emerald green (`#14AE6F`), thumb displays white checkmark icon $\checkmark$. Text: «تایید شد» / «Confirmed». | Static state for 800ms before routing or modal dismissal. | **`AppHaptics.heavy()`** executes upon backend acknowledgment. | «تراکنش با موفقیت تایید شد». |
| **Disabled** | Track opacity set to 40% (`Color(0x661E1E1C)`), thumb muted gray (`#656262`), text muted. | Pointer events ignored; gestures do not register. | None | State: `disabled`. Announces reason (e.g. «موجودی ناکافی»). |

### 2.2 RTL vs LTR Adaptation
- **LTR (English, Turkish, Russian):** Thumb starts at left edge ($x = 0$), drags toward right. Delta calculated as $+dx$. Shimmer animates left-to-right.
- **RTL (Persian, Arabic):** Thumb starts at right edge, drags toward left. Delta calculated as $-dx$. Shimmer animates right-to-left.
- **Auto-detection:** Automatically reads `Directionality.of(context) == TextDirection.rtl`.

---

## 3. Component 2: `CommonButton` / `EcardoButton`

Universal multi-variant button component deployed across all auth, form submission, dialog action, and card trigger interfaces.

- **Primary Source File:** `lib/src/common/widgets/button/common_button.dart`
- **Variants Supported:** `ButtonVariant.primary`, `ButtonVariant.secondary`, `ButtonVariant.outline`, `ButtonVariant.text`

### 3.1 State Matrix

| State | Primary Variant | Secondary Variant | Outline Variant | Text Variant | Interaction Behavior |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle** | Background: `#7445FF`<br>Text: `#FFFFFF`<br>Shadow: `shadowCard` | Background: `#262624` (dark) / `#F0F2F6` (light)<br>Text: `#E7E0DE` / `#161614` | Background: Transparent<br>Border: 1.5px `#B79CFF`<br>Text: `#B79CFF` | Background: Transparent<br>Text: `#B79CFF`<br>No border | Full hit-target ($48 \times 48\text{ dp}$ minimum). Standard cursor. |
| **Pressed / Squish** | Scale: 0.98<br>Background: `#5A35CC`<br>Duration: 100ms | Scale: 0.98<br>Background: `#1E1E1C`<br>Duration: 100ms | Scale: 0.98<br>Background: `#7445FF 10%`<br>Duration: 100ms | Scale: 0.98<br>Background: `#7445FF 08%` | **`AppHaptics.light()`** triggered on `onTapDown`. |
| **Focused / Hover** | 2px focus ring (`focusRing` token) with 2px offset | 2px focus ring with 2px offset | 2px focus ring with 2px offset | Underline or pill highlight | Focus ring visible for keyboard and assistive tech. |
| **Loading** | Background maintains variant color; text replaced by `LoadingAnimationWidget.staggeredDotsWave(color: white, size: 24)`. | Same as primary with variant text color. | Border maintains color; spinner matches text color. | Spinner in accent color. | `onPressed` disabled; touches absorbed; preserves width to avoid layout jump. |
| **Disabled** | Background: `Color(0x4D7445FF)` (40% opacity)<br>Text: `Color(0x66FFFFFF)` | Background: `Color(0x4D262624)`<br>Text: `Color(0x66E7E0DE)` | Border: `Color(0x33D5CBC8)`<br>Text: `Color(0x66D5CBC8)` | Text: `Color(0x66656262)` | `onPressed: null`; cursor: forbidden; excluded from accessibility action click. |

---

## 4. Component 3: `CommonTextInputField`

Comprehensive form input widget designed for phone numbers, passwords, amounts, Sheba bank numbers, and search bars.

- **Primary Source Files:**
  - `lib/src/common/widgets/input_field/common_text_input_filed.dart`
  - `lib/src/common/widgets/input_field/common_auth_text_input_field.dart`
  - `lib/src/helper/amount_input_formatter.dart`

### 4.1 State Matrix

| State | Border & Outline | Surface Fill | Text & Label Color | Prefix / Suffix Accessories |
| :--- | :--- | :--- | :--- | :--- |
| **Idle (Empty)** | 1px `borderSubtle` (`#D5CBC8 20%` dark / `#D2D5E0` light) | Sunken surface (`#0E0E0C` dark / `#F5F7FB` light) | Hint text: `softGray` (`#656262`), 14sp | Suffix icon tinted with `softGray`. |
| **Focused** | 2px `borderFocused` (`#B79CFF` dark / `#7445FF` light) | Slightly elevated (`#1A1A18` dark / `#FFFFFF` light) | Caret: `#7445FF`; Label transitions to active accent | Clear button ($\otimes$) fades in if text present; eye toggle active. |
| **Filled (Valid)** | 1px `borderMedium` (`#D5CBC8 30%` dark / `#B3A9A5` light) | Same as idle | Input text: `warmWhite` (`#E7E0DE` dark / `#161614` light) | Suffix checkmark icon or currency ticker pill (`IRT`, `USD`). |
| **Error** | 1.5px `borderError` (`#F08A82` dark / `#DC3C22` light) | `#351714 20%` (dark) / `#FDECEA` (light) | Input text unchanged; helper text below: `#DC3C22` | Suffix error exclamation icon; triggers **`AppHaptics.error()`**. |
| **Disabled / Read-Only** | 1px dashed or 10% opacity border | Sunken muted (`#0E0E0C 50%` dark / `#EBEDF4` light) | Text: `Color(0x66E7E0DE)` (muted) | Suffix lock icon $\odot$; non-editable. |

### 4.2 Numeric & Bilingual Formatting Rules
- **Sheba Account Field:** Fixed `IR` prefix on the left, followed by 24 digits grouped in blocks of 4 (`IR12 3456 7890 1234 5678 9012`). Text direction forced to `TextDirection.ltr`.
- **Card 16-Digit Field:** Formatted as `•••• •••• •••• 1234` with automatic card issuer logo detection (Saman, Mellat, Pasargad, Visa, Mastercard) in prefix slot.
- **Amount Field:** Formatted with thousand separators via `AmountInputFormatter` (`1,000,000`). Currency unit badge (`تومان` / `USDT`) pinned to trailing edge.

---

## 5. Component 4: `EcardoBalanceHero`

Flagship portfolio and wallet balance display featuring split typography, privacy obscuring, and a multi-currency switcher.

- **Primary Source Files:**
  - `lib/src/common/widgets/design_system/ecardo_balance_hero.dart`
  - `lib/src/presentation/screens/home/view/sub_sections/balance_hero_section.dart`

### 5.1 State Matrix

| State | Primary Amount Typography | Privacy State | Currency Pill & Switcher | Ambient Lighting Aura |
| :--- | :--- | :--- | :--- | :--- |
| **Visible Mode** | Split layout: Integer part in 34sp `FontWeight.w900`, decimal part (`.50`) in 20sp `FontWeight.w600`. Tabular figures enabled. | Eye icon: `Icons.visibility_rounded`. Tapping fires **`AppHaptics.light()`**. | Chip showing active ticker (`USD`, `USDT`, `EUR`, `IRT`). Tap opens currency bottom sheet. | Radial glow reflecting 24h PnL: Emerald for positive ($+\Delta$), Crimson for negative ($-\Delta$). |
| **Obscured Privacy Mode** | Amount replaced by bullet glyphs: `••••••••` with letter-spacing 6px. Subtitle equivalents also masked. | Eye icon: `Icons.visibility_off_rounded` with diagonal slash. | Currency chip remains visible and functional. | Glow reduces to neutral subtle violet aura (`Color(0xFF7445FF).withValues(alpha: 0.08)`). |
| **Currency Switching** | Amount fades out (120ms); new currency amount cross-fades in (180ms) with zero layout jump. | Maintains existing privacy state. | Active currency pill highlights with border ring (`borderFocused`). | Recomputes PnL direction and updates light-field. |
| **Zero / New Account** | Displays `0.00` with subtle «شارژ حساب» (Deposit) animated hint badge. | Functional. | Default currency selected. | Neutral violet ambient light-field. |

---

## 6. Component 5: `EcardoEmptyState` & `EcardoErrorView`

Standardized visual recovery components communicating system states with actionable next steps.

- **Primary Source Files:**
  - `lib/src/common/widgets/design_system/ecardo_empty_state.dart`
  - `lib/src/common/widgets/design_system/ecardo_error_view.dart`

### 6.1 `EcardoEmptyState` State Matrix

| State | Orbital Glyph & Visual Aura | Headline & Microcopy | Actions / Buttons |
| :--- | :--- | :--- | :--- |
| **Empty Transactions** | Floating wallet icon inside concentric orbital rings. Glow breathes every 2800ms (`Curves.easeInOutSine`). | «تراکنشی یافت نشد»<br>«هنوز هیچ تراکنشی در این کیف پول ثبت نشده است. اولین تراکنش خود را آغاز کنید.» | Primary CTA: «انتقال جدید» (New Transfer)<br>Secondary CTA: «شارژ حساب» |
| **Empty Search Results** | Search glyph with dotted planetary orbit. | «نتیجه‌ای یافت نشد»<br>«عبارت جستجو شده را بررسی کرده یا فیلترها را بازنشانی کنید.» | Primary CTA: «پاک کردن فیلترها» (Clear Filters) |
| **Empty Beneficiaries** | Contact booklet glyph with subtle violet radial gradient. | «مخاطبی ذخیره نشده است»<br>«شماره شبا یا کارت دوستان خود را ذخیره کنید تا انتقال سریع‌تر انجام شود.» | Primary CTA: «افزودن مخاطب جدید» |

### 6.2 `EcardoErrorView` State Matrix

| State | Radar Indicator | Diagnostics & Monospace Badge | Recovery Interaction |
| :--- | :--- | :--- | :--- |
| **Network Timeout** | Expanding radar ripple animation (`Curves.easeOutQuad`). Icon: `Icons.wifi_off_rounded`. | Monospace pill: `ERR_NET_TIMEOUT`<br>One-tap copy to clipboard with toast confirmation. | Button: «تلاش مجدد» with loading state.<br>Secondary link: «بررسی تاریخچه تراکنش‌ها» |
| **Server / Gateway Fault** | Amber warning triangle with pulsing aura. | Monospace pill: `GW_503_UNAVAILABLE`<br>Copyable reference ID. | Button: «تلاش مجدد» (Retry) with 30-second exponential backoff timer countdown. |
| **Session Expired** | Padlock glyph with red container. | Monospace pill: `AUTH_SESSION_EXPIRED` | Button: «ورود مجدد» (Re-authenticate), directs cleanly to sign-in modal. |

---

## 7. Component 6: `DigitalReceiptTicket`

Fintech transaction voucher featuring concave ticket cutouts, cryptographic barcode/QR, masked PII, and multi-format export.

- **Primary Source Files:**
  - `lib/src/common/widgets/receipt/digital_receipt_ticket.dart`
  - `lib/src/common/widgets/design_system/ecardo_digital_receipt.dart`
- **Silhouette Architecture:** `TicketClipper` (`CustomClipper<Path>`) with 16px corner radii and 12px concave notches at 65% vertical height.

### 7.1 State Matrix

| State / Feature | Visual Treatment | Data Masking Standard | Export & Sharing Actions |
| :--- | :--- | :--- | :--- |
| **Settled (Success)** | Emerald header badge $\checkmark$ «تراکنش موفق». Angled watermark stamp: `SETTLED`. | Destination card masked: `•••• •••• •••• 9012`<br>Sheba masked: `IR**-****-****-****-****-5678`<br>User National ID / PII redacted. | Primary: «ذخیره PDF» (renders via `pdf` & `printing`).<br>Secondary: «اشتراک‌گذاری تصویر» (`RepaintBoundary` $\rightarrow$ PNG). |
| **Pending / Escrow** | Amber header badge $\odot$ «در حال پردازش / امانی». Monospace tracking ID. | Financial release conditions displayed; escrow dispute window countdown. | Primary: «اشتراک رسید»<br>Secondary: «پیگیری سفارش» |
| **Failed / Reversed** | Crimson header badge $\times$ «تراکنش ناموفق». Reason explanation banner. | Zero fee charged; refund settlement status displayed clearly. | Primary: «دریافت جزئیات خطا»<br>Secondary: «پشتیبانی آنلاین» |
| **In-Flight Export** | Screen bounds captured via `RenderRepaintBoundary.toImage(pixelRatio: 3.0)`. | Temporary spinner replaces export icon; system share sheet opened. | Disables buttons during image generation to prevent memory leak. |

---

## 8. Component 7: `ShamsiFlightDatePicker`

Travel calendar modal with dynamic Gregorian/Jalali calendar toggle, range selection, and weekend highlights.

- **Primary Source Files:**
  - `lib/src/presentation/screens/travel/flights/flight_search_screen.dart` (`_FlightDatePickerBottomSheet`)
  - `lib/src/common/widgets/common_single_date_picker.dart`

### 8.1 State Matrix

| State / Feature | Shamsi (Jalali) Mode | Gregorian Mode | Range Selection Flow |
| :--- | :--- | :--- | :--- |
| **Header Toggle** | Segmented pill active on «شمسی». Title: `اردیبهشت ۱۴۰۵`. | Segmented pill active on «میلادی». Title: `May 2026`. | Date summary reflects selected format: «سه‌شنبه، ۱۵ اردیبهشت ۱۴۰۵». |
| **Weekday Headers** | `['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']`. Friday (`ج`) highlighted in `brand700`. | `['M', 'T', 'W', 'T', 'F', 'S', 'S']`. Sunday highlighted. | High-contrast label typography (12sp `FontWeight.w700`). |
| **Active Date Cell** | Circular violet container (`#7445FF`), white bold text, `AppHaptics.selection()` on tap. | Circular violet container (`#7445FF`), white bold text. | Start date: Left/Right rounded cap; End date: Opposite rounded cap. |
| **In-Range Ribbon** | Continuous soft violet fill (`#F0ECFF` light / `#2B2159` dark) connecting departure and return dates. | Same continuous fill across Gregorian grid. | Connects across row breaks seamlessly. |
| **Past / Disabled Days** | Text color: `inkMuted` at 25% opacity (`Color(0x409C98AC)`). Non-tappable. | Non-tappable; opacity 25%. | Gestures absorbed; taps produce no feedback. |

---

## 9. Code Usage Snippets

### 9.1 `EcardoSwipeButton`
```dart
EcardoSwipeButton(
  text: 'برای انتقال به راست بکشید',
  loadingText: 'در حال ثبت حواله...',
  successText: 'انتقال انجام شد',
  isLoading: controller.isSubmitting.value,
  enabled: controller.isFormValid.value,
  onSwipeComplete: () => controller.executeTransfer(),
)
```

### 9.2 `EcardoBalanceHero`
```dart
EcardoBalanceHero(
  amount: wallet.balance,
  currencyCode: wallet.currency,
  pnlPercentage: wallet.dayChangePercent,
  secondaryEquivalent: '≈ ${wallet.tomanEquivalentFormatted} تومان',
  onTogglePrivacy: (hidden) => userSettings.setHideBalance(hidden),
  onCurrencyChanged: (currency) => controller.switchWallet(currency),
)
```
