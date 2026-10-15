# eCardo — Usability Research & Target Personas (DX-003)

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa (2).md` — Sections 16, 17 & Task DX-003  
**Methodology:** Task-Based Usability Benchmark, Remote Moderated Testing & Persona Modeling

---

## 1. Target Personas

### Persona 1: Maryam (29) — Remote Freelance Designer & Content Creator
- **Location:** Tehran / Isfahan
- **Profile:** Receives payments in USDT / USD from international clients; needs to convert funds into Toman (IRT) and payout to her Iranian Sheba account to pay living expenses.
- **Pain Points:** High exchange commissions, fear of escrow fraud, cryptic blockchain addresses, unverified payment links.
- **Key eCardo Flows:**
  1. Receive funds into USDT wallet.
  2. Exchange USDT $\to$ IRT using live rate lock.
  3. Withdraw IRT to Iranian Sheba with card masking and clear fee disclosure.

### Persona 2: Reza (42) — International Business Traveler & Consultant
- **Location:** Tehran $\leftrightarrow$ Dubai $\leftrightarrow$ Istanbul
- **Profile:** Frequent flyer requiring flight tickets, hotel reservations, and CIP lounge access; needs an active virtual Mastercard to pay overseas expenses.
- **Pain Points:** Credit cards issued in Iran do not work abroad; booking international hotels with domestic debit cards is impossible; confusing conversion rates.
- **Key eCardo Flows:**
  1. Book Tehran $\to$ Dubai flight with Shamsi date picker.
  2. Issue a multi-currency virtual card funded from IRT wallet.
  3. Reserve Imam Khomeini Airport (IKA) CIP lounge pass with real-time voucher generation.

### Persona 3: Alex (34) — International Digital Nomad & Crypto Trader
- **Location:** Dubai / Bali / Global
- **Profile:** Operates across USD, EUR, and Crypto; relies on P2P trading for local fiat off-ramping.
- **Pain Points:** Overcomplicated P2P order flows; language barriers; security risks on unsecured Wi-Fi.
- **Key eCardo Flows:**
  1. English LTR interface with dark theme.
  2. P2P escrow trading with automated timer and encrypted chat.
  3. Session management and instant biometric sign-in.

---

## 2. Core Task Usability Benchmarks & Success Metrics

| Task ID | Task Description | Target Completion Rate | Target Max Time | Target Error Rate |
| :--- | :--- | :--- | :--- | :--- |
| **UT-01** | Cold-Start Onboarding & Biometric Setup | $\ge 95\%$ | $< 45$ seconds | $< 2\%$ |
| **UT-02** | Currency Swap (USD $\to$ IRT) with Rate Review | $\ge 92\%$ | $< 30$ seconds | $0\%$ financial loss |
| **UT-03** | Internal Transfer via User UID / Account | $\ge 94\%$ | $< 25$ seconds | $< 1\%$ recipient error |
| **UT-04** | Withdrawal to Iranian Sheba | $\ge 90\%$ | $< 40$ seconds | $0\%$ invalid Sheba format |
| **UT-05** | Flight Search with Shamsi / Gregorian Toggle | $\ge 93\%$ | $< 35$ seconds | $< 3\%$ date confusion |
| **UT-06** | Virtual Card Issuance & Sensitive Data Disclosure | $\ge 91\%$ | $< 50$ seconds | $0\%$ accidental leak |
| **UT-07** | P2P Order Creation & Escrow Payment Upload | $\ge 88\%$ | $< 90$ seconds | $< 2\%$ state confusion |
