# Duplicate Components & Widget Convergence Catalog

> **Audit Date:** 2026-10-20  
> **Target:** `lib/src/presentation/screens` and Shared UI Layers  
> **Companion Files:** `TOKEN_DRIFT_REPORT.csv`, `COMPONENT_ADOPTION_MATRIX.csv`, `DESIGN_SYSTEM_AUDIT_SUMMARY.md`

---

## 1. Executive Summary

This catalog documents visual and architectural redundancy across the eCardo Flutter user application. While the core design system library (`lib/src/common/widgets/design_system/`) provides 6 high-quality flagship components (`EcardoGlassCard`, `EcardoBalanceHero`, `EcardoSwipeButton`, `EcardoDigitalReceipt`, `EcardoEmptyState`, `EcardoErrorView`), ad-hoc implementations of recurring fintech UI patterns have proliferated across domain modules.

The primary drivers of duplication are:
1. **Status Badges & Pills:** 12+ separate badge/pill implementations with divergent border radii, tint opacities, and icon-to-text spacings.
2. **Amount Inputs & Selectors:** Repeated currency/amount step cards, custom decimal formatters, and quick-amount chips across 11 financial flows.
3. **Custom Surface & Card Wrappers:** Re-implementations of frosted glass, gradient hero surfaces, and action tiles that bypass `EcardoGlassCard`.
4. **Monograms & User Avatars:** 5 separate avatar painters generating initial-based circular or rounded avatars.
5. **PIN & Keypad Patterns:** Divergent PIN dot indicators and custom numeric keypads scattered between authentication, security lock, and virtual cards.
6. **Step Progress Indicators:** 5 disjointed step bars across auth, escrow, guarantee, loan, and KYC wizards.

Each catalog entry below provides exact `file:line` locations, root cause analysis, and a definitive architectural recommendation: **Extract to Design System** vs. **Keep Local (Refactor Styling)**.

---

## 2. Status Badges & Semantic Pills

Status badges convey financial transaction and verification states (e.g. `completed`, `pending`, `processing`, `failed`, `rejected`, `frozen`). Currently, individual modules implement their own badges, leading to inconsistent color saturations and accessibility regressions (WCAG 1.4.1 color-only indicators).

### Catalog of Implementations

| Component Symbol | Location (`file:line`) | Visual Spec & Styling | Current Domain |
|---|---|---|---|
| `EscrowStatusBadge` | `lib/src/escrow/widgets/escrow_widgets.dart:10` | Container with 12px radius, tinted background, uppercase status label | Escrow transactions |
| `_KycStatusBadge` | `lib/src/presentation/screens/home/view/sub_sections/user_profile_section.dart:336` | Custom pill badge with tier text (`Unverified`, `Tier 1`, `Tier 2`) and status dot | Dashboard profile header |
| `_CryptoMiniBadge` | `lib/src/presentation/screens/exchange/view/exchange_history/exchange_history.dart:354` | Mini crypto ticker pill with subtle border and text | Exchange history list |
| `_WalletMiniBadge` | `lib/src/presentation/screens/exchange/view/sub_sections/exchange_review_step_section.dart:540` | Rounded pill with wallet icon and balance tag | Exchange review step |
| `_LightCryptoBadge` | `lib/src/presentation/screens/exchange/widgets/exchange_swap_card.dart:678` | Glassmorphic chip for light theme currency display | Exchange swap card |
| `_DarkCryptoBadge` | `lib/src/presentation/screens/exchange/widgets/exchange_swap_card.dart:705` | Glassmorphic chip for dark theme currency display | Exchange swap card |
| `LiveRateBadge` | `lib/src/presentation/screens/exchange/widgets/live_rate_badge.dart:20` | Pulsing real-time FX rate indicator with timer dot | Exchange real-time rate |
| `_OperatorLogoBadge` | `lib/src/presentation/screens/bill_payment/view/widgets/operator_selector_widget.dart:241` | Rounded logo pill for utility/telecom operator | Bill payments |
| `_buildPriorityBadge` | `lib/src/presentation/screens/settings/view/support_tickets/support_tickets.dart:1253` | Ad-hoc ticket status & priority pill (`Open`, `Pending`, `Closed`) | Support tickets |
| Roadmap Status Nodes | `lib/src/presentation/screens/kyc_level/view/kyc_level_roadmap.dart:828` | Literal colored nodes (`Color(0xFF10B981)`, `Color(0xFFF59E0B)`) with status text | KYC tier progression |
| P2P Ad / Order Status | `lib/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_title_block_widget.dart:335` | Custom banner pill with red/amber/green status | P2P trade status |
| Card Status Indicator | `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart:489` | Frozen / Active pill with toggle glow | Virtual card controls |

### Architectural Recommendation: **EXTRACT TO DESIGN SYSTEM**
- **Target Component:** `lib/src/common/widgets/design_system/ecardo_status_badge.dart` (`EcardoStatusBadge`).
- **Unified API:**
  ```dart
  enum EcardoStatusType { success, warning, error, info, neutral, pending }
  enum EcardoBadgeSize { sm, md, lg }

  class EcardoStatusBadge extends StatelessWidget {
    final String label;
    final EcardoStatusType status;
    final EcardoBadgeSize size;
    final IconData? icon;
    final bool showDot;
    final bool pulseDot;
  }
  ```
- **Rationale:** Unifying these 12 variants ensures WCAG 1.4.1 compliance (guaranteed icon/dot + localized text), enforces `AppColors.success`, `warning`, `error`, `info` container tokens, and eliminates over 450 lines of duplicate UI boilerplate.

---

## 3. Amount Displays, Inputs & Quick-Selectors

Handling financial numbers requires currency symbols, decimal point scaling, balance affordances, and quick-percent buttons. 11 screens independently implement amount input scaffolding.

### Catalog of Implementations

| Component Symbol | Location (`file:line`) | Implementation Characteristics | Current Domain |
|---|---|---|---|
| `QuickAmountSelector` | `lib/src/common/widgets/input_field/quick_amount_selector.dart:12` | Horizontal list of preset percentages (25%, 50%, 75%, 100%) | Shared widget |
| `QuickAmountSelectorWidget` | `lib/src/presentation/screens/bill_payment/view/widgets/quick_amount_selector_widget.dart:22` | Bill payment amount packages with title, amount, and discount tag | Bill payment packages |
| `_QuickAmountChip` | `lib/src/presentation/screens/bill_payment/view/widgets/quick_amount_selector_widget.dart:129` | Re-implementation of selectable choice chip with manual borders | Bill payment amounts |
| `AddMoneyAmountStepSection` | `lib/src/presentation/screens/add_money/view/sub_sections/add_money_amount_step_section.dart:19` | Currency dropdown prefix + large font amount input + limits text | Deposit flow |
| `CashOutAmountStepSection` | `lib/src/presentation/screens/cash_out/view/sub_sections/cash_out_amount_step_section.dart:27` | Currency indicator + amount field + available balance subtext | Cash-out flow |
| `ExchangeAmountStepSection` | `lib/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart:30` | Dual currency input cards with interactive swap icon | Currency exchange |
| `TransferAmountStepSection` | `lib/src/presentation/screens/transfer/view/sub_sections/transfer_amount_step_section.dart:20` | Recipient card summary + amount field + fee breakdown hint | P2P transfer |
| `WithdrawAmountStepSection` | `lib/src/presentation/screens/withdraw/view/sub_sections/withdraw_amount_step_section.dart:18` | Destination account header + amount input + daily limit bar | Fiat withdrawal |
| Bill Amount Steps (x6) | `lib/src/presentation/screens/bill_payment/view/*/sub_sections/*_amount_step_section.dart` | 6 copies of amount input cards across airtime, cable, data, electricity, internet, toll | Bill utilities |

### Architectural Recommendation: **HYBRID (EXTRACT FIELD + KEEP FLOW LOCAL)**
1. **Extract `EcardoAmountInputField` to Design System:**
   - **Target:** `lib/src/common/widgets/design_system/ecardo_amount_input_field.dart`.
   - **Features:** Auto-formatting decimal separator (via `AmountInputFormatter`), localized currency prefix/suffix, dynamic text scaling clamp (prevents layout overflow at 1.5x font scale), available balance indicator with "Use Max" shortcut, and integrated limit validation.
2. **Extract `EcardoQuickAmountSelector` to Design System:**
   - Consolidate `quick_amount_selector.dart` and `quick_amount_selector_widget.dart` into a single responsive chip group supporting both percentage presets (`25%, 50%, Max`) and fixed currency tiers (`$10, $25, $50, $100`).
3. **Keep Local:** The step wizard controllers and outer layout wrappers (`*_amount_step_section.dart`) remain in their respective feature folders, but delegate their core card and input mechanics to the new design system components.

---

## 4. Custom Cards & Surface Containers

`EcardoGlassCard` was created to serve as the signature surface container for neo-fintech elevations. However, numerous screens continue to manually build `BoxDecoration` objects with hardcoded `BoxShadow`, `BackdropFilter`, and arbitrary border strokes.

### Catalog of Implementations

| Component Symbol | Location (`file:line`) | Duplication Details | Recommendation |
|---|---|---|---|
| `_FromCard` & `_ToCard` | `lib/src/presentation/screens/exchange/widgets/exchange_swap_card.dart:193, 348` | Custom container with manual gradient, radial glow, and border | **Refactor to `EcardoGlassCard`:** Use `EcardoGlassVariant.frosted` and brand gradient override. |
| `BillReviewReceiptCard` | `lib/src/presentation/screens/bill_payment/view/widgets/bill_review_receipt_card.dart:8` | Ticket container mimicking digital receipt | **Migrate to `EcardoDigitalReceipt`:** Directly replace with the design system receipt. |
| `_OperatorCard` | `lib/src/presentation/screens/bill_payment/view/widgets/operator_selector_widget.dart:133` | Grid selection card with manual hover/press state | **Extract `EcardoSelectionCard`:** Standardize selectable grid cards. |
| `_RecentBillCard` | `lib/src/presentation/screens/bill_payment/view/widgets/recent_favorite_bills_strip.dart:209` | Horizontal scroll card with provider logo and quick re-pay | **Keep Local:** Refactor background and border to `AppColors` and `AppSpacing.radiusLg`. |
| `OtherSessionCard` | `lib/src/presentation/screens/device_sessions_security/view/widgets/other_session_card.dart:15` | Elevated device card with IP, location, and revoke action | **Refactor to `EcardoGlassCard`:** Use `EcardoGlassVariant.flat` or `elevated`. |
| `ThisDeviceHeroCard` | `lib/src/presentation/screens/device_sessions_security/view/widgets/this_device_hero_card.dart:17` | Hero card with gradient background and green active badge | **Refactor to `EcardoGlassCard`:** Use `EcardoGlassVariant.gradient`. |
| `P2pAdCard` | `lib/src/presentation/screens/p2p/widgets/p2p_ad_card.dart:71` | Complex financial offer card with pricing, limits, and payment methods | **Keep Local:** Retain complex domain layout; replace manual container decoration with `EcardoGlassCard`. |
| `TransferRecipientCard` | `lib/src/presentation/screens/transfer/view/widgets/transfer_recipient_card.dart:162` | Verified counterparty card with monogram and verification tag | **Refactor to `EcardoGlassCard`:** Delegate surface container; use unified avatar. |
| `TransferPathCard` | `lib/src/presentation/screens/transfer/view/widgets/transfer_path_card.dart:10` | Selection card for transfer destination (Internal, SEPA, SWIFT) | **Refactor to `EcardoGlassCard`:** Standardize interactive selection states. |
| `WithdrawBreakdownCard` | `lib/src/presentation/screens/withdraw/view/widgets/withdraw_breakdown_card.dart:9` | Summary card displaying principal, fee, and arrival time | **Keep Local:** Delegate background to `EcardoGlassCard`. |
| `MultiCurrencyFlipCard` | `lib/src/presentation/screens/wallets/widgets/multi_currency_flip_card.dart:160` | 3D debit card with EMV chip painter, metallic gradients, and flip physics | **Keep Local:** Specialized fintech pattern; extract crypto gradient tokens into design system. |
| `CommonVirtualCardView` | `lib/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart:27` | Virtual card canvas with card number masking, CVV reveal, and freeze overlay | **Keep Local:** High domain complexity; align colors with `AppColors`. |

---

## 5. Monograms & User / Entity Avatars

5 distinct widgets render circular or rounded-rectangular monogram avatars by taking initials and computing background tint hashes.

### Catalog of Implementations

| Component Symbol | Location (`file:line`) | Features | Duplication Analysis |
|---|---|---|---|
| `MonogramAvatar` | `lib/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart:13` | Computes hash of name string to pick from 10 hardcoded colors | High visual drift; bypasses `AppColors` palette. |
| `RecipientMonogramAvatar` | `lib/src/presentation/screens/transfer/view/widgets/transfer_recipient_card.dart:31` | Circle avatar with 20px radius and brand violet tint | Duplicates initials extraction logic. |
| `EscrowCounterpartyAvatar` | `lib/src/escrow/widgets/escrow_widgets.dart:315` | Avatar with verification badge overlay (green checkmark) | Duplicates avatar painting with ad-hoc badge positioning. |
| `_WalletAvatar` | `lib/src/presentation/screens/exchange/widgets/wallet_selector_sheet.dart:360` | Currency flag or network logo with fallback initials | Duplicates avatar + fallback icon logic. |
| `_Avatar` | `lib/src/presentation/screens/home/view/sub_sections/dashboard_sliver_header.dart:273` | Profile image with initials fallback and active status ring | Header-specific avatar implementation. |

### Architectural Recommendation: **EXTRACT TO DESIGN SYSTEM**
- **Target Component:** `lib/src/common/widgets/design_system/ecardo_avatar.dart` (`EcardoAvatar`).
- **Features:** Supports image URL with caching, automatic initials extraction (supports LTR and RTL scripts), deterministic theme-compliant background palette (derived from `AppColors.brandVioletContainer`, `lightSecondaryContainer`, etc.), optional verification badge overlay, and standard size presets (`xs: 24`, `sm: 32`, `md: 40`, `lg: 48`, `xl: 64`).

---

## 6. PIN & Passcode Indicators / Keypads

High-security PIN entry is required for app lock, biometric fallback, device revocation, and high-value transfers. Currently, two disjointed approaches exist: custom text field overlays and manual `AnimatedContainer` dot rows.

### Catalog of Implementations

| Component Symbol | Location (`file:line`) | Input Type | Accessibility / Polish Regressions |
|---|---|---|---|
| `VisualPinDotsIndicator` | `lib/src/presentation/screens/device_sessions_security/view/widgets/visual_pin_dots_indicator.dart:11` | 4/6 animated dots with scale and glow | High quality; lacks screen reader semantics (WCAG 1.3.1). |
| `LockScreen` PIN Row | `lib/src/presentation/screens/settings/view/lock_screen.dart:219` | Raw 14x14 circle containers with hardcoded margins | Lacks error shake animation; hardcoded colors. |
| `LockScreen` Keypad | `lib/src/presentation/screens/settings/view/lock_screen.dart:273` | Ad-hoc GridView with text buttons and haptic feedback | Hardcoded layout; cannot be reused in transfer confirmation. |
| `ForgotPasswordPinVerification` | `lib/src/presentation/screens/authentication/forgot_password/view/sub_sections/forgot_password_pin_verification.dart:19` | Uses third-party `pin_code_fields` package | Inconsistent styling with lock screen; different aspect ratio. |
| `_CardOtpBottomSheet` | `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart:1291` | 6-digit SMS OTP input modal | Third distinct styling for digit inputs. |

### Architectural Recommendation: **EXTRACT TO DESIGN SYSTEM**
- **Target Components:**
  1. `lib/src/common/widgets/design_system/ecardo_pin_dots.dart` (`EcardoPinDots`):
     - Unifies `VisualPinDotsIndicator` and `LockScreen` dots.
     - Adds accessibility announcements ("Digit 1 entered", "PIN cleared").
     - Includes built-in error shake animation via `AnimationController`.
  2. `lib/src/common/widgets/design_system/ecardo_numeric_keypad.dart` (`EcardoNumericKeypad`):
     - Standalone on-screen keypad with 60x60dp minimum touch targets.
     - Optional biometric shortcut key and backspace key.
     - Tactile haptics via `HapticFeedback.lightImpact()`.

---

## 7. Step Progress Indicators & Multi-Stage Steppers

Multi-step wizards guide users through registration, verification, KYC, and multi-stage financial transactions. 5 separate stepper components exist.

### Catalog of Implementations

| Component Symbol | Location (`file:line`) | Features | Duplication Analysis |
|---|---|---|---|
| `AuthStepProgressBar` | `lib/src/presentation/screens/authentication/shared/auth_step_progress_bar.dart:10` | Segmented horizontal progress bar with glow | Auth-specific styling with Tailwind colors. |
| `EscrowMilestoneStepper` | `lib/src/escrow/widgets/escrow_widgets.dart:128` | Vertical stepper with checkmarks, pending dots, and connector lines | Custom escrow milestone timeline. |
| `GuaranteeStatusStepper` | `lib/src/guarantee/widgets/guarantee_status_stepper.dart:9` | Horizontal stepper tracking collateral approval | Re-implements step connector lines. |
| `LoanStatusStepper` | `lib/src/loan/widgets/loan_status_stepper.dart:26` | Multi-step loan origination tracker | Duplicates guarantee stepper structure. |
| `KycSubmitWizard` Header | `lib/src/presentation/screens/kyc_level/view/kyc_submit_wizard.dart:210` | 3-step numbered circles with active line fill | Re-implements circular numbered step tracker. |

### Architectural Recommendation: **EXTRACT TO DESIGN SYSTEM**
- **Target Component:** `lib/src/common/widgets/design_system/ecardo_step_indicator.dart` (`EcardoStepIndicator`).
- **Variants:**
  - `EcardoStepIndicator.bar`: Compact segmented horizontal progress bar (for quick flows like auth and payments).
  - `EcardoStepIndicator.numbered`: Numbered step circles with title and connector lines (for multi-stage wizards like KYC and loans).
  - `EcardoStepIndicator.timeline`: Vertical milestone stepper (for escrow and tracking).

---

## 8. Summary of Extraction Decisions

| Component Group | Proposed Design System Component | Action | Modules Impacted | Estimated Code Reduction |
|---|---|---|---|---|
| Status Badges | `EcardoStatusBadge` | **Extract** | Escrow, KYC, Exchange, P2P, Tickets, Cards | ~650 lines |
| Amount Input | `EcardoAmountInputField` | **Extract** | Add Money, Cash Out, Transfer, Withdraw, Bills | ~850 lines |
| Quick Amount Chips | `EcardoQuickAmountSelector` | **Extract** | Input Fields, Bill Payments | ~300 lines |
| Avatar & Monogram | `EcardoAvatar` | **Extract** | Beneficiary, Transfer, Escrow, Header, Exchange | ~400 lines |
| PIN Dots & Keypad | `EcardoPinDots` + `EcardoNumericKeypad` | **Extract** | Lock Screen, Security, Auth, Cards | ~550 lines |
| Multi-Step Stepper | `EcardoStepIndicator` | **Extract** | Auth, KYC, Escrow, Loans, Guarantees | ~500 lines |
| Ad-hoc Card Boxes | Migrate to `EcardoGlassCard` | **Refactor** | Exchange, Bills, Security, Transfer, Withdraw | ~700 lines |
| Domain-Specific Cards | `MultiCurrencyFlipCard`, `P2pAdCard` | **Keep Local** | Wallets, P2P (Retain domain models, tokenize styling) | 0 lines (cleaner tokens) |

**Total Estimated Technical Debt Elimination:** ~3,950 lines of redundant UI code replaced by 7 unified design system components.
