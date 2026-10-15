# eCardo — Neo-Fintech Visual Design Specification (DX-005)

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa (2).md` — Sections 13, 14, 20 & Task DX-005  
**Compliance Standards:** Apple Human Interface Guidelines (2026), Material Design 3, W3C WCAG 2.2 Level AA/AAA  
**Target Platform:** Flutter 3.x Multi-Platform (iOS, Android, Web)

---

## 1. Visual Design Philosophy & Dual-Concept Architecture

eCardo's visual identity balances technical precision with organic human warmth. As an international financial bridge linking Persian Sheba and debit rails with global multi-currency accounts, travel systems, and digital asset custody, the design language communicates **fail-safe solidity**, **immediate clarity**, and **refined craftsmanship**.

> **«آشنا در استفاده، متمایز در شخصیت، شفاف در پول، دقیق در اجرا.»**  
> *"Familiar in use, distinctive in character, transparent in money, meticulous in execution."*

```
┌────────────────────────────────────────────────────────────────────────┐
│                        eCardo Visual Synthesis                        │
├──────────────────────────────────┬─────────────────────────────────────┤
│     Concept A: Dark Neofintech   │       Concept B: Ambient Glass      │
│  - Deep Black (#161614) canvas   │  - Multi-layer backdrop blur (20px) │
│  - Layered card tiers (1E1E1C)   │  - Hero Night Gradient (1A1F36...)  │
│  - Razor 1px specular borders    │  - Specular gradient rim lighting   │
│  - Tactical Neo-Lime & Amber CTAs│  - Luminous radial portfolio aura   │
└──────────────────────────────────┴─────────────────────────────────────┘
                                   │
                                   ▼
             [Synthesized eCardo Neo-Fintech Design System]
```

### 1.1 Concept A: "Dark Neofintech" (Tactical Precision)
- **Aesthetic:** High-density, instrument-grade financial surface inspired by Bloomberg Terminal elegance and modern high-frequency trading dashboards.
- **Surfaces:** Deep OLED black foundations (`#161614`) paired with dark basalt cards (`#1E1E1C` and `#262624`) and sunken input wells (`#0E0E0C`).
- **Highlights:** High-chroma Neo-Lime (`#D4FF00`) and Tactical Amber (`#FFAA00` / `#D9A94A`) reserved strictly for interactive confirmation sliders, active states, and critical PnL metrics.

### 1.2 Concept B: "Ambient Glass" (Atmospheric Depth)
- **Aesthetic:** Luminous, spatial banking environment utilizing physical depth cues, refractive glass sheets, and diffused night gradients.
- **Lighting:** Signature `heroNightGradient` (`#1A1F36` $\rightarrow$ `#2A3B5C` $\rightarrow$ `#442E7A`) on flagship surfaces, paired with frosted `BackdropFilter` layers (sigma 16–24px).
- **Specular Borders:** Subtle directional 1px perimeter gradients simulating top-down raking ambient light (18% white at top-left fading to 3% at bottom-right).

### 1.3 The eCardo Synthesis
The live production architecture combines both approaches:
1. **Structural Foundation:** Concept A's strict tier-based surface tokens and 8px rhythm provide unbeatable readability, contrast, and performance.
2. **Flagship Moments:** Concept B's ambient lighting and specular glass cards are deployed on hero balance modules, digital receipt tickets, and swipe confirmation controls.

---

## 2. Color Palette Specification

All color tokens are formalized in `lib/src/app/constants/app_colors.dart` and `lib/src/common/theme/ecardo_tokens.dart`. Hardcoded hexadecimal values in UI views are prohibited.

### 2.1 Primary & Neutral Foundations

| Token Name | Hex Code | Flutter Color Constant | Role & Semantic Purpose |
| :--- | :--- | :--- | :--- |
| `deepBlack` | `#161614` | `Color(0xFF161614)` | Primary dark canvas, OLED-optimized app background |
| `cardTier1` | `#1E1E1C` | `Color(0xFF1E1E1C)` | Base card layer, bottom sheet backdrop, list tiles |
| `cardTier2` | `#262624` | `Color(0xFF262624)` | Elevated modal dialogs, segmented controls, popovers |
| `sunkenSurface`| `#0E0E0C` | `Color(0xFF0E0E0C)` | Sunken text input fields, search boxes, track wells |
| `warmWhite` | `#E7E0DE` | `Color(0xFFE7E0DE)` | Primary text in dark mode, light mode surface card |
| `lightWarmGray`| `#D5CBC8` | `Color(0xFFD5CBC8)` | Subtle border outlines, ticket perforation lines |
| `softGray` | `#656262` | `Color(0xFF656262)` | Secondary metadata, timestamps, inactive icons |
| `lightCanvas` | `#F5F7FB` | `Color(0xFFF5F7FB)` | Primary light mode canvas background |
| `lightSurface` | `#FFFFFF` | `Color(0xFFFFFFFF)` | Light mode elevated card and sheet surface |
| `lightSunken` | `#EBEDF4` | `Color(0xFFEBEDF4)` | Light mode input field fill, skeleton base |

### 2.2 Brand Violet Core & Accents

| Token Name | Hex Code | Contrast Ratio | Usage Rule |
| :--- | :--- | :--- | :--- |
| `brandViolet` | `#7445FF` | 5.2:1 on `#FFFFFF` | Primary action button fill, active tab tint, brand badges |
| `brandVioletDeep` | `#5A35CC` | 8.1:1 on `#FFFFFF` | Button pressed state, gradient end-stop, focused ring |
| `brandVioletSoft` | `#B79CFF` | 9.8:1 on `#161614` | Primary accent in dark theme, dark mode link text |
| `brandContainerLight` | `#F0ECFF` | — | Background for violet icon badges and tags in light mode |
| `brandContainerDark` | `#2B2159` | — | Background for violet icon badges and tags in dark mode |

### 2.3 Tactical Accents (Neo-Lime, Amber & Teal)

| Token Name | Hex Code | Contrast Ratio | Usage Rule |
| :--- | :--- | :--- | :--- |
| `neoLime` | `#D4FF00` | 13.5:1 on `#161614` | High-energy financial highlights, PnL positive spike, swipe thumb |
| `amberGold` | `#FFAA00` | 9.2:1 on `#161614` | Pending escrow badge, VIP tier badge, warning banners |
| `sand600` | `#D9A94A` | 7.6:1 on `#161614` | Secondary text link («مشاهده همه»), golden accent chips |
| `secondaryTeal` | `#00BFA6` | 9.1:1 on `#161614` | Travel service chips, secondary CTAs, crypto USDT rail indicator |
| `tealContainerDark` | `#0E3A34` | — | Dark mode container behind teal accents |
| `tealContainerLight`| `#E0F8F5` | — | Light mode container behind teal accents (paired with `#00695C` text) |

### 2.4 Financial Status Colors

Financial indicators must never rely exclusively on color; they must pair with explicit directional icons ($\uparrow$, $\downarrow$, $\odot$) or descriptive text.

| Status | Dark Value | Light Value | Container (Dark / Light) | Semantic Meaning |
| :--- | :--- | :--- | :--- | :--- |
| **Success** | `#4FBD80` | `#15713F` | `#12301F` / `#E8F8F0` | Deposits, settled transfers, completed KYC, verified cards |
| **Warning** | `#E0AE4D` | `#8A5A00` | `#312408` / `#FFF8E1` | Pending escrow, network congestion, expiring rate quotes |
| **Danger** | `#F08A82` | `#A3231C` | `#351714` / `#FDECEA` | Debits, transfer failed, blocked account, validation error |
| **Info** | `#76B6E2` | `#1D5C8A` | `#10293A` / `#E3F2FD` | Remittance route update, exchange holiday notice, system tips |

---

## 3. Elevation, Borders & Glass Surface Tokens

eCardo rejects heavy drop shadows in favor of **ambient surface luminance** and **specular hairline borders**. Depth is established by step-wise lightening of dark surfaces and precise 1px perimeter lighting.

```
Elevation Hierarchy:
Level 4: Floating Quick-Action / Snackbars ────► Blur: 16px, Offset: (0, 6), Color: #000000 40%
Level 3: Bottom Sheets / Modals ──────────────► Blur: 24px, Offset: (0, -8), Color: #000000 50%
Level 2: Elevated Segmented Rows / Dropdowns ─► Surface: #262624, Border: 1px 18% alpha
Level 1: Base Content Cards / List Tiles ─────► Surface: #1E1E1C, Border: 1px 10% alpha
Level 0: OLED Base Canvas ─────────────────────► Surface: #161614 (0dp elevation)
```

### 3.1 Surface Elevation System

| Elevation Tier | Dark Value | Light Value | Border Spec | Typical Widget |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 0 (Canvas)** | `#161614` | `#F5F7FB` | None | Scaffold background, route canvas |
| **Tier 1 (Base Card)** | `#1E1E1C` | `#FFFFFF` | 1px `borderSubtle` | Transaction list cards, wallet cards |
| **Tier 2 (Elevated)** | `#262624` | `#F0F2F6` | 1px `borderMedium` | Dropdown sheets, active chips, dialogs |
| **Tier 3 (Overlay)** | `#2A2A28` | `#FFFFFF` | 1px `borderStrong` | Bottom modal sheets, full-screen dialogs |
| **Tier 4 (Floating)** | `#323230` | `#FFFFFF` | 1.5px `borderGlow` | Toast banners, floating pill action bars |

### 3.2 Border Tokens & Raking Specular Lighting

In dark neofintech aesthetics, cards appear floating due to subtle light reflections along their top edges:

```dart
// Specular border gradient for ambient glass cards
BoxDecoration(
  color: ECardoTokens.isDark(context) 
      ? const Color(0xFF1E1E1C).withValues(alpha: 0.88) 
      : Colors.white,
  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl), // 18.0
  border: Border.all(
    width: 1.0,
    color: ECardoTokens.isDark(context)
        ? const Color(0xFFE7E0DE).withValues(alpha: 0.12)
        : const Color(0xFFD2D5E0).withValues(alpha: 0.60),
  ),
)
```

| Token | Dark Border Color | Light Border Color | Width | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `borderSubtle` | `Color(0x1AE7E0DE)` (10%) | `Color(0xFFE7EAEE)` | 1.0 dp | List separators, table borders |
| `borderMedium` | `Color(0x2EE7E0DE)` (18%) | `Color(0xFFD5CBC8)` | 1.0 dp | Interactive cards, unselected inputs |
| `borderStrong` | `Color(0x4DE7E0DE)` (30%) | `Color(0xFFB3A9A5)` | 1.5 dp | Active cards, modal headers |
| `borderFocused`| `Color(0xFFB79CFF)` (100%)| `Color(0xFF7445FF)` | 2.0 dp | Focused text field, active slider ring |
| `borderError`  | `Color(0xFFF08A82)` (100%)| `Color(0xFFDC3C22)` | 1.5 dp | Input validation failure |

### 3.3 Ambient Glass & Signature Gradients

#### Hero Night Gradient (Flagship Accounts & Virtual Cards)
```dart
static const LinearGradient heroNightGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1A1F36), // Deep Navy
    Color(0xFF2A3B5C), // Midnight Slate
    Color(0xFF442E7A), // Royal Indigo
  ],
  stops: [0.0, 0.45, 1.0],
);
```

#### Ambient Portfolio Light-Field
Behind the balance hero, a subtle radial gradient aura blooms to communicate real-time market or account direction:
- **Positive Day ($+\Delta$):** Radial aura of `Color(0xFF00BFA6).withValues(alpha: 0.14)`, radius 180dp.
- **Negative Day ($-\Delta$):** Radial aura of `Color(0xFFDC3C22).withValues(alpha: 0.10)`, radius 180dp.
- **Neutral / Stable:** Radial aura of `Color(0xFF7445FF).withValues(alpha: 0.12)`, radius 180dp.

---

## 4. Micro-Interaction & Motion Guidelines

Motion in eCardo serves one primary purpose: **communicating state transformation and confidence in money**. Whimsical, gratuitous, or lagging animations are prohibited.

### 4.1 Duration Hierarchy

| Category | Duration Window | Use Cases |
| :--- | :--- | :--- |
| **Instant / Micro** | `80 ms – 140 ms` | Button press squish, checkbox toggle, eye privacy cross-fade |
| **Standard / Component** | `180 ms – 260 ms` | Accordion expand/collapse, tab-bar indicator slide, input focus ring |
| **Macro / Structural** | `280 ms – 360 ms` | Bottom sheet enter/exit, route transitions, modal pop-ups |
| **Physics Snap / Inertia**| `300 ms – 380 ms` | Swipe-to-confirm spring release, slider snap-back |
| **Atmospheric Ambient** | `1800 ms – 2800 ms` | Empty state breathing glow, radar warning pulse, shimmer hint |

### 4.2 Easing Curves

1. **Standard Enter / Exit:** `Curves.fastOutSlowIn` (Flutter's native Cubic(0.4, 0.0, 0.2, 1.0)) — used for 90% of layout transitions.
2. **Spring Snap-Back:** `Curves.easeOutBack` or `Curves.easeOutCubic` — used when a user cancels a swipe button before the threshold.
3. **Deceleration for Entrances:** `Curves.easeOutQuad` — used when bottom sheets rise into view.
4. **Acceleration for Dismissals:** `Curves.easeInQuad` — used when sheets or snackbars are swiped away.
5. **Continuous Ambient Pulses:** `Curves.easeInOutSine` — used for breathing glow in `EcardoEmptyState` and radar rings in `EcardoErrorView`.

### 4.3 Tactile Haptics System (`AppHaptics`)

Haptic feedback is tightly coupled with visual motion to provide tactile confirmation for financial actions:

| Action / Event | Method | Haptic Pattern | Intent |
| :--- | :--- | :--- | :--- |
| **Standard Tap** | `AppHaptics.light()` | Light impact (subtle click) | Tab switch, filter chip tap, eye privacy toggle |
| **Picker / Slider Tick** | `AppHaptics.selection()` | Selection click (crisp tick) | Shamsi date cell tap, slider drag passes 50% milestone |
| **Confirmation Threshold** | `AppHaptics.medium()` | Medium impact (solid tap) | Swipe-to-confirm crosses 85% threshold, biometric prompt opens |
| **Financial Execution** | `AppHaptics.heavy()` | Heavy impact (deep thud) | Irreversible transfer dispatched, order settled, cashout confirmed |
| **Validation / Error** | `AppHaptics.error()` | Dual buzz / vibration | Insufficient funds, invalid Sheba, card expired, network timeout |

### 4.4 Reduced Motion Accessibility Mode

The app strictly respects system accessibility settings:
```dart
final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
```
- When `reduceMotion == true`:
  - Shimmer sweeps and breathing glow loops are stopped immediately.
  - Page transitions become instant or simple opacity cross-fades ($100\text{ ms}$).
  - Spring-physics sliders snap instantly to position without inertia bounce.
  - Financial numbers display final values immediately without counting ticker animations.

---

## 5. Visual Hierarchy & Financial Typography

### 5.1 Dual-Font Strategy
- **Persian / Arabic Scripts (`fa`, `ar`):** `Vazirmatn` font family. Optimized for Arabic-script legibility, baseline alignment, and balanced ascenders/descenders.
- **Latin / International Scripts (`en`, `tr`, `ru`, `zh`):** `Plus Jakarta Sans`. Contemporary geometric sans-serif with high x-height and open apertures.

### 5.2 Numeric Formatting Standards
Financial values are critical. The visual system enforces:
1. **Split Integer & Fraction:** In large hero displays, the fractional decimals (e.g. `.50`) and currency ticker are styled at 60% of the integer font size.
2. **Tabular Figures:** Numbers in tables and transaction receipts use monospace or tabular figure settings (`fontFeatures: [FontFeature.tabularFigures()]`) to prevent jitter during real-time updates.
3. **Persian Digits in Persian UI:** While domestic Iranian banking uses Eastern Arabic/Persian digits (`۰۱۲۳۴۵۶۷۸۹`), international currency codes (USD, EUR, USDT) retain standard Latin digits to prevent ambiguity.

---

## 6. Implementation Reference Checklist for Engineers

- [ ] All colors referenced through `AppColors` or `ECardoTokens` (no inline `Color(0x...)`).
- [ ] Contrast ratios independently checked against `#161614` in dark mode and `#FFFFFF` in light mode.
- [ ] Every button tap triggers the corresponding `AppHaptics` method.
- [ ] Interactive elements support `Curves.fastOutSlowIn` within 150–250ms duration.
- [ ] Glass cards utilize `BackdropFilter` with `ImageFiltered` containment to prevent GPU overhead.
- [ ] All inputs and cards declare explicit RTL mirroring or direction-agnostic geometry.
