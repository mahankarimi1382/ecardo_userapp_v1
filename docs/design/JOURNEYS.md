# eCardo — Critical User Journey Maps & Flow Specifications (DX-009)

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa (2).md` — Section 16 & Task DX-009  
**Standard:** Task-Based Interaction Design & State Machine Alignment

---

## 1. Journey 1: Sign-In, 2FA & Biometric Onboarding

```
[Cold App Launch]
       │
       ▼
[Token Check in FlutterSecureStorage]
       ├── Present & Valid ──► [Prompt Biometric Unlock] ──Success──► [Home Dashboard]
       │                                     │
       │                                   Fail / Cancel
       │                                     │
       └── Absent / Expired ───────────────► ▼
                              [Sign-In Screen (Email & Password)]
                                     │
                                Submit (Post ApiPath.loginEndpoint)
                                     │
                         ┌───────────┴───────────┐
                         ▼                       ▼
                   [2FA Required]          [Standard Login]
                         │                       │
                  Enter 6-Digit OTP        Set State & FCM Token
                         │                       │
                         └───────────┬───────────┘
                                     ▼
                            [Prompt Enable Biometrics]
                                     │
                                     ▼
                              [Home Dashboard]
```

- **Trigger:** User opens app.
- **Prerequisites:** Hardware biometrics available (Fingerprint / FaceID).
- **Error States:** Invalid credentials (inline field error), rate-limited OTP (countdown timer), network timeout (friendly retry).
- **Security Invariants:** Plaintext passwords are never retained in persistent storage; bearer token lives exclusively in hardware Keystore/Keychain.

---

## 2. Journey 2: Currency Exchange (USD $\leftrightarrow$ IRT)

```
[Exchange Tab / Quick Action]
       │
       ▼
[Step 1: Pair & Amount Input]
       ├── Select From Wallet & To Wallet
       ├── Input Amount (Debounced 250ms)
       ├── Live Preview calculated via liveToAmount
       └── Validation: Min/Max limits, balance check, zero-minor-unit rounding
       │
       ▼ (Tap Continue)
[Step 2: Review & Quote Lock]
       ├── ExchangeRateManager locks rate (60s timer)
       ├── Displays Source Amount, Net Destination, and Platform Fee
       ├── Real-time drift detector ($> 0.01\%$ drift triggers Stale Banner)
       │
       ▼ (Swipe to Confirm / EcardoSwipeButton)
[Submission: POST /user/exchange with Idempotency-Key]
       │
       ├── Success ──► [Step 3: Confetti Receipt & Updated Balance Event]
       └── Timeout ──► [Pending Verification Toast + Status Query]
```

- **Trigger:** User wants to convert international earnings to domestic currency.
- **Fail-Safe:** Rate drift $> 0.01\%$ or expiration $> 60$s automatically disables confirmation slider until refreshed.

---

## 3. Journey 3: Withdrawal to Iranian Sheba

```
[Withdraw Screen]
       │
       ▼
[Step 1: Destination & Amount]
       ├── Select Source Wallet (e.g. IRT Wallet)
       ├── Select Destination Type (Iranian Sheba)
       ├── Input Sheba: Strict validation (IR + 24 digits, total 26 chars)
       ├── Input Amount: Enforce min/max daily limits
       └── Review Fee: MoneyMathHelper computes percentage + fixed fee
       │
       ▼ (Tap Continue)
[Step 2: Review Details & Security PIN]
       ├── Masked Sheba Display: "IR82 •••• •••• •••• 9012"
       ├── Bottom Sheet: VerifyPasscodeBottomSheet (4-digit transaction PIN)
       │
       ▼ (Swipe to Confirm)
[Submission: POST /user/withdraw with Idempotency-Key]
       │
       ├── Success ──► [Receipt Ticket with Masked Account Numbers]
       └── Timeout ──► [Retain Idempotency-Key & Show Pending Check Banner]
```

- **Trigger:** User requests bank payout.
- **Privacy:** Receipts generated for sharing mask all Sheba and account numbers by default.
