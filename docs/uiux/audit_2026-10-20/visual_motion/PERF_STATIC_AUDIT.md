# eCardo Static Performance & Architecture Audit

**Audit Date:** 2026-10-20  
**Target Codebase:** `ecardo_userapp_v1` (Flutter / Dart 3.x, App v1.0.41+41)  
**Audit Scope:** Coarse-grained reactive rebuilds (`Obx`), `BackdropFilter` GPU compositing overhead, oversized monolithic source files (>2000 lines), and list virtualization/layout constraints.

---

## 1. Executive Summary & Architecture Health

Static analysis of the eCardo presentation layer highlights strong visual polish but identifies **four systemic architectural risks** that threaten 60 FPS performance on low-end and mid-tier Android devices (Mali-G52/G57, Adreno 610/619, 2GB–4GB RAM):

1. **Coarse-Grained `Obx` Rebuild Trees:** 708 `Obx` calls across 267 files. Multiple critical screens wrap root `Scaffold` or entire scroll views inside `Obx`, causing massive widget tree re-instantiations on single property changes.
2. **Unmitigated `BackdropFilter` GPU Density:** While `docs/uiux/PERFORMANCE_PROFILE.md` states that low-end hardware bypasses blur, code inspection reveals **zero device capability checks**. The primary bottom navigation bar (`navigation_screen.dart`) runs a permanent `sigma: 20` blur directly over scrolling content with no bypass.
3. **Monolithic Mega-Files (>2000 lines):** 7 source files exceed 2,000 lines (led by `services_screen.dart` at 2,888 lines and `settings_screen.dart` at 2,820 lines), combining state management, multiple modals, layout painters, and domain logic into single files.
4. **Unoptimized Viewport Virtualization:** 86 files use eager `ListView(children: [...])` (113 instances), 18 files use `shrinkWrap: true`, and **0 of 130** `ListView.builder` instances specify `itemExtent` or `prototypeItem`.

---

## 2. Coarse-Grained Reactive Rebuilds (`Obx` Anti-Patterns)

GetX's `Obx` is designed for fine-grained leaf reactivity. However, throughout the app, developers have used `Obx` as a broad screen-level wrapper.

### The "Scaffold in Obx" Anti-Pattern (Root Tree Invalidation)
6 critical routes wrap their entire root `Scaffold` inside an `Obx` closure:

| File Path | Wrapped Root | Impact |
| :--- | :---: | :--- |
| `lib/src/app/navigation/navigation_screen.dart` (L231) | `Scaffold` | The **entire primary navigation shell** rebuilds whenever active tab, KYC banner, or network status updates. Destroys cached sub-element trees. |
| `lib/src/presentation/screens/gift_code/view/gift_code_screen.dart` (L45) | `Scaffold` | Full scaffold rebuild on tab change or balance update. |
| `lib/src/presentation/screens/withdraw/view/withdraw_screen.dart` (L48) | `Scaffold` | Full scaffold rebuild when step counter or active currency shifts. |
| `lib/src/presentation/screens/virtual_card/view/virtual_card_details/virtual_card_details.dart` (L55) | `Scaffold` | Full screen rebuild when card reveal or balance toggle fires. |
| `lib/src/loan/screens/loan_application_screen.dart` (L68) | `Scaffold` | Entire form and application shell rebuilds on any slider adjustment. |
| `lib/src/tour/screens/tour_match_screen.dart` (L82) | `Scaffold` | Root scaffold rebuilds on filter trigger. |

### The "Scrollable/Container in Obx" Anti-Pattern
Rather than wrapping only the reactive text or status indicator, `Obx` wraps entire scrolling viewports:
- **`flight_screens.dart`:** `Obx(() => ListView(...))` rebuilds the entire flight search results feed on price quote updates.
- **`travel_checkout_screen.dart`:** `Obx(() => ListView(...))` rebuilds complex ticket checkout cards.
- **`rental_home_screen.dart`:** `Obx(() => ListView(...))` discards list state.
- **`remittance_details.dart`:** `Obx(() => SingleChildScrollView(...))` rebuilds the entire multi-section detail tree.
- **`transactions_screen.dart`:** `Obx(() => Column(...))` wraps the entire transaction history tab.
- **`wallets_card_section.dart`:** `Obx(() => Column(...))` wraps the multi-card carousel and balance summary.

### Performance Consequence
When an `Obx` wrapping a `Scaffold` or `ListView` triggers:
1. Flutter traverses hundreds of widget element nodes rather than 2–3 leaf nodes.
2. Input focus, text cursor positions, and transient scroll physics animations can suffer micro-stutters.
3. Garbage collector pressure increases drastically as hundreds of short-lived widget objects are discarded per second during rapid reactive streams (e.g., live rate ticks or countdown timers).

---

## 3. `BackdropFilter` Density & GPU Compositing Cost

Glassmorphism is a signature visual identity of eCardo, implemented primarily through `EcardoGlassCard`. However, the GPU cost is severe on lower-tier hardware.

### Direct `BackdropFilter` Inventory

| # | File Path | Sigma Blur | Use Case | Bypass Logic |
| :-: | :--- | :---: | :--- | :---: |
| 1 | `lib/src/app/navigation/navigation_screen.dart` (L349) | **`sigma: 20, 20`** | Primary Bottom Navigation Bar | **NONE** (Always active) |
| 2 | `lib/src/common/widgets/design_system/ecardo_glass_card.dart` (L185) | **`sigma: 10–18`** | Reusable Card (used in 16 screens) | Only `disableAnimations` |
| 3 | `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart` (L80) | **`sigma: 7, 7`** | Frozen Card Overlay | **NONE** |
| 4 | `lib/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart` (L337) | **`sigma: 5, 5`** | Frozen Card Backdrop | **NONE** |
| 5 | `lib/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart` (L13) | Delegated | Frosted swap card token | Delegated to GlassCard |

### Fact-Checking `PERFORMANCE_PROFILE.md` vs Reality
In `docs/uiux/PERFORMANCE_PROFILE.md` Section 1.1, the documentation states:
> *"On low-end hardware or when MediaQuery.maybeOf(context)?.disableAnimations is true, blur is bypassed (sigma = 0.0), eliminating expensive multi-pass GPU compositing."*

**Actual Code Reality:**
- **Zero hardware capability detection exists.** There is no RAM check, GPU tier check, or platform capability query anywhere in `lib/`.
- `ecardo_glass_card.dart` only checks `MediaQuery.maybeOf(context)?.disableAnimations`. If a user on a $90 Android Go device does not enable "Remove animations" in accessibility settings, `EcardoGlassCard` renders full multi-stop blur.
- Most critically, `navigation_screen.dart` hardcodes `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` unconditionally. Because the navigation bar floats above the scrollable content of Home, Wallets, Transfer, and Services, **every scroll gesture forces the GPU to blur the scrolling content behind the bar at 60/120 FPS**.

### GPU Cost Mechanism
On mobile GPUs, a Gaussian blur with `sigma: 20` requires:
1. Allocating an offscreen frame buffer at the target rect size (390 x 84 logical pt @ 3x = 1170 x 252 px).
2. Copying the underlying rendered scene texture into the offscreen buffer.
3. Executing two separable 1D convolution passes (horizontal and vertical) across the fragment shader.
4. Compositing the blurred texture back into the main render pipeline.
On low-end Mali/Adreno GPUs, this single effect consumes 5–10 ms of the 16.6 ms frame budget. Combined with scrolling list builds, it produces noticeable frame drops (jank).

---

## 4. Large Monolithic Files (>2000 Lines)

Seven Dart source files exceed 2,000 lines. These files present high risk for maintenance, state leakages, and rendering overhead:

| File Path | Line Count | Classes | Primary Responsibility / Architecture Smells |
| :--- | :---: | :---: | :--- |
| `lib/src/presentation/screens/services/view/services_screen.dart` | **2,888** | 8 | Combines category hub, search filtering, animated entrance controllers, 15+ sub-service tiles, and inline dialogs into one file. |
| `lib/src/presentation/screens/settings/view/settings_screen.dart` | **2,820** | 5 | Massive `_SettingsScreenState` managing language picker, theme selector, currency picker, account delete dialogs, biometric switches, and cache clearing. |
| `lib/src/presentation/screens/travel/hotels/hotel_screens.dart` | **2,755** | 26 | Crams 26 separate classes (`HotelSearchScreen`, `HotelResultsScreen`, 6 custom cards, filters, and sheets) into a single compilation unit. |
| `lib/src/presentation/screens/travel/flights/flight_search_screen.dart` | **2,698** | 9 | Contains entire flight booking flow: airport picker sheet, passenger counter modal, cabin class selector, and date picker sheet. |
| `lib/src/presentation/screens/travel/services/cip_lounge_screen.dart` | **2,388** | 14 | CIP airport lounge booking, passenger forms, meal options, and payment triggers. |
| `lib/src/presentation/screens/travel/flights/flight_screens.dart` | **2,296** | 18 | Flight list screen, filter sheets, fare breakdown cards, and baggage policy views. |
| `lib/src/common/services/demo_account_service.dart` | **2,196** | 1 | Massive mock state generator with hundreds of hardcoded transaction records and balance dictionaries. |

### Secondary Oversized Files (>1500 lines)
- `lib/src/network/service/network_service.dart`: 1,981 lines
- `lib/src/presentation/screens/travel/insurance/insurance_screens.dart`: 1,821 lines
- `lib/src/presentation/screens/travel/trains/train_screens.dart`: 1,803 lines
- `lib/src/presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart`: 1,755 lines
- `lib/src/presentation/screens/travel/shared/seat_selection_map.dart`: 1,695 lines
- `lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart`: 1,634 lines
- `lib/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart`: 1,607 lines
- `lib/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart`: 1,576 lines

### Engineering & Performance Impact
1. **Broken Hot Reload Performance:** Dart VM dev compilers take significantly longer to re-compile 2,800+ line compilation units, slowing developer feedback loops.
2. **Testing Friction:** It is impossible to write focused golden or unit tests for individual cards (e.g. `_HotelOfferCard`) without pulling in the entire 2,755-line hotel screens bundle and its controller dependencies.
3. **Memory Retention:** Monolithic State classes hold references to dozens of transient variables, controllers, and focus nodes, increasing the risk of memory retention.

---

## 5. Unconstrained Lists & Viewport Virtualization

### 1. Eager `ListView(children: [...])` (113 Instances in 86 Files)
Instead of lazy viewport recycling via `ListView.builder`, 86 files instantiate all children immediately:
- `hotel_screens.dart` (6 instances): All hotel offer cards and amenities instantiate up front.
- `flight_screens.dart` (4 instances): All flight search cards instantiate up front.
- `notifications.dart` (4 instances): Notification cards instantiate eagerly.
- `device_sessions_security_screen.dart` (2 instances): Session cards instantiate eagerly.

### 2. `shrinkWrap: true` Anti-Pattern (21 Instances in 18 Files)
`shrinkWrap: true` forces Flutter to layout every single child in the list to determine the total scrollable height, destroying lazily recycled viewports:
- `lib/src/presentation/screens/services/view/services_screen.dart` (2 instances)
- `lib/src/presentation/screens/travel/hotels/widgets/hotel_amenities_grid.dart` (2 instances)
- `lib/src/escrow/widgets/escrow_widgets.dart` (2 instances)
- `lib/src/presentation/screens/travel/flights/flight_search_screen.dart` (1 instance)
- `lib/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart` (1 instance)
- `lib/src/loan/widgets/loan_amortization_schedule.dart` (1 instance)

### 3. Missing `itemExtent` / `prototypeItem` (0 out of 130)
- Across 130 `ListView.builder` and `ListView.separated` declarations, **0 specify `itemExtent` or `prototypeItem`**.
- Without `itemExtent`, the scroll physics engine cannot compute jump offsets or scrollbar thumb positions mathematically; it must layout each intermediate child along the way.
- **`cacheExtent` Tuning Missing:** `cacheExtent` is not specified in any list (0 instances), contradicting the 300.0 pt claim in `PERFORMANCE_PROFILE.md`.

---

## 6. Static Remediation Blueprint

### Recommendation 1: Extract Leaf `Obx` Widgets
Refactor `navigation_screen.dart` and `withdraw_screen.dart` so `Scaffold` is static:
```dart
// BEFORE (Bad):
Obx(() => Scaffold(
  body: _pages[controller.currentIndex.value],
  bottomNavigationBar: _buildBottomBar(controller.currentIndex.value),
))

// AFTER (Optimized):
Scaffold(
  body: Obx(() => _pages[controller.currentIndex.value]),
  bottomNavigationBar: Obx(() => _buildBottomBar(controller.currentIndex.value)),
)
```

### Recommendation 2: Introduce Low-End Blur Bypass Service
Create `DevicePerformanceService` to detect device memory and GPU tier:
```dart
class DevicePerformanceService extends GetxService {
  final RxBool isLowEndDevice = false.obs;

  Future<void> init() async {
    // Check available RAM or Android Go flags
    // If RAM <= 3GB, toggle low-end mode
  }
}
```
Update `navigation_screen.dart` and `ecardo_glass_card.dart` to bypass `BackdropFilter` when `isLowEndDevice.value || disableAnimations`.

### Recommendation 3: Modularize the Big Four Files
Split each file >2000 lines into dedicated sub-packages:
- `services_screen.dart` -> `services/view/widgets/`, `services/view/sheets/`, `services/model/`
- `settings_screen.dart` -> `settings/view/sheets/`, `settings/view/sections/`
- `hotel_screens.dart` -> `hotel/view/search/`, `hotel/view/results/`, `hotel/view/widgets/`
- `flight_search_screen.dart` -> `flight/view/search/`, `flight/view/sheets/`

### Recommendation 4: Enforce `itemExtent` on Uniform Lists
Add `itemExtent: 72.0` to transaction feeds and wallet lists, eliminating layout measurement passes on scroll.
