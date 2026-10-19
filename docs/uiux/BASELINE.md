# eCardo UI/UX Baseline Dossier (Phase 0)

- **Date:** 2026-10-19  
- **Active Release Tag:** `v1.0.178` (`a3b6010`)  
- **Staging Version:** `1.0.180+180` (declared in `pubspec.yaml`)  
- **Architecture:** Feature-driven modular Flutter app with GetX state management  
- **Baseline Design System Specs:**  
  - Baseline resolution: 376 × 812 dp (`flutter_screenutil`)  
  - Primary tokens: `AppColors` (Primary emerald: `#00D563`, Dark background: `#0A0F1D`, Card dark: `#141C2E`, Light surface: `#FFFFFF`)  
  - Spacing & radius: `AppSpacing` (xs: 4, sm: 8, md: 12, lg: 16, xl: 24, 2xl: 32; radiusSm: 8, radiusMd: 12, radiusLg: 16, radiusXl: 24)  
  - Languages supported: 6 locales (`fa`, `en`, `ar`, `zh`, `tr`, `ru`)  
  - Total routes declared: 99 routes in `lib/src/app/routes/routes.dart`  

---

## 1. Git & Tree Status
- **Repository:** `mahankarimi1382/ecardo_userapp_v1`
- **Head Commit:** `a3b60104764b85c2763264ec47185bb81cb60d2b` (`v1.0.178`)
- **Staging Branch:** `main` (active local working tree with 36 modified files)
- **CI Status:**
  - Android Release Build: **#628 (v1.0.178)** — Success (Universal FAT APK: 59.2 MB, SHA256: `50d14ef5853309e615944d155d04aec2796a801280ae4c066cf5630d8d6ae134`)
  - Android Main Branch: **#627** — Success
  - Web Staging Build: **#238** — Success

---

## 2. Key UI/UX Invariants & Rules
1. **Preserve GetX Architecture:** No forced migration to GoRouter.
2. **Financial Truth:** UI is not the authority for wallet balances, transaction states, conversion rates, or crypto addresses. All financial operations require authenticated backend confirmations.
3. **No Fake Success:** Incomplete, pending, or failed operations must never display misleading success states.
4. **Locale Parity:** All 6 languages must render properly without clipping, with bidirectional RTL support for Persian and Arabic.
5. **Fail-Closed Security:** On-chain crypto deposit requires full server policy verification (TRC-20 USDT only, minimum confirmations, valid address checksum, non-expired assignment).
