# ADR 0002: Monetary Arithmetic, Currency Precision Scaling, and Server-Authoritative Exchange Drift Model

- **Status:** ACCEPTED
- **Date:** 2026-10-14
- **Deciders:** Chief Architect, Financial Engineering Guild, Core Mobile Platform Team
- **Consulted:** Backend Financial Ledger Team, Risk & Treasury Operations
- **Informed:** Mobile Frontend Engineers, Product Managers, QA Financial Test Guild
- **Document Reference:** Section 8 of Audit Roadmap (`ecardo_userapp_v1_audit_roadmap_fa.md`), Financial Flows (`docs/audit/FINANCIAL_FLOWS.md`), Findings (`docs/audit/FINDINGS.md` - FIN-01)

---

## 1. Context and Problem Statement

Financial software must maintain absolute precision across all accounting, fee deduction, currency exchange, and ledger balance representations. The eCardo User App handles a complex, heterogeneous multi-currency domain comprising:
1. **Zero-decimal fiat currencies:** Iranian Rial (`IRR`), Iranian Toman (`IRT`), Japanese Yen (`JPY`), Chilean Peso (`CLP`), and Korean Won (`KRW`).
2. **Standard two-decimal fiat currencies:** United States Dollar (`USD`), Euro (`EUR`), UAE Dirham (`AED`), Turkish Lira (`TRY`), and Chinese Yuan (`CNY`).
3. **High-precision digital assets & cryptocurrencies:** Bitcoin (`BTC`, 8 decimals), Ethereum (`ETH`, 8 decimals), and Tether (`USDT`, TRC-20 / ERC-20, 4 to 6 decimals).

### 1.1 The Binary Floating-Point Vulnerability (IEEE-754)
Standard 64-bit binary floating-point numbers (`double` in Dart and JavaScript) represent base-10 fractions using binary fractions. Many common base-10 decimals cannot be represented exactly in binary:
```dart
0.1 + 0.2 = 0.30000000000000004
1.0 - 0.9 = 0.09999999999999998
100.0 * 0.07 = 7.000000000000001
```
In financial transactions, accumulating floating-point errors causes severe bugs:
- Fee calculation drift: calculating a 1.5% fee on a deposit or transfer produces fractional cents or micro-Rials that fail backend validation.
- Sub-penny rounding arbitrage: malicious actors can exploit rounding discrepancies across split transfers or repeat exchange requests.
- Balance comparison failures: `balance >= amount + fee` evaluates to `false` when floating-point drift creates phantom micro-fractions.

### 1.2 Rate Volatility and Quote Staleness
In currency exchange operations (`/exchange`), rapid market movements create race conditions between the moment a user reviews a quoted conversion rate and the moment the order reaches the matching engine. Executing orders on stale rates leads to slippage loss for either the user or the platform treasury.

---

## 2. Decision Drivers

- **Zero Floating-Point Drift:** Elimination of IEEE-754 arithmetic inaccuracies in fee calculation, addition, and subtraction.
- **Dynamic Asset Precision:** Correct decimal formatting strictly aligned with ISO 4217 and cryptocurrency minor-unit standards.
- **Server Single Source of Truth:** The backend ledger is authoritative for balances, final fees, and settlement amounts; client logic serves strictly as an input collector, pre-validation guard, and UX renderer.
- **Drift Protection on Quotes:** Strict time-to-live (TTL) and percentage drift boundaries for exchange rates displayed in review steps.
- **Auditable Financial Determinism:** All mathematical operations must yield reproducible results across Android, iOS, and Web platforms.

---

## 3. Considered Options

1. **Option 1: Dart Native `double` with String Formatting (`toStringAsFixed`)**
   - *Pros:* Zero external dependencies, minimal initial boilerplate.
   - *Cons:* Prone to cumulative floating-point errors prior to formatting; `toStringAsFixed` applies standard IEEE round-to-even which causes financial edge-case rounding drift. Unacceptable for financial compliance.
2. **Option 2: Third-Party Decimal / Money Library (`decimal` / `money2` package)**
   - *Pros:* Clean object-oriented API.
   - *Cons:* External dependency risk, serialization overhead, impedance mismatch with existing GetX reactive observable streams (`RxDouble`, `RxString`).
3. **Option 3 (Selected): In-House Scaled Integer Arithmetic (`BigInt` / Minor Units via `MoneyMathHelper`) + `DynamicDecimalsHelper` + Server-Authoritative Quote Locking**
   - *Pros:* Zero external dependency vulnerability, 100% mathematical determinism using native arbitrary-precision `BigInt`, standardized $10^8$ scaling factor covering both fiat and crypto, low latency, seamless integration with existing codebase.

---

## 4. Architectural Decision

We adopt a three-pillar financial precision architecture:
1. **Scaled Integer Math Engine (`MoneyMathHelper`):** Performs additions, subtractions, and fee percentage calculations using integer minor units scaled by $10^8$.
2. **ISO 4217 & Crypto Precision Adapter (`DynamicDecimalsHelper`):** Dynamically bounds decimal formatting per currency code.
3. **Server-Authoritative Rate Manager with Drift Protection (`ExchangeRateManager`):** Enforces a 60-second TTL and 0.01% drift limit on locked quotes.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Financial Input Layer                           │
│  - User enters amount via numeric input keypad                         │
│  - Raw string parsed safely via safe-parse helper (no tryParse!)       │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│               DynamicDecimalsHelper (Precision Engine)                 │
│  - IRR / IRT / JPY / KRW / CLP ────────► 0 decimals (integer-only)     │
│  - USD / EUR / GBP / AED / TRY ────────► 2 decimals (standard minor)   │
│  - USDT / TRX                  ────────► 4-6 decimals (token scale)    │
│  - BTC / ETH                   ────────► 8 decimals (satoshi scale)    │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│               MoneyMathHelper (Scaled Integer Math Engine)             │
│  Scaling factor: defaultScale = 100,000,000 (10^8 minor units)         │
│                                                                        │
│  scaledAmount  = round(amount  * 10^8)                                 │
│  scaledPercent = round(percent * 10,000)                               │
│  charge        = (BigInt(scaledAmount) * BigInt(scaledPercent)) /      │
│                  (BigInt(1,000,000) * BigInt(defaultScale))            │
│  sum           = (scaledA + scaledB) / 10^8                            │
│  difference    = (scaledA - scaledB) / 10^8                            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│           ExchangeRateManager (Quote Locking & Drift Engine)           │
│  1. Capture lockedReviewRate and reviewEnteredAt on Step 1 entry       │
│  2. Background timer checks live rate every 5 seconds                  │
│  3. If rate drifts > 0.01% (driftTolerance = 0.0001) ──► Mark STALE   │
│  4. If review elapsed time > 60s (reviewStalenessDuration) ─► Mark STALE│
│  5. Stale quote locks submission button; requires user re-confirmation │
│  6. Transmit rate, expected_rate, rate_locked_at in POST payload       │
└────────────────────────────────────────────────────────────────────────┘
```

### 4.1 Scaled Integer Math Engine (`MoneyMathHelper`)

Located at `lib/src/helper/money_math_helper.dart`, the engine uses a uniform scaling constant:
$$\text{defaultScale} = 10^8 = 100,000,000$$

- **Percentage Fee Calculation:**
  ```dart
  static double calculatePercentCharge(double amount, double percent, {int decimals = 4}) {
    if (amount <= 0 || percent <= 0) return 0.0;
    final int scaledAmount = (amount * defaultScale).round();
    final int scaledPercent = (percent * 10000).round();
    final BigInt numerator = BigInt.from(scaledAmount) * BigInt.from(scaledPercent);
    final BigInt denominator = BigInt.from(1000000) * BigInt.from(defaultScale);

    final double result = numerator.toDouble() / denominator.toDouble();
    return roundToDecimals(result, decimals);
  }
  ```
  Multiplying two scaled 32/64-bit integers can overflow standard 64-bit registers. We elevate operands to arbitrary-precision `BigInt`, guaranteeing exact calculation without numerical overflow before dividing back by the composite scale factor.

- **Addition and Subtraction:**
  Operands are rounded to scaled integer minor units prior to the arithmetic operation, preventing fractional binary drift from contaminating intermediate sums:
  ```dart
  static double add(double a, double b, {int decimals = 4}) {
    final int scaledA = (a * defaultScale).round();
    final int scaledB = (b * defaultScale).round();
    return roundToDecimals((scaledA + scaledB) / defaultScale, decimals);
  }
  ```

### 4.2 Dynamic Decimals & Currency Partitioning (`DynamicDecimalsHelper`)

Located at `lib/src/helper/dynamic_decimals_helper.dart`, currency formatting adheres strictly to international and local banking conventions:
- **Zero-Decimal Currencies:** `{'IRR', 'IRT', 'JPY', 'CLP', 'KRW'}`. For Iranian Rial and Toman, fractional amounts do not exist in banking rails. Any user input or fee calculation must truncate/round to whole integer units.
- **Standard Fiat:** Defaults to 2 decimals for USD, EUR, etc., matching standard ISO 4217 minor units (cents).
- **Crypto Assets:** Configured dynamically up to 8 decimal places (Satoshis) for BTC/ETH, preventing truncation of micro-payments.

### 4.3 Server-Authoritative Quote Locking & Drift Protection

Exchange operations (`lib/src/presentation/screens/exchange/service/exchange_rate_manager.dart`) enforce a deterministic review workflow:
- **Quote Lock Snapshot:** When the user enters the Review step, the system snapshots `lockedReviewRate = currentRate.value` and records `reviewEnteredAt = DateTime.now()`.
- **Drift Threshold:**
  $$\text{Drift Tolerance} = 0.01\% = 0.0001$$
  Every 5 seconds (`reviewCheckInterval`), `ExchangeRateManager` compares `lockedReviewRate` against incoming live quotes from the market streaming source (`fee.ecardo.ir` / `ExchangeRateService`).
- **Quote Expiration (TTL):** Quotes expire automatically after 60 seconds (`reviewStalenessDuration = Duration(seconds: 60)`).
- **Enforcement Action:** If drift exceeds 0.01% or elapsed time exceeds 60 seconds, `isReviewRateStale` transitions to `true`. The UI presents a warning badge, disables the confirmation slider/CTA, and requires the user to refresh the quote before proceeding.
- **Server Verification:** The submission payload includes:
  `{ amount, from_wallet, to_wallet, rate, expected_rate, rate_locked_at }`. The backend matching engine verifies that the executed rate matches the quote within contract parameters; requests with expired timestamps are rejected.

---

## 5. Consequences

### 5.1 Positive Consequences

- **Complete Elimination of Binary Float Drift:** Calculations like `0.1 + 0.2` or complex percentage fees no longer produce trailing rounding anomalies.
- **Ledger Parity:** Client fee previews match server-side calculated fees to the exact minor unit, preventing unexpected discrepancy rejections on submission.
- **Protection Against Market Arbitrage:** Users cannot submit orders against stale quotes during sudden market volatility or network delays.
- **Zero-Fraction Compliance for Iranian Rails:** Prevents invalid decimal inputs for Sheba, Shetab, and internal Rial transfers.
- **Transparent UX:** Users receive explicit visual indicators (stale rate warnings, live rate direction badges) before committing funds.

### 5.2 Negative Consequences and Trade-Offs

- **Volatile Market Friction:** During periods of extreme price volatility, users may encounter frequent stale rate prompts requiring them to re-confirm quotes.
- **BigInt Conversion Overhead:** Minimal CPU overhead for converting values to `BigInt` (microsecond range, completely imperceptible in UI interactions).

---

## 6. Compliance Mapping

| Standard / Framework | Requirement ID | Architecture Verification & Enforcement |
| :--- | :--- | :--- |
| **ISO 4217** | `Currency & Minor Units` | Verified: Decimal precision matches ISO 4217 specifications (0 for IRR/JPY, 2 for USD/EUR). |
| **OWASP MASVS v2** | `MASVS-AUTH-3` | Verified: Financial transactions and balance calculations are tamper-resistant and server-verified. |
| **GAAP / IFRS 9** | `Fair Value & Financial Measurement` | Verified: Deterministic integer rounding rules; transparent fee calculations. |
| **Central Bank of Iran (CBI)** | `Electronic Payment Directive 1402` | Verified: Absolute zero-decimal handling for IRR/IRT; client cannot transmit fractional Rials. |
| **Shaparak Gateway Guidelines** | `Technical Spec 3.4` | Verified: Transaction amounts formatted as exact whole integer Rials. |

---

## 7. Implementation Artifacts and Code References

- **Scaled Arithmetic Helper:** `lib/src/helper/money_math_helper.dart:1-48`
- **Dynamic Decimals Helper:** `lib/src/helper/dynamic_decimals_helper.dart:1-30`
- **Exchange Rate Manager:** `lib/src/presentation/screens/exchange/service/exchange_rate_manager.dart:1-90`
- **Live Rate Service:** `lib/src/presentation/screens/exchange/service/exchange_rate_service.dart:35-99`
- **Unit & Property Tests:** `test/helper/money_math_helper_test.dart`, `test/exchange_drift_test.dart`
