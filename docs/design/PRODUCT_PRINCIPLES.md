# eCardo — Core Product Principles & Brand Positioning (DX-004)

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa (2).md` — Sections 13, 14 & Task DX-004  
**Standard:** Apple HIG, Nielsen Norman Group, W3C WCAG 2.2 AA

---

## 1. Product Mission & Positioning

### 1.1 The Bridge Between Domestic & Global Fintech
eCardo is an international multi-currency financial and lifestyle super-app designed to seamlessly bridge domestic banking networks (Iranian Sheba, 16-digit debit cards, Toman/IRR rails) with international financial infrastructure (multi-currency virtual cards, cross-border remittance, international travel bookings, digital escrow, and P2P trading).

### 1.2 Core Product Mantra
> **«آشنا در استفاده، متمایز در شخصیت، شفاف در پول، دقیق در اجرا.»**  
> *"Familiar in use, distinctive in character, transparent in money, meticulous in execution."*

---

## 2. The Five Guiding Product Principles

### Principle 1: Familiarity Over Eccentricity (Recognize, Don't Recall)
- We do not reinvent standard financial navigation patterns for the sake of novelty.
- Inputs, numpads, transaction confirmation sheets, and card carousels follow proven mental models from global fintech leaders (Revolut, Wise, Nubank) so users feel instantly confident with their money.
- Distinction is expressed through craftsmanship, typography (Vazirmatn & Plus Jakarta Sans), micro-interactions, haptics, and harmonious visual weight.

### Principle 2: Absolute Transparency in Money (No Surprises)
- **Zero Hidden Costs:** Before any financial commitment, the user sees an exact breakdown: Gross Amount, Service Fee, Network Fee, Live Conversion Rate, and Net Received Amount.
- **Quote Staleness Awareness:** Rates carry visible time-to-live countdowns. If a quote drifts, the UI clearly discloses the update before allowing re-confirmation.
- **Server as the Single Source of Truth:** The client never estimates final balances locally or declares transaction success from redirects alone.

### Principle 3: Equal Dignity in Bilingual Layouts (RTL $\leftrightarrow$ LTR)
- Persian (RTL) is not an afterthought or automated mirror of an English design.
- Typography in Persian utilizes `Vazirmatn` with proportional line heights and clear numerals.
- Sliders, swipe-to-confirm buttons, card carousels, and progress steppers are built to flow naturally from right to left in Persian/Arabic and left to right in English/Russian/Turkish/Chinese.
- Fixed physical conventions (such as bank card EMV chips and credit card logos) maintain their physical integrity across all locales.

### Principle 4: Fail-Closed Security & Privacy by Default
- The app protects user privacy in public settings: automatic screen obscuring in the OS App Switcher (`FLAG_SECURE` on Android, snapshot blur on iOS) and balance masking.
- Biometric authentication delegates directly to hardware Keystore/Keychain tokens; plaintext user passwords are never stored, cached, or logged.
- Console and telemetry logs are strictly sanitized to redact PII, PINs, OTP codes, and card security codes.

### Principle 5: Resiliency Across Low-Bandwidth & Network Faults
- In-flight financial operations are idempotent by design. A temporary network dropout during an in-flight transfer never produces a duplicate debit.
- Timeouts transition the user into an informative "Pending Verification" state with one-tap status polling rather than showing confusing generic errors.
