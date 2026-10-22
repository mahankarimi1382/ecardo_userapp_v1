# eCardo Flutter User App: Money Formatting & Decimal Precision Audit

**Date:** 2026-10-20  
**Audit Scope:** Currency precision, decimal handling, truncation vs rounding, and UI consistency across all money-moving screens in `ecardo_userapp_v1`.  
**Auditor:** Financial Correctness & Truth Agent  

---

## 1. Executive Summary & Core Rules

In a multi-currency fintech platform bridging fiat (IRR/IRT, USD, EUR, TRY, AED) and cryptocurrency (USDT, BTC, ETH), decimal precision is a primary line of financial defense. Displaying fractional units on zero-decimal fiat currencies (e.g., `1,500,000.00 IRT`) erodes consumer trust and confuses local banking gateways (Shetab/Shaparak). Conversely, over-truncating crypto assets or displaying excessive decimals on stablecoins (e.g., `50.00000000 USDT`) creates visual noise and causes micro-discrepancies between review and execution.

### Canonical Precision Rules
| Currency Category | ISO / App Codes | Correct Decimals | Current App Behavior | Status |
| :--- | :--- | :---: | :--- | :---: |
| **Iranian Fiat** | `IRR`, `IRT`, `TOMAN`, `TMN`, `RLS`, `RIAL` | **0** | Correct (0) via `_zeroDecimalCurrencies`, but **BROKEN** on `make_payment` & `request_money` success screens where `wallet.name` was passed instead of `wallet.code`. | ⚠️ Partial Bug |
| **Traditional Fiat** | `USD`, `EUR`, `GBP`, `AED`, `TRY`, `CAD`, `AUD`, `CHF`, `CNY`, `JPY` | **2** (JPY: 0) | Correct (2) via `_twoDecimalCurrencies`. JPY correctly in zero-decimal set. | ✅ Verified |
| **USD Stablecoins** | `USDT`, `USDC`, `DAI` | **2** (up to 6 on on-chain transfer) | **INCORRECT (8)**: Because USDT is marked `isCrypto: true`, it falls into `return isCrypto ? 8 : 2;`, rendering 8 decimal places. | ⚠️ Defect |
| **Major Crypto** | `BTC` | **8** | Correct (8) via `isCrypto: true`. | ✅ Verified |
| **EVM Crypto** | `ETH` | **6–8** | Correct (8) via `isCrypto: true`. | ✅ Verified |

---

## 2. DynamicDecimalsHelper Architecture

The helper is located at `lib/src/helper/dynamic_decimals_helper.dart`.

```dart
class DynamicDecimalsHelper {
  static const Set<String> _zeroDecimalCurrencies = {
    'IRR', 'IRT', 'TOMAN', 'TMN', 'RLS', 'RIAL',
    'JPY', 'CLP', 'KRW', 'VND', 'IDR',
  };

  static const Set<String> _twoDecimalCurrencies = {
    'USD', 'EUR', 'CNY', 'RMB', 'YUAN', 'GBP',
    'AED', 'TRY', 'CAD', 'AUD', 'CHF',
  };

  int getDynamicDecimals({
    required String currencyCode,
    required String siteCurrencyCode,
    required String? siteCurrencyDecimals,
    required bool isCrypto,
  }) {
    final upperCode = currencyCode.toUpperCase().trim();
    if (_zeroDecimalCurrencies.contains(upperCode)) {
      return 0;
    }
    if (_twoDecimalCurrencies.contains(upperCode)) {
      return 2;
    }

    final bool dynamicDecimal = currencyCode == siteCurrencyCode;

    if (dynamicDecimal) {
      return int.tryParse(siteCurrencyDecimals ?? "") ?? 2;
    } else {
      return isCrypto ? 8 : 2;
    }
  }
}
```

### Flaws in Helper Design:
1. **No Stablecoin Differentiation**: Stablecoins (USDT, USDC) are pegged to USD and economically function like 2-decimal fiat in consumer wallet displays. Tagging them `isCrypto: true` makes them default to 8 decimals.
2. **Missing Normalization**: The helper depends entirely on the caller passing an uppercase ISO code (`code`). If a caller passes `wallet.name` (e.g. "Toman Wallet", "کیف پول تومانی"), lookup fails silently and falls back to `2` decimals.

---

## 3. Systematic Screen-by-Screen Decimal Verification

### 3.1 Home Screen & Balance Hero
- **File**: `lib/src/presentation/screens/home/view/sub_sections/balance_hero_section.dart`
- **Primary Balance Display**: Formats according to `EcardoBalanceHero`. Uses `NumberFormat.currency`.
- **Secondary Equivalent Calculation (Lines 71–85)**:
  - When viewing `USD` or `USDT`: Converts to Toman via `(currentBalance * liveUsdToIrt).toInt()`. Formats with integer comma grouping (0 decimals). **Correct**.
  - When viewing `IRT` or `TOMAN`: Converts to USD via `currentBalance / liveUsdToIrt`. Formats with `usdEq.toStringAsFixed(2)`. **Correct**.
  - When viewing `IRR`: Converts to USD via `(currentBalance / 10.0) / liveUsdToIrt`. Formats with `usdEq.toStringAsFixed(2)`. **Correct**.
  - **DEFECT**: If `WalletLiveRateService` has not fetched live rates yet, `liveUsdToIrt` defaults to hardcoded `95000.0`. This shows a completely wrong secondary equivalent until rates arrive.

### 3.2 Transfer Flow
- **Files**:
  - `lib/src/presentation/screens/transfer/view/sub_sections/transfer_amount_step_section.dart:74`
  - `lib/src/presentation/screens/transfer/view/sub_sections/transfer_review_step_section.dart:44`
  - `lib/src/presentation/screens/transfer/view/sub_sections/transfer_success_step_section.dart:52`
- **Verification**:
  - `currencyCode: walletCode` (`currentWallet?.code ?? 'USD'`).
  - Correctly retrieves 0 decimals for IRT/IRR, 2 for USD/EUR.
  - Success receipt uses `DynamicDecimalsHelper().getDynamicDecimals` with `walletCode`.
  - Amount and Fee rows format identically. **Verified clean**.

### 3.3 Exchange Flow
- **Files**:
  - `lib/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart:378`
  - `lib/src/presentation/screens/exchange/view/sub_sections/exchange_review_step_section.dart:55,62`
  - `lib/src/presentation/screens/exchange/view/sub_sections/exchange_success_step_section.dart:179,185`
- **Verification**:
  - Independently computes `payDecimals` (for `fromWallet.code`) and `receiveDecimals` (for `toWallet.code`).
  - Example: Exchanging `100.00 USD` to `18,850,000 IRT` uses 2 decimals for input, 0 decimals for output.
  - Review card and Success receipt maintain separate decimal formatting for both legs.
  - **Precision Edge Case**: In `exchange_success_step_section.dart:224`, the approximate rate is computed as:
    `final rate = convertedAmount / payAmount;`
    `'1 $payCurrencyCode ≈ ${rate.toStringAsFixed(4)} $receiveCurrencyCode'`
    For crypto-to-crypto (e.g. BTC to USDT) 4 decimals is acceptable, but for IRT to USD (`1 IRT ≈ 0.0000053 USD`), `toStringAsFixed(4)` truncates to `0.0000 USD`! Rate display needs dynamic precision based on magnitude.

### 3.4 Withdraw Flow
- **Files**:
  - `lib/src/presentation/screens/withdraw/view/sub_sections/withdraw_amount_step_section.dart:521`
  - `lib/src/presentation/screens/withdraw/view/sub_sections/withdraw_review_step_section.dart:104`
  - `lib/src/presentation/screens/withdraw/view/sub_sections/withdraw_success_step_section.dart:55`
- **Verification**:
  - Evaluates decimals based on `withdrawAccount.currency` and `method.isCrypto`.
  - Net payout calculation: `(amount).toStringAsFixed(calculateDecimals)`.
  - Charge calculation: `(charge).toStringAsFixed(calculateDecimals)`.
  - Success receipt items reflect exact decimals. **Verified clean**.

### 3.5 Cash Out Flow
- **Files**:
  - `lib/src/presentation/screens/cash_out/view/sub_sections/cash_out_review_step_section.dart:105`
  - `lib/src/presentation/screens/cash_out/view/sub_sections/cash_out_success_step_section.dart:51`
- **Verification**:
  - Evaluates decimals using `wallet?.code ?? "USD"`.
  - Final payout and agent fee format cleanly with 0 decimals for Toman and 2 for USD. **Verified clean**.

### 3.6 Make Payment Flow (Merchant)
- **Files**:
  - `lib/src/presentation/screens/make_payment/view/sub_sections/make_payment_review_step_section.dart:99`
  - `lib/src/presentation/screens/make_payment/view/sub_sections/make_payment_success_step_section.dart:68`
- **CRITICAL BUG IDENTIFIED (FIN-14)**:
  - In `make_payment_review_step_section.dart:100`:
    `currencyCode: controller.wallet.value!.code!` -> Evaluates to `0` for IRT.
  - In `make_payment_success_step_section.dart:69`:
    `currencyCode: currentWallet?.name ?? 'USD'` -> Passes `"Toman Wallet"` or `"کیف پول تومان"`.
    Because `"Toman Wallet"` is NOT in `_zeroDecimalCurrencies`, it falls back to `2` decimals!
  - **User Impact**: A merchant payment of `500,000 IRT` shows as `500,000 IRT` on the review sheet, but once paid, the receipt displays `500,000.00 IRT`!

### 3.7 Request Money Flow
- **Files**:
  - `lib/src/presentation/screens/request_money/view/sub_sections/request_money_review_step_section.dart:99`
  - `lib/src/presentation/screens/request_money/view/sub_sections/request_money_success_step_section.dart:49`
- **CRITICAL BUG IDENTIFIED (FIN-15)**:
  - In `request_money_review_step_section.dart:100`:
    `currencyCode: controller.wallet.value!.code!` -> Evaluates correctly.
  - In `request_money_success_step_section.dart:50`:
    `currencyCode: currentWallet?.name ?? 'USD'` -> Passes `wallet.name` instead of `wallet.code`.
  - **User Impact**: Inverted decimal precision on request money receipts for all local currencies.

### 3.8 Bill Payment Flow
- **Files**:
  - `lib/src/presentation/screens/bill_payment/controller/electricity_controller.dart:333`
  - `lib/src/presentation/screens/bill_payment/controller/internet_controller.dart:315`
  - `lib/src/presentation/screens/bill_payment/controller/airtime_controller.dart:328`
  - `lib/src/presentation/screens/bill_payment/controller/cable_controller.dart:297`
  - `lib/src/presentation/screens/bill_payment/controller/toll_controller.dart:297`
  - `lib/src/presentation/screens/bill_payment/controller/data_bundle_controller.dart:311`
- **Verification**:
  - All bill controllers query `site_currency` (`IRT` / `USD`).
  - In `BillPaymentResultStepSection`, values are formatted upstream and displayed cleanly as label/value strings. **Verified clean**.

### 3.9 Gift Code Flow
- **Files**:
  - `lib/src/presentation/screens/gift_code/controller/create_gift_controller.dart:190`
  - `lib/src/presentation/screens/gift_code/view/sub_sections/create_gift_review_section.dart:24`
  - `lib/src/presentation/screens/gift_code/view/sub_sections/create_gift_success_step_section.dart:31`
- **Verification**:
  - Passes `currencyCode: controller.wallet.value!.code!`. Correct decimal determination.
  - **DEFECT**: Success screen contains dangerous force-unwraps:
    `DateFormat(...).format(DateTime.parse(controller.successCreateGiftData.value!["gift"]["created_at"]))`
    which crashes if `gift` or `created_at` is null.

### 3.10 Transaction Activity Summary Card
- **File**: `lib/src/presentation/screens/transactions/widgets/transaction_summary_card.dart:36-45`
- **CRITICAL FINANCIAL MATH BUG IDENTIFIED (FIN-16)**:
  ```dart
  for (final tx in transactions) {
    if (currencySymbol.isEmpty && tx.trxCurrencySymbol != null) {
      currencySymbol = tx.trxCurrencySymbol!;
    }
    final amount = tx.numericAmount;
    if (tx.isPlus == true) {
      inflowCount++;
      totalInflow += amount;
    } else {
      outflowCount++;
      totalOutflow += amount;
    }
  }
  ```
  - **Issue**: Naive direct summation of `amount` across completely different currencies!
  - If a user has a `$100 USD` deposit and a `50,000,000 IRT` withdrawal, `totalInflow` is `100` and `totalOutflow` is `50,000,000`. The summary card displays `Total Outflow: -$50,000,000` (prefixed with the dollar sign).
  - This is mathematically false and alarmingly deceptive.

---

## 4. Remediation Plan

### Fix 1: Update `DynamicDecimalsHelper` for Stablecoins
In `lib/src/helper/dynamic_decimals_helper.dart`:
```dart
  static const Set<String> _twoDecimalCurrencies = {
    'USD', 'EUR', 'CNY', 'RMB', 'YUAN', 'GBP',
    'AED', 'TRY', 'CAD', 'AUD', 'CHF',
    'USDT', 'USDC', 'DAI', 'BUSD', // Stablecoins default to 2 decimals
  };
```

### Fix 2: Repair `make_payment` and `request_money` Success Screens
Replace `currentWallet?.name` with `currentWallet?.code`:
- `lib/src/presentation/screens/make_payment/view/sub_sections/make_payment_success_step_section.dart:69`:
  ```dart
  currencyCode: currentWallet?.code ?? 'USD',
  ```
- `lib/src/presentation/screens/request_money/view/sub_sections/request_money_success_step_section.dart:50`:
  ```dart
  currencyCode: walletCode,
  ```

### Fix 3: Multi-Currency Aggregation in `TransactionSummaryCard`
In `lib/src/presentation/screens/transactions/widgets/transaction_summary_card.dart`:
Do not sum numbers of mixed currencies. Either:
1. Filter the transaction list by the currently selected wallet's currency before calculating inflow/outflow.
2. Group the totals per currency chip (e.g. `+150 USD`, `+2,500,000 IRT`).

### Fix 4: Dynamic Decimal Precision for Exchange Inverse Rates
In `lib/src/presentation/screens/exchange/view/sub_sections/exchange_success_step_section.dart`:
```dart
  String formatRate(double rate) {
    if (rate >= 1) return rate.toStringAsFixed(4);
    if (rate >= 0.001) return rate.toStringAsFixed(6);
    return rate.toStringAsFixed(8);
  }
```
