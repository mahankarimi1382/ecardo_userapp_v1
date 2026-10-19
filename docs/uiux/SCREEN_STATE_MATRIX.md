# eCardo Screen State Matrix (Phase 0 Standard)

Every user-facing financial screen family in `ecardo_userapp_v1` must explicitly define, test, and render the complete state matrix. No financial screen may assume only optimistic success.

---

## State Matrix Taxonomy

| State Code | State Name | Visual & Behavioral Contract | Accessibility & Recovery |
| :--- | :--- | :--- | :--- |
| **S0** | **Initial / Idle** | Clean form or empty input containers, default asset/currency selected, action buttons in disabled/ready state. | Screen reader identifies screen title and active default account. |
| **S1** | **Loading / Skeleton** | `EcardoShimmerLoader` matching screen layout geometry. Primary CTA locked with spinner to prevent double-tap. | Announces "Loading content...", avoids flickering, respects reduced motion. |
| **S2** | **Success / Populated** | Authoritative data from authenticated backend. Badges, balance indicators, active list items displayed cleanly. | Clear semantic headings, 4.5:1 minimum contrast. |
| **S3** | **Empty State** | `EcardoEmptyState` with contextual icon, helpful title, explanatory body, and single primary CTA. | Never shows empty container or dead whitespace; CTA guides user to creation/discovery. |
| **S4** | **Error / Retry** | `EcardoErrorView` or inline alert banner. Monospace error code badge, clean non-technical explanation, "Try Again" button. | Focus shifts to error banner, announcer reads error without raw backend stack traces. |
| **S5** | **Stale / Offline** | Header warning badge or `EcardoInlineNotice` stating data timestamp. Write actions disabled or explicitly queued with warning. | Explains cached data status; financial write actions fail-closed. |
| **S6** | **Permission Denied** | Dedicated guidance sheet/screen explaining why permission (Camera for QR, Biometrics, Notifications) is required with button to App Settings. | Explains feature limitation; user can dismiss without getting stuck. |
| **S7** | **Pending / Reconciling** | Amber status badge, clock/hourglass icon, reference ID, live polling or WebSocket listener, clear notice that funds will be credited upon finality. | Crucial for on-chain crypto and interbank transfers; never render as final Success. |

---

## Detailed Matrix by Screen Family

### 1. Home / Dashboard (`BaseRoute.navigation`, `BaseRoute.root`)
- **S0 (Initial):** Cached quick actions, skeleton balance hero.
- **S1 (Loading):** Hero shimmer, recent transactions shimmer.
- **S2 (Success):** `EcardoBalanceHero` with split units, active currency, 24h PnL badge, quick action grid, recent transactions list.
- **S3 (Empty):** First-time user greeting, onboarding steps banner, "Add Money" prompt.
- **S4 (Error):** Network retry banner at top; cached balances remain visible with stale warning tag.
- **S5 (Offline):** "Offline Mode" notice; tap-to-refresh disabled; local navigation active.
- **S7 (Pending Notice):** Active banner for in-flight deposits, KYC under review, or maintenance warnings.

### 2. Wallets & Portfolio (`BaseRoute.wallets`, `BaseRoute.walletsDetails`)
- **S0 (Initial):** Default fiat/crypto wallet selected.
- **S1 (Loading):** Carousel cards shimmer, transaction history skeleton.
- **S2 (Success):** `MultiCurrencyFlipCard` with 3D flip, balance, EMV chip, account number, transaction list.
- **S3 (Empty):** "No wallets found" empty state with "Create Wallet" button.
- **S4 (Error):** Service unavailable banner; retry button; individual wallet cards show cached balances with exclamation indicator.
- **S5 (Offline):** View-only mode for cached balances.
- **S7 (Reconciliation):** Amber warning pill on wallet showing pending incoming on-chain deposit.

### 3. On-Chain Crypto Deposit (`CryptoDepositBottomSheet`)
- **S0 (Initial):** Bottom sheet opened; loading indicator active.
- **S1 (Loading):** Centered spinner with "Fetching secure deposit policy...".
- **S2 (Success):** Verified TRC-20 USDT deposit address in monospace chunked text, QR code, contract verification chip, minimum deposit notice, copy & share action buttons.
- **S3 (Empty / Not Applicable):** N/A (policy based).
- **S4 (Security Failure / Reject):** Fail-closed screen; no QR code, no address, no copy button. Clear localized explanation that server checks failed.
- **S5 (Offline):** Cannot generate address without live server authentication.
- **S6 (Gated / Disabled):** `deposits_enabled=false` displays explicit "On-chain deposits temporarily disabled pending infrastructure verification".
- **S7 (Expired Assignment):** Countdown reached zero or expired; address obscured with "Request New Address" CTA.

### 4. Transfer & Send Money (`BaseRoute.transfer`)
- **S0 (Initial):** Recipient input, amount field, available balance indicator, disabled "Review Transfer" button.
- **S1 (Loading Quote / Fee):** Fee estimation spinner in review step; recipient lookup shimmer.
- **S2 (Review / Success):** Breakdown of principal, fees, conversion, final total, recipient name, step-up PIN confirmation.
- **S4 (Error):** Insufficient balance, invalid account number, daily limit exceeded, wrong PIN.
- **S5 (Offline):** Form submission blocked; requires live network.
- **S7 (Pending / Processing):** Digital receipt with amber "Processing" badge and transaction hash; warns user not to re-submit.

### 5. Currency Exchange (`BaseRoute.exchange`)
- **S0 (Initial):** From currency and To currency selector, exchange rate banner.
- **S1 (Loading Rate):** Real-time quote retrieval spinner.
- **S2 (Quote Locked):** 60-second countdown ring (`EcardoRateCountdownTimer`), guaranteed conversion rate, fee breakdown, swipe button.
- **S4 (Quote Expired / Drift):** Countdown reaches zero; button disabled with "Rate Expired — Tap to Refresh" prompt.
- **S7 (Executing Exchange):** Screen locked with spinner; transitions directly to authoritative `EcardoDigitalReceipt`.

### 6. Virtual Cards & Security (`BaseRoute.virtualCard`, `BaseRoute.virtualCardDetails`)
- **S0 (Initial):** Card carousel loaded with card design and masked PAN.
- **S1 (Loading Details):** Sensitive details fetch (CVV, full PAN) requires biometric prompt.
- **S2 (Success):** Card controls active: Freeze switch, Online transactions switch, Spending limit slider.
- **S4 (Action Error):** Freeze action failed server check; rollback switch state immediately.
- **S6 (Provider Maintenance):** Provider card issuance disabled; displays maintenance notification.

### 7. Transaction Activity & Digital Receipt (`BaseRoute.transactions`)
- **S0 (Initial):** Filter chips (All, Transfers, Deposits, Exchanges, Bills).
- **S1 (Loading):** History list tiles shimmer.
- **S2 (Success):** Grouped transaction rows by date with type icons, directional arrows, status colors, and amounts.
- **S3 (Empty):** "No transactions found in this period" with "Reset Filters" action.
- **S4 (Paging Error):** "Failed to load more transactions" retry footer.
- **S7 (Receipt Pending):** Receipt shows perforated ticket with "In-Flight" stamp and status progress dots.

### 8. Auth, Passcode & KYC (`BaseRoute.signIn`, `BaseRoute.kycSubmitWizard`)
- **S0 (Initial):** Clean phone/email input, biometric quick-login button if enrolled.
- **S1 (Submitting):** Button loading spinner, inputs disabled.
- **S2 (Success):** Direct smooth navigation to `BaseRoute.navigation`.
- **S4 (Failed Attempts / Lockout):** Countdown lockout timer (e.g. "Too many failed attempts. Try again in 04:59"), shake animation on PIN dots.
- **S6 (KYC Pending):** KycStatus card showing "Documents under review (12-24 hours)".
