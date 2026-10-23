# eCardo User App — Comprehensive Business Flows

This document provides end-to-end verification traces for all mission-critical financial and operational flows in eCardo.

## 1. Authentication, Onboarding & Security Flow
- **Flow ID:** `FLOW-AUTH-01`
- **Primary Journey:** User Launch -> Splash -> Token Evaluation -> Intro / Login -> Mobile Input -> SMS OTP Verification -> 4-Dot PIN Setup / Biometric Prompt -> Navigation Dashboard.
- **Critical Checks:**
  - OTP Resend countdown timer integrity.
  - Auto-fill and secure storage of session refresh tokens in Keychain/EncryptedSharedPreferences.
  - Biometric authentication fallback to PIN.

## 2. Multi-Currency Wallet & Balance Management Flow
- **Flow ID:** `FLOW-WALLET-01`
- **Primary Journey:** Home -> Wallets Tab -> Wallet Details -> Ledger Statement -> Deposit / Withdrawal.
- **Critical Checks:**
  - Strict Zero-Decimal Toman formatting for IRR wallets; exact decimal accuracy for USD/EUR/AED/USDT.
  - Immediate pull-to-refresh and optimistic UI balance consistency.
  - Empty ledger handling with helpful CTA.

## 3. Card Management & Instant Security Flow
- **Flow ID:** `FLOW-CARD-01`
- **Primary Journey:** Home -> Cards Tab -> Select Card -> Reveal CVV2/Expiry -> Instant Card Freeze / Unfreeze -> PIN Management -> Limits Adjustment.
- **Critical Checks:**
  - Masked PAN numbers (e.g. 6037-****-****-1234) until biometric unlock.
  - Atomic toggle for Freeze/Unfreeze with immediate visual feedback.
  - Idempotent API calls to avoid duplicate card orders or duplicate PIN updates.

## 4. Transfers, Remittance & P2P Settlement Flow
- **Flow ID:** `FLOW-TX-01`
- **Primary Journey:** Transfers Tab -> Select Channel (Wallet-to-Wallet / Card-to-Card / Paya / Satna) -> Recipient Input -> Dynamic Fee Calculation -> Confirmation Modal -> Biometric / PIN Authorization -> Immutable Receipt.
- **Critical Checks:**
  - Recipient name inquiry verification prior to submission.
  - Fee breakdown displayed prominently before the user confirms.
  - Double-tap prevention (button debounce & idempotency key dispatch).

## 5. Live Currency & Crypto Exchange Flow
- **Flow ID:** `FLOW-FX-01`
- **Primary Journey:** Home / Services -> Currency Exchange -> Select Source & Destination Currencies -> Real-time Rate Fetch -> Quote Timer (15s lock) -> Execute Swap -> Confirmation & Wallet Update.
- **Critical Checks:**
  - Rate expiry countdown and automatic re-quote dialog.
  - Slippage limit protection and spread transparency.

## 6. Travel & Lifestyle Booking Flow (eTrip)
- **Flow ID:** `FLOW-TRAVEL-01`
- **Primary Journey:** Travel Hub -> Service Selection (Flights / Hotels / eSIM / Boats / Dining) -> Parameter Search -> Results List -> Passenger / Guest Details -> Multi-passenger Math & Tax -> Checkout -> Digital Voucher / Boarding Pass.
- **Critical Checks:**
  - Passenger passport expiry validation (min 6 months).
  - Harmonized Toman pricing across domestic/international services.
  - Offline voucher caching for active bookings.

## 7. Customer Support, KYC & Account Compliance Flow
- **Flow ID:** `FLOW-COMPLIANCE-01`
- **Primary Journey:** Settings -> Identity Verification (KYC) -> Document Upload -> Status Tracking -> Support Tickets -> Live Chat.
- **Critical Checks:**
  - Client-side image compression before document upload.
  - Real-time ticket reply push notifications.
