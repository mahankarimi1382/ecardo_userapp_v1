# eCardo User App (v1) — Annex 2 Product & Design Excellence Roadmap (DX-001 to DX-020)

**Document Reference:** `ecardo_userapp_v1_audit_roadmap_fa (2).md` — Sections 13 to 22  
**Standard Compliance:** Apple HIG, W3C WCAG 2.2 AA, Nielsen Norman Group, OWASP MASVS  
**Philosophy:** *"Familiar in use, distinctive in character, transparent in money, meticulous in execution."*

---

## 1. Product Quality Targets & Global Metrics

| Metric | Target Standard | Current Baseline / Code Status | Evaluation & Action |
| :--- | :--- | :--- | :--- |
| **Critical Task Success** | $\ge 90\%$ in usability tests | Flow test coverage in `test/` passes 100% | Needs continuous human user testing in staging |
| **Financial UI Errors** | 0 critical errors / double debits | Idempotency key covers 23 endpoints | Fix key eviction on timeout bug in `NetworkService` |
| **Accessibility (WCAG)** | WCAG 2.2 AA compliance | Light theme secondary contrast is 1.92:1 (Fails) | Change `onSecondary` in `light_theme.dart` to dark (9:1) |
| **Touch Targets** | Min $48 \times 48$ dp Android / $44 \times 44$ pt iOS | Buttons use Material 3 tokens with min sizes | Verified in `CommonIconButton` and `AppSpacing` |
| **Visible Hardcoded Strings** | 0 hardcoded strings in visible UI | 2,700 keys in `app_fa.arb`; 3 isolated hardcoded strings | Prune strings in `offline_queue_banner.dart` and `splash_screen.dart` |
| **Performance Budgets** | Lean APK, $60$ fps, 0 jank | `split-per-abi` enabled; Impeller disabled fallback | Verified in `build.gradle.kts` and `AndroidManifest.xml` |
| **Network Integrity** | 0 un-reconciled timeouts | Automatic idempotency injection active | Implement pending verification state on timeout |

---

## 2. Gate-Based Design-to-Release Process (Gates A to G)

```
[Gate A: Research & Discovery]
       │
       ▼
[Gate B: Product Definition & Capabilities]
       │
       ▼
[Gate C: Visual Exploration & Prototype Testing]
       │
       ▼
[Gate D: Design System, Tokens & Golden Tests]
       │
       ▼
[Gate E: Implementation & State Integration]
       │
       ▼
[Gate F: Validation, RTL/Dark/Network Stress]
       │
       ▼
[Gate G: Controlled Beta & Privacy Telemetry]
```

---

## 3. Supplementary UX/DX Task Inventory (DX-001 to DX-020)

| ID | Task Description | Priority | Dependencies / Target Artifacts |
| :--- | :--- | :--- | :--- |
| **DX-001** | Complete screenshot inventory across all 40 modules | **P0** | Baseline screenshots before UI changes |
| **DX-002** | Competitive benchmark of global fintech apps (Revolut, Wise, Nubank) | **P1** | `docs/design/COMPETITIVE_REVIEW.md` |
| **DX-003** | Task-based usability research baseline for Iranian & global users | **P1** | `docs/design/RESEARCH.md` |
| **DX-004** | Brand positioning & core identity principles definition | **P1** | `docs/design/PRODUCT_PRINCIPLES.md` |
| **DX-005** | Two distinct visual concept prototypes (Dark Neofintech vs Ambient Glass) | **P1** | Interactive prototype tested with users |
| **DX-006** | Design tokens & semantic theme architecture | **P1** | `AppColors`, `AppSpacing`, `AppTextStyles` |
| **DX-007** | Component catalog with complete state matrix (loading/error/empty/disabled) | **P1** | Storybook / component documentation |
| **DX-008** | Content design standard & plain-language error copy guidelines | **P1** | Standardized error messages in ARB files |
| **DX-009** | User journey maps for auth, KYC, transfer, exchange, withdraw, cards | **P0** | `docs/design/JOURNEYS.md` |
| **DX-010** | Accessibility audit (TalkBack/VoiceOver, semantics, touch targets) | **P0** | Automated semantics & contrast check |
| **DX-011** | RTL/LTR visual regression testing | **P1** | Golden tests in `test/wallet_card_rtl_test.dart` |
| **DX-012** | Dark mode & dynamic type validation across all screens | **P1** | Multi-screen dark theme verification |
| **DX-013** | Subtle motion system with `prefers-reduced-motion` support | **P2** | Easing curves in `AppAnimations` |
| **DX-014** | Golden screenshot test coverage for critical financial flows | **P1** | `test/wallets_screenshot_test.dart` |
| **DX-015** | Privacy-aware telemetry schema without PII | **P1** | Zero logging of account numbers or card data |
| **DX-016** | Usability re-testing after each major milestone | **P1** | SUS / CSAT survey metrics |
| **DX-017** | Internal style consistency linter & check | **P2** | Remove ad-hoc inline styles |
| **DX-018** | Mandatory design review checklist in PR templates | **P1** | `.github/PULL_REQUEST_TEMPLATE.md` |
| **DX-019** | Asset quality & licensing audit (100% verified fonts/icons) | **P1** | Vazirmatn & Plus Jakarta Sans licenses confirmed |
| **DX-020** | Monthly UX & product quality health report | **P2** | Ongoing quality monitoring |

---

## 4. Per-Screen Design Review Checklist (15 Mandatory Criteria)

Every screen must pass this checklist before closure:
1. **Clarity:** Is the screen's core purpose immediately understood within 3 seconds?
2. **Hierarchy:** Are the primary CTA obvious and secondary actions non-intrusive?
3. **Financial Typography:** Are amount, currency ticker, fees, and destination prominent and readable?
4. **Plain Language:** Is the microcopy free of jargon, cryptic error codes, or raw English strings in Persian mode?
5. **Interactive States:** Do controls provide immediate haptic/visual feedback on pressed, focused, disabled, and loading?
6. **State Coverage:** Are dedicated UI designs active for loading (skeleton), empty, offline, server error, and session expired?
7. **Reversibility:** Can the user review and cancel prior to committing irreversible transactions?
8. **Financial Disclosure:** Are fees, exchange rates, net received amount, and quote expiry visible before confirmation?
9. **Screen Reader:** Do screen readers announce semantic labels, currency amounts, and error states accurately?
10. **Dynamic Scaling:** Does the layout remain intact with large system fonts and varied screen aspect ratios?
11. **RTL Integrity:** In RTL, do numbers, tickers, carousels, and swipe sliders render in correct order without layout bleed?
12. **Contrast & Themes:** Does the screen meet WCAG 2.2 AA contrast in both light and dark modes?
13. **Design System Tokens:** Does the screen use standardized tokens (`AppColors`, `AppSpacing`) rather than ad-hoc hex values?
14. **Asset Hygiene:** Are all icons vector/SVG, logos licensed, and placeholder assets eliminated?
15. **Automated Evidence:** Are unit tests, widget tests, or golden screenshot tests attached to the task?
