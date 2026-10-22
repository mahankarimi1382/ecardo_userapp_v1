# eCardo Motion & Animation Audit

**Audit Date:** 2026-10-20  
**Target Codebase:** `ecardo_userapp_v1` (Flutter / Dart 3.x, App v1.0.41+41)  
**Audit Scope:** Explicit AnimationControllers, TabControllers, Implicit Animations, Timer loops, Reduce-Motion accessibility compliance, and disposal safety.

---

## 1. Executive Summary & Motion Health Scorecard

A full static sweep of all 424 graph nodes and 172,000+ lines of Dart code reveals an expressive, modern neo-fintech motion system, but one that suffers from **severe accessibility non-compliance** and **perpetual background GPU ticker consumption**.

| Metric | Measured Value | Health Status |
| :--- | :---: | :---: |
| **Total AnimationController Files** | 30 files (40 controller instances) | Active |
| **TabController Files** | 9 files (9 controller instances) | Clean |
| **Implicit Animation Files** | 94 files (`AnimatedContainer`, `Opacity`, etc.) | High Usage |
| **Background `Timer.periodic` Loops** | 15 files | Managed |
| **Proper Dispose Rate** | **100%** (39/39 controller files dispose safely) | **EXCELLENT** |
| **Reduce-Motion Compliance (`disableAnimations`)** | **3.3%** (1 of 30 files: `EcardoGlassCard`) | **CRITICAL FAILURE** |
| **Infinite Perpetual Tickers** | **15 components** (50% of explicit animations) | **HIGH RISK** |
| **Test Bypass Anti-Pattern (`contains('Test')`)** | **3 components** | **HIGH RISK** |

---

## 2. Comprehensive AnimationController Inventory

Below is the verified inventory of all 30 files instantiating explicit Flutter `AnimationController`s, detailing controller instances, timing parameters, infinite repetition, reduce-motion checks, and disposal status.

| # | Component / File | Declared Controllers | Durations | Curves | Mode | Reduce Motion? | Dispose Safety |
| :-: | :--- | :--- | :--- | :--- | :-: | :-: | :-: |
| 1 | `exchange_success_step_section.dart` | `_celebrationController` | 900ms, 150ms | `easeOut`, `easeOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 2 | `ecardo_digital_receipt.dart` | `_controller` | 1800ms, 200ms | `easeInOut` | One-shot | **NO** | Safe (`dispose()`) |
| 3 | `multi_currency_flip_card.dart` | `_controller` | 450ms | `easeInOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 4 | `ecardo_glass_card.dart` | `_controller` | 120ms (rev: 240ms) | `easeInOutQuad`, `easeOutBack` | One-shot | **YES** | Safe (`dispose()`) |
| 5 | `sign_in_screen.dart` | `_bioPulseCtrl`, `_enterCtrl` | 550ms, 1800ms | `easeInOut`, `easeOut` | **Infinite** (`_bioPulseCtrl`) | **NO** | Safe (`dispose()`) |
| 6 | `transfer_success_celebration.dart` | `_controller` | 900ms | `easeInOut`, `easeOut`, `elasticOut` | One-shot | **NO** | Safe (`dispose()`) |
| 7 | `ecardo_swipe_button.dart` | `_resetController`, `_shimmerController` | 320ms, 1800ms | `easeInOutSine`, `easeOutBack` | **Infinite** (`_shimmerController`) | **NO** | Safe (`dispose()`) |
| 8 | `kyc_tier_upgrade_card.dart` | `_animController` | 2200ms, 250ms | `easeInOut` | **Infinite** (Glow pulse) | **NO** | Safe (`dispose()`) |
| 9 | `services_screen.dart` | `_entranceController` | 700ms | `easeOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 10 | `support_tickets.dart` | `_controller` | 140ms | `easeInOut`, `easeOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 11 | `splash_screen.dart` | `_introController`, `_progressController`, `_pulseController` | 1400ms, 1800ms, 2200ms | `easeOut`, `easeOutBack`, `easeOutCubic` | **Infinite** (`_pulseController`) | **NO** | Safe (`dispose()`) |
| 12 | `common_virtual_card_view.dart` | `_flipController` | 500ms | `easeInOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 13 | `swipe_to_confirm_slider.dart` | `_animController` | 250ms | `easeOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 14 | `exchange_swap_card.dart` | `_swapRotationController`, `_swapScaleController` | 360ms, 140ms | `easeInOut` | One-shot | **NO** | Safe (`dispose()`) |
| 15 | `live_rate_badge.dart` | `_pulseController` | 1400ms | `easeOut` | **Infinite** (`repeat(rev: true)`) | **NO** | Safe (`dispose()`) |
| 16 | `app_update_screen.dart` | `_lottieController` | 1400ms | Linear / Lottie default | One-shot | **NO** | Safe (`dispose()`) |
| 17 | `ecardo_balance_hero.dart` | `_controller` | 260ms | `easeInOut` | One-shot | **NO** | Safe (`dispose()`) |
| 18 | `wallets_card_section.dart` | `_flipController` | 450ms | `easeInOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 19 | `kyc_level_roadmap.dart` | `_pulseController` | 1800ms | `easeInOut` | **Infinite** (`repeat(rev: true)`) | **NO** | Safe (`dispose()`) |
| 20 | `document_alignment_guide.dart` | `_scanController` | 2500ms, 3200ms | `easeInOut` | **Infinite** (Scan laser) | **NO** | Safe (`dispose()`) |
| 21 | `visual_pin_dots_indicator.dart` | `_shakeController` | 400ms | `easeInOut`, `easeOutCubic` | One-shot (Error shake) | **NO** | Safe (`dispose()`) |
| 22 | `pulsing_indicator.dart` | `_controller` | 1500ms | `easeOut` | **Infinite** (`repeat()`) | **NO** | Safe (`dispose()`) |
| 23 | `add_account_dashed_button.dart` | `_pressController` | 180ms | `easeOutCubic` | One-shot | **NO** | Safe (`dispose()`) |
| 24 | `ticket_status_helper.dart` | `_pulseController` | 1200ms | `easeInOut` | **Infinite** (`repeat(rev: true)`) | **NO** | Safe (`?.dispose()`) |
| 25 | `recent_transactions_section.dart` | `_controller` | 800ms | `easeInOut` | **Infinite** (`repeat(rev: true)`) | **NO** | Safe (`dispose()`) |
| 26 | `rate_lock_countdown_timer.dart` | `_countdownController`, `_pulseController` | 45s, 600ms | `easeInOut` | **Infinite** (`_pulseController`) | **NO** | Safe (`dispose()`) |
| 27 | `ecardo_empty_state.dart` | `_controller`, `_pulseController` | 180ms, 2800ms | `easeInOut`, `easeInOutSine` | **Infinite** (`_pulseController`) | **NO** | Safe (`dispose()`) |
| 28 | `ecardo_error_view.dart` | `_controller`, `_pulseController` | 180ms, 2000ms | `easeInOut`, `easeOutQuad` | **Infinite** (`_pulseController`) | **NO** | Safe (`dispose()`) |
| 29 | `maintenance_mode.dart` | `_rotationController`, `_pulseController`, `_fadeController` | 10s, 2s, 1200ms | `easeInOut`, `easeOut` | **Infinite** (Gears & Pulse) | **NO** | Safe (`dispose()`) |
| 30 | `sign_up_bonus_pop_up.dart` | `_controller` | 1200ms | `easeOut` | **Infinite** (`repeat(rev: true)`) | **NO** | Safe (`dispose()`) |

---

## 3. TabController Inventory

Nine modules manage explicit `TabController`s bound to `SingleTickerProviderStateMixin`. All 9 properly release their controller inside `dispose()`:

1. `lib/src/remitv2/screens/remittance_track_screen.dart` (`_tabController.dispose()`)
2. `lib/src/commercial/screens/commercial_projects_screen.dart` (`_tabController.dispose()`)
3. `lib/src/commercial/screens/equity_project_detail_screen.dart` (`_tabController.dispose()`)
4. `lib/src/stock/screens/stock_tracking_screen.dart` (`_tabController.dispose()`)
5. `lib/src/rental/screens/rental_home_screen.dart` (`_tabController.dispose()`)
6. `lib/src/presentation/screens/travel/insurance/insurance_claim_screen.dart` (`_tabController.dispose()`)
7. `lib/src/tour/screens/tour_detail_screen.dart` (`_tabController.dispose()`)
8. `lib/src/license/view/license_my_licenses_screen.dart` (`_tabController.dispose()`)
9. `lib/src/license/view/license_detail_screen.dart` (`_tabController.dispose()`)

---

## 4. Implicit Animations & Transitions Inventory

94 files across `lib/` utilize Flutter's implicit animation widgets. The breakdown by widget type:
- **`AnimatedContainer`** (46 files): Used heavily for filter chip selection, expandable transaction rows, card border gradients, and button state transitions (typical durations: 150ms–300ms, `Curves.easeInOutCubic`).
- **`AnimatedOpacity` / `AnimatedCrossFade`** (24 files): Used for step transitions, error banners, and conditional action buttons.
- **`AnimatedSwitcher`** (12 files): Used for currency code switching, numeric balance updates, and live rate tickers.
- **`AnimatedPositioned` / `AnimatedAlign`** (7 files): Used in custom toggle switches, sliding tabs, and camera alignment guides.
- **`AnimatedSize`** (5 files): Used in accordion dropdowns and bottom sheets.

**Accessibility Risk:** Standard implicit animations (e.g. `AnimatedContainer(duration: const Duration(milliseconds: 250))`) continue to animate even when `MediaQuery.disableAnimations` is true on the system level, unless explicitly wrapped in a duration ternary: `duration: disableAnimations ? Duration.zero : const Duration(milliseconds: 250)`. Currently, **zero** implicit animations in the codebase implement this zero-duration bypass.

---

## 5. Background Timers & Polling Loops

15 files instantiate `Timer.periodic`. These drive auto-scrolling carousels, rate refreshes, OTP countdowns, and chat polling:

| File Path | Interval | Purpose | Cancelled in `dispose()`? |
| :--- | :---: | :--- | :---: |
| `authentication/welcome/view/welcome_screen.dart` | 4s | Auto-advancing onboarding carousel | **YES** (`_autoSlideTimer?.cancel()`) |
| `authentication/sign_in/controller/email_otp_login_controller.dart` | 1s | OTP resend countdown | **YES** (`onClose()`) |
| `authentication/sign_up/controller/verify_email_controller.dart` | 1s | Email verification countdown | **YES** (`onClose()`) |
| `authentication/forgot_password/.../forgot_password_pin_verification_controller.dart` | 1s | Reset PIN countdown | **YES** (`onClose()`) |
| `dynamic_password/view/dynamic_password_screen.dart` | 1s | 60-second TOTP token progress bar | **YES** (`dispose()`) |
| `exchange/service/exchange_rate_manager.dart` | Configurable | Background exchange rate quote polling | **YES** (`onClose()`) |
| `exchange/service/exchange_rate_service.dart` | Configurable | Live rate timer | **YES** (`onClose()`) |
| `p2p/controller/p2p_order_details_controller.dart` | 1s | P2P escrow payment window countdown | **YES** (`onClose()`) |
| `p2p/sub_category/my_order/chat/controller/order_chat_controller.dart` | 12s | P2P live order chat message polling | **YES** (`onClose()`) |
| `remittance/controller/remittance_controller.dart` | 1s | Remittance rate lock countdown | **YES** (`onClose()`) |
| `settings/view/support_tickets/replay_ticket/replay_ticket.dart` | 6s | Support ticket message poll | **YES** (`dispose()`) |
| `travel/bookings/travel_checkout_screen.dart` | 1s | Seat reservation hold countdown | **YES** (`dispose()`) |
| `travel/taxi/taxi_controller.dart` | Configurable | Driver location update simulation | **YES** (`onClose()`) |
| `virtual_card/widgets/virtual_card_security_controls.dart` | 1s | Dynamic CVV countdown timer | **YES** (`dispose()`) |
| `license/controller/license_controller.dart` | 1s | Software license delivery poll | **YES** (`onClose()`) |

---

## 6. Critical Findings & Motion Vulnerabilities

### Finding M-1: Perpetual Infinite Tickers (15 Components)
- **Impact:** High battery drain and GPU thermal throttling on low-end devices.
- **Root Cause:** Half of the explicit animation controllers in the app call `.repeat(reverse: true)` or `.repeat()` without any restriction on whether the screen is currently visible or in the foreground.
- **Examples:**
  - `ecardo_swipe_button.dart`: The linear gradient shimmer runs continuously (`1800ms`) even when the button is idle.
  - `live_rate_badge.dart`: Runs a continuous 1400ms pulse.
  - `document_alignment_guide.dart`: Runs a 2500ms laser scan animation perpetually.
  - `maintenance_mode.dart`: 3 concurrent controllers (10s rotation, 2s pulse, 1.2s fade) running simultaneously.
  - `sign_in_screen.dart`: `_bioPulseCtrl` pulses indefinitely while on the login screen.

### Finding M-2: The Test Bypass Anti-Pattern (`contains('Test')`)
- **Impact:** Technical debt and fragile testing infrastructure.
- **Root Cause:** Because infinite tickers cause `tester.pumpAndSettle()` in Flutter widget tests to time out after 10 minutes, developers hardcoded a runtime type check:
  ```dart
  final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
  if (!isTest) {
    _controller.repeat(reverse: true);
  } else {
    _controller.value = 1.0;
  }
  ```
- **Affected Files:**
  - `lib/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart` (L58)
  - `lib/src/presentation/screens/kyc_level/view/kyc_level_roadmap.dart` (L63)
  - `lib/src/presentation/screens/home/view/sub_sections/recent_transactions_section.dart` (L947)
- **Problem:** Inspecting the string representation of `WidgetsBinding.instance.runtimeType` at runtime is brittle and obscures accessibility intent. It bypasses tests without providing any benefit to real users with vestibular disorders.

### Finding M-3: Systemic Non-Compliance with Reduce-Motion
- **Impact:** Violation of WCAG 2.1 Success Criterion 2.3.3 (Animation from Interactions - Level AAA) and Android/iOS system accessibility guidelines.
- **Finding:** Only **1 single file** (`ecardo_glass_card.dart`) in the entire repository inspects `MediaQuery.maybeOf(context)?.disableAnimations`. The remaining 29 animation files, 9 tab files, and 94 implicit animation files unconditionally trigger motions, bounces, pulses, and shakes even when users explicitly activate "Remove animations" in their operating system settings.

### Finding M-4: Multiple Unbounded Status Dots in List Feeds
- In `recent_transactions_section.dart`, every single pending transaction row mounts an individual `_PulsingDot` widget containing its own `AnimationController` ticking at 800ms. In an account with 8 pending transactions, 8 separate tickers fire concurrently on every vsync signal.

---

## 7. Remediation Blueprint & Action Plan

### 1. Introduce `AppMotion` Global Token Helper
Create `lib/src/app/constants/app_motion.dart` defining standard motion tokens:
```dart
class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration expressive = Duration(milliseconds: 400);

  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveEntrance = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;

  /// Returns Duration.zero if the system requested reduced motion.
  static Duration duration(BuildContext context, Duration standardDuration) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return reduceMotion ? Duration.zero : standardDuration;
  }
}
```

### 2. Replace String-Check Hack with `useSafeAnimation`
Replace the `contains('Test')` string hack across `kyc_tier_upgrade_card.dart`, `kyc_level_roadmap.dart`, and `recent_transactions_section.dart` with standard `disableAnimations` logic:
```dart
final disableMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
if (!disableMotion) {
  _controller.repeat(reverse: true);
} else {
  _controller.value = 1.0;
}
```

### 3. Idle Shimmer Optimization in `EcardoSwipeButton`
Modify `_shimmerController` in `ecardo_swipe_button.dart` to only run when the user is actively dragging the slider, or limit shimmer pulses to 2 cycles upon initial mount rather than continuous `.repeat()`.
