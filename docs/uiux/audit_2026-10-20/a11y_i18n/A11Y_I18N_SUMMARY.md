# Accessibility, RTL & Localization Audit: Summary

## Top 10 Issues Ranked by Severity
1. [P0] l10nPick Silent Fallback: 2,476 calls missing Turkish/Russian (81%), 1,464 missing Chinese (48%), 1,039 missing Arabic (34%).
2. [P0] Dark Theme Secondary Text Contrast: darkTextSecondary (#656262 on #262625 = 2.51:1) fails WCAG AA normal and large text.
3. [P0] Dynamic Type Overflows: 398 fixed-height containers (<=60dp) wrap text without minHeight, overflowing at 1.8x textScaler.
4. [P1] Back Arrows Unmirrored in RTL: 12 raw AppBars (remittance, commercial, etc.) point leftward into screen in Persian/Arabic.
5. [P1] Screen Reader Silence: 466 raw tap targets vs only 51 Semantics widgets (10.9% coverage); CommonButton lacks semantics.
6. [P1] Unlabeled IconButtons: 159 of 181 (87.8%) IconButtons lack tooltips/labels, announced as unlabeled by TalkBack/VoiceOver.
7. [P1] Light Theme Semantic Contrast: warning (1.91:1), mutedBlue (2.33:1), success (2.87:1) on white card fail WCAG AA.
8. [P2] Undersized Touch Targets: 211 interactive elements < 44dp (e.g. P2P close buttons 20-22dp, copy order 16dp).
9. [P2] Hardcoded TextDirection Container Wrapping: userProfileUid wraps entire row in LTR, breaking RTL screen alignment.
10. [P2] Unmirrored Asset Icons: CommonIconButton with reviewArrowBackCommonIcon points into label rather than back in RTL.

## Proposed Golden Test Matrix
Target dimensions: 10 screens x 6 locales x 2 directionalities x 3 text scales (1.0x, 1.4x, 1.8x) = 360 golden scenarios.
| Key Core Screen | Locales Tested | Directionality | Text Scaler | Golden Verification Focus |
|---|---|---|---|---|
| Home / Dashboard | fa, en, ar, tr, ru, zh | RTL & LTR | 1.0x, 1.8x | Balance hero, services grid, UID row alignment |
| Wallets & Multi-Currency | fa, en, ar, ru | RTL & LTR | 1.0x, 1.4x | Currency flip cards, transfer action button mirroring |
| Exchange & Rates | fa, en, tr, zh | RTL & LTR | 1.0x, 1.4x | Rate badge BiDi isolation (1 EUR = X), swap card |
| Remittance Wizard | fa, ar, en, ru | RTL & LTR | 1.0x, 1.8x | AppBar back arrow mirroring, stepper, payout button |
| Transfer & Slider | fa, en, ar | RTL & LTR | 1.0x, 1.4x | Swipe-to-confirm slider drag physics and chevrons |
| Cash Out Review | fa, ar, en, tr | RTL & LTR | 1.0x, 1.8x | CommonIconButton back asset direction, amount card |
| Virtual Cards Details | en, fa, zh, ru | RTL & LTR | 1.0x, 1.4x | PAN formatting, security toggle chevrons, card flip |
| Commercial Projects | fa, en, ar, zh | RTL & LTR | 1.0x, 1.8x | Back chevron direction, investment calculator sheet |
| P2P Orders & Sheet | fa, en, tr, ru | RTL & LTR | 1.0x, 1.4x | Close button hit target (min 48dp), order status |
| Device Sessions Security | fa, en, ru, tr | RTL & LTR | 1.0x, 1.8x | Session list items, terminate button, dark contrast |
