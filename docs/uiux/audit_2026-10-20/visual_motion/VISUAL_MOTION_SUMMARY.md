# Visual, Motion & Performance Audit Summary (2026-10-20)

## Coverage Stats
- **Total Routes**: 137 routes (40 P0, 82 P1, 15 P2)
- **Golden Captures**: 37 PNGs tracked; only 25 active in 5 test files (12 orphan PNGs)
- **Active Coverage**: 6 of 137 routes (4.4% overall; 5 of 40 P0s = 12.5%)
- **Stale Test Artifacts**: 117 untracked failure diff PNGs (7.3 MB) in test/failures/
- **Animations & Disposals**: 30 AnimationController files (100% disposed); 9 TabControllers
- **Reduce-Motion**: 1 of 30 files compliant (3.3%); 94 implicit animation files non-compliant

## Top 5 Motion & Performance Risks
1. **Permanent BackdropFilter (sigma: 20)** in navigation_screen.dart blurs scrolling content continuously with zero device-tier or reduce-motion bypass.
2. **15 Perpetual Infinite Tickers** (e.g. ecardo_swipe_button shimmer, live_rate_badge, pulsing indicators) drain battery and GPU cycles off-screen.
3. **Coarse-Grained Obx on Scaffolds & Lists** (6 screens wrap full Scaffold; flight/travel/rental wrap entire ListViews), triggering massive unnecessary rebuilds.
4. **Test-Bypass Anti-Pattern**: 3 files inspect WidgetsBinding runtimeType string to dodge test timeouts instead of honoring MediaQuery.disableAnimations.
5. **7 Monolithic Files >2000 Lines** (led by services_screen: 2,888 lines, settings_screen: 2,820 lines) coupled with 0 of 130 lists using itemExtent.

## Top 5 Priority Golden Captures to Add Next
1. **PAGE-066: VirtualCardScreen** — verify card flip, freeze blur overlay, CVV toggle (light/dark/fa RTL/ru Cyrillic).
2. **PAGE-016 & PAGE-017: AddMoney & MakePayment** — deposit and merchant payment flows (amount, gateway, review steps).
3. **PAGE-007 & PAGE-008: Email Registration & OTP Verification** — critical P0 onboarding funnel with input error states.
4. **PAGE-024: TransactionsScreen** — high-density transaction cluster list, date group headers, and empty/filter states.
5. **PAGE-075 & PAGE-080: P2P Trading & Remittance** — escrow order book, currency country payout pickers, and dynamic type (1.3x/2.0x).
