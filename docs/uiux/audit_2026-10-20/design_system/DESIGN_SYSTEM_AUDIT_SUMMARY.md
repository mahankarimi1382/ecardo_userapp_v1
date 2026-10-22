# Design System & Token Audit Summary (2026-10-20)

## State of the Design System
- Core foundation: 4 locked token files (`AppColors`, `AppSpacing`, light/dark themes) and 6 flagship widgets (`EcardoGlassCard`, `EcardoBalanceHero`, `EcardoSwipeButton`, `EcardoDigitalReceipt`, `EcardoEmptyState`, `EcardoErrorView`) covering ~4.7k LOC.
- Adoption verdict across 31 screen families: 9 ADOPTED (29%), 13 PARTIAL (42%), 5 DRIFTED (16%), 4 LEGACY (13%).
- Measured token drift: 1,844 drift occurrences in top 20 files alone; 1,369 literal `Color(0x...)` calls across screens; parallel token layers like `ExchangeDesignTokens` and local Tailwind palettes in `SettingsScreen`.

## Top 5 Drift Areas
1. **Massive Hex Drift in Monolithic Screens:** `services_screen.dart` (183 raw colors) and `settings_screen.dart` (private 30-color Tailwind palette) completely bypass `AppColors`.
2. **Travel & P2P Module Isolation:** 141 files (`travel`: 83, `p2p`: 58) with 324 raw colors and zero design system widget adoption.
3. **Crypto & Card Theming Drift:** `wallets_card_section.dart` (73 colors) and `multi_currency_flip_card.dart` (49 colors) hardcode ad-hoc gradients instead of tokenized palettes.
4. **Fragmented UI Primitives:** 12+ disjointed status badges, 5 monogram avatar painters, and 5 separate multi-step progress indicators across features.
5. **Security & PIN Input Duplication:** Inconsistent PIN dot indicators and custom soft keypads between `LockScreen`, `device_sessions_security`, and `virtual_card`.

## Concrete Phased Migration Plan
- **Phase 1 — Token Enforcement (Sprints 1–2):** Run automated codemods to replace raw `Color(0xFF...)` in top 20 screens with `AppColors`; eliminate private Tailwind palettes in `settings` and `sign_in`; deprecate `ExchangeDesignTokens` by aliasing directly to `AppColors`/`AppSpacing`.
- **Phase 2 — Core Primitive Extraction (Sprints 3–4):** Extract `EcardoStatusBadge`, `EcardoAmountInputField`, `EcardoAvatar`, and `EcardoPinInput` into `lib/src/common/widgets/design_system/`; eliminate ~3.9k lines of duplicate widget boilerplate.
- **Phase 3 — Monolith & Shell Refactoring (Sprints 5–6):** Decompose `services_screen.dart` (2.8k LOC) and `settings_screen.dart` (2.8k LOC) into tokenized sub-sections; replace raw container decorations with `EcardoGlassCard`.
- **Phase 4 — Complex Module Convergence (Sprints 7–8):** Migrate `travel` and `p2p` screens to `EcardoEmptyState`, `EcardoErrorView`, and `EcardoDigitalReceipt`; unify travel seat map and booking receipts with design system tokens.
- **Phase 5 — CI Architecture & Drift Gates (Ongoing):** Enforce `flutter analyze` linter rule (`avoid_hardcoded_colors`, custom AST rule blocking raw `Color(0x...)` under `lib/src/presentation/`); wire graphify sync to pre-commit.
