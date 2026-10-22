# eCardo Flutter User App: Double-Submit, Idempotency & Pending States Audit

**Date:** 2026-10-20  
**Audit Scope:** Double-submission guards, HTTP idempotency headers, network timeout handling, and transaction lifecycle states across all financial controllers in `ecardo_userapp_v1`.  
**Auditor:** Financial Correctness & Truth Agent  

---

## 1. Executive Summary

In fintech client engineering, moving funds over unreliable mobile networks (3G/4G/public Wi-Fi in Iran, Turkey, and UAE) requires strict coordination between UI button state, client-side idempotency tracking, and backend transactional integrity:

1. **In-Flight UI Guarding (`isLoading`)**: Prevents rapid multi-taps on submit buttons from initiating duplicate concurrent HTTP requests before the client receives a server response.
2. **Network Idempotency (`Idempotency-Key` / `X-Idempotency-Key`)**: Ensures that if a TCP connection drops or times out after the backend has committed ledger debits, a client retry carrying the same key is deduplicated rather than executed as a second transaction.
3. **Ambiguous Timeout Recovery**: When an HTTP request times out in the read/receive phase, the client *cannot know* whether the server executed the transaction. The app must warn the user to inspect transaction history rather than presenting a generic failure toast that prompts blind retries.
4. **Pending vs Completed Truth**: Asynchronous transactions (such as bank payouts, manual deposits, or gateway approvals) must render in a visible `Pending` state. Presenting an unconfirmed or user-aborted transaction with green celebratory confetti and a "PAID" receipt stamp is a critical financial falsehood.

---

## 2. Comprehensive Financial Controller Audit Matrix

| Module & Controller | Action Method | API Endpoint | `isLoading` Double-Submit Guard? | Idempotency Header? | Timeout Recovery Warning? | Pending vs Success Handling | Verdict |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Transfer**<br>`TransferController` | `transferAmount` | `/user/transfer` | ✅ Yes<br>`isTransferAmountLoading.isTrue` | ✅ Yes<br>`/user/transfer` in list | ✅ Yes<br>`NetworkErrorHelper.isTimeout` caught with warning toast | ✅ Instant transfer; evaluates `Status.completed` | **PASSED** |
| **Exchange**<br>`ExchangeController` | `exchangeWallet` | `/user/exchange` | ✅ Yes<br>`isExchangeWalletLoading.isTrue` | ✅ Yes<br>`/user/exchange` in list | ✅ Yes<br>`NetworkErrorHelper.isTimeout` caught with warning toast | ✅ Instant exchange; rates locked on review | **PASSED** |
| **Cash Out**<br>`CashOutController` | `cashOut` | `/user/cashout` | ✅ Yes<br>`isCashOutLoading.isTrue` | ✅ Yes<br>`/user/cashout` in list | ✅ Yes<br>`NetworkErrorHelper.isTimeout` caught with warning toast | ✅ Agent payout receipt renders confirmed | **PASSED** |
| **Withdraw**<br>`WithdrawController` | `submitWithdraw` | `/user/withdraw` | ✅ Yes<br>`isWithdrawLoading.isTrue` | ✅ Yes<br>`/user/withdraw` in list | ❌ **NO**<br>Generic error toast | ❌ **CRITICAL BUG (FIN-07)**<br>Backend sets `Pending`; Receipt stamps "PAID" | ⚠️ **FAIL** |
| **Make Payment**<br>`MakePaymentController` | `makePayment` | `/user/payment/make` | ✅ Yes<br>`isMakePaymentLoading.isTrue` | ❌ **CRITICAL BUG (FIN-09)**<br>Missing from idempotent list! | ❌ **NO**<br>Generic error toast | ✅ Evaluates `Status.completed` | ⚠️ **FAIL** |
| **Add Money (Auto)**<br>`AddMoneyController` | `submitAddMoneyAuto` | `/user/add-money` | ✅ Yes<br>`isPaymentLoading.isTrue` | ✅ Yes<br>`/user/add-money` in list | ❌ **NO**<br>Generic error toast | ❌ **CRITICAL BUG (FIN-05)**<br>User abort/backout routed to Success + PAID receipt | 🚨 **P0 FAIL** |
| **Add Money (Manual)**<br>`AddMoneyController` | `submitAddMoneyManual` | `/user/add-money` | ✅ Yes<br>`isPaymentLoading.isTrue` | ✅ Yes<br>Handled by `postMultipart` | ❌ **NO**<br>Generic error toast | ✅ Routes to `AddMoneyPendingStepSection` | **PASSED** |
| **Request Money**<br>`RequestMoneyController` | `requestMoney` | `/user/request-money` | ✅ Yes<br>`isRequestMoneyLoading.isTrue` | ❌ **NO**<br>Missing from idempotent list | ❌ **NO**<br>Generic error toast | ✅ Records pending request | ⚠️ **WARN** |
| **Accept Request**<br>`ReceivedRequestController` | `submitRequestAction` | `/user/request-money/$id/action` | ✅ Yes<br>`isSubmittingAction.value` | ❌ **CRITICAL BUG (FIN-13)**<br>URL ends in `/action`, missing idempotency! | ❌ **NO**<br>Generic error toast | ✅ Refresh list on completion | ⚠️ **FAIL** |
| **Bill Payment**<br>6 Controllers | `submitPayBill` | `/user/pay-bill` | ✅ Yes<br>`isSubmitLoading.isTrue` | ✅ Yes<br>`/user/pay-bill` in list | ❌ **NO**<br>Generic error toast | ✅ Evaluates status from backend | **PASSED** |
| **Gift Creation**<br>`CreateGiftController` | `createGift` | `/user/gifts` | ✅ Yes<br>`isCreateGiftLoading.isTrue` | ✅ Yes<br>`/user/gifts` in list | ❌ **NO**<br>Generic error toast | ⚠️ Force unwrap crash risk (FIN-17) | ⚠️ **WARN** |
| **Gift Redeem**<br>`GiftRedeemController` | `giftCodeRedeem` | `/user/gifts/redeem` | ❌ **CRITICAL BUG (FIN-12)**<br>No guard! | ❌ **NO**<br>`/user/gifts/redeem` not matched | ❌ **NO**<br>Generic error toast | ✅ Single call success | ⚠️ **FAIL** |

---

## 3. Deep-Dive on Critical Deficiencies

### 3.1 P0 Defect: Canceled Payment Gateway Treated as Successful Deposit
- **Locations**:
  - `lib/src/presentation/screens/add_money/controller/add_money_controller.dart:270–277`
  - `lib/src/presentation/screens/add_money/view/add_money_screen.dart:163–166`
- **Mechanism**:
  ```dart
  final paymentResult = await Get.to<Map<String, dynamic>>(
    () => WebViewScreen(paymentUrl: redirectUrl),
    fullscreenDialog: false,
  );
  if (paymentResult != null && paymentResult['success'] == true) {
    successPaymentData.value = paymentResult['data'];
    currentStep.value = 2;
    AppEventBus.emit(BalanceChangedEvent(sourceModule: 'add_money'));
  } else if (paymentResult == null) {
    // The user backed out of the gateway page. The deposit is still
    // open server-side, so say so instead of silently resetting.
    pendingPaymentData.value = payload;
    currentStep.value = 2;
    AppEventBus.emit(BalanceChangedEvent(sourceModule: 'add_money'));
    ToastHelper().showSuccessToast(localization!.addMoneySuccess);
  }
  ```
  When `currentStep.value` is set to `2`, `add_money_screen.dart` evaluates:
  ```dart
  controller.currentStep.value == 2
      ? controller.gatewayMethod.value!.type == "auto"
          ? const AddMoneySuccessStepSection()
          : const AddMoneyPendingStepSection()
      : const SizedBox.shrink();
  ```
- **Consequence**:
  Because online gateways are `type == "auto"`, backing out of the WebView immediately navigates to `AddMoneySuccessStepSection`!
  The user is greeted with a confetti celebration, a green banner saying "Deposit completed successfully", and a digital receipt stamped "PAID". In reality, zero money was transferred.
- **Fix Required**:
  When `paymentResult == null`, the flow must navigate to `AddMoneyPendingStepSection` or return to the review step with an advisory notice that the payment was not completed. It must NEVER navigate to `AddMoneySuccessStepSection` or toast success.

---

### 3.2 P0 Defect: Bank Payouts Stamped "PAID" on Submission
- **Location**:
  `lib/src/presentation/screens/withdraw/view/sub_sections/withdraw_success_step_section.dart:155`
- **Mechanism**:
  The widget invokes `EcardoDigitalReceipt`:
  ```dart
  EcardoDigitalReceipt(
    title: l10nPick(context, en: 'Withdrawal Payout Receipt', ...),
    transactionReference: tnxId,
    primaryAmount: amount,
    primaryCurrency: currency,
    status: EcardoReceiptStatus.success, // <--- Hardcoded success!
    ...
  );
  ```
  In `EcardoDigitalReceipt`:
  ```dart
  final stampText = widget.watermarkText ??
      switch (widget.status) {
        EcardoReceiptStatus.success => 'PAID',
        EcardoReceiptStatus.pending => 'PENDING',
        EcardoReceiptStatus.failed => 'VOID',
      };
  ```
- **Backend Reality**:
  Backend `WithdrawController.php:133` records the transaction as:
  `'status' => TxnStatus::Pending`
  and posts to ledger account `liability:pending_withdraw:{currency}`. It awaits banking cycle execution (Paya/Satna in Iran, SEPA in Europe).
- **Consequence**:
  The digital receipt issued to the user explicitly stamps "PAID" and displays a green "Success" badge with share text `Status: Confirmed`. If the payout is later canceled, rejected for compliance, or fails at the clearing house, the user has a contradictory receipt claiming payout completion.
- **Fix Required**:
  Set `status: EcardoReceiptStatus.pending` in `WithdrawSuccessStepSection`. The receipt will render the AMBER `PENDING` watermark stamp and an "In Processing" status pill.

---

### 3.3 P0 Defect: Merchant Payment (`/user/payment/make`) Lacks Idempotency Protection
- **Location**:
  `lib/src/network/service/network_service.dart:54–90`
- **Mechanism**:
  `NetworkService` intercepts POST requests and attaches `Idempotency-Key` and `X-Idempotency-Key` only if `options.uri.path` ends with one of the entries in `_idempotentEndpointSuffixes`.
  The list contains `/user/pay-bill`, `/user/transfer`, `/user/cashout`, `/user/gifts`, `/user/withdraw`, `/user/exchange`, etc., but **omits** `/user/payment/make`.
- **Consequence**:
  When a user pays a merchant via QR code or Merchant ID in a poor network area (e.g. at a physical store counter), if the cellular connection experiences a transport timeout, retrying or re-tapping sends a new POST without an idempotency header. The backend S-023 middleware passes it through, double-debiting the user's wallet.
- **Fix Required**:
  Add `'/user/payment/make'` to `_idempotentEndpointSuffixes` in `NetworkService`.

---

### 3.4 P1 Defect: Gift Code Redeem Lacks Double-Submit Guard
- **Location**:
  `lib/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart:37–40`
- **Mechanism**:
  ```dart
  Future<void> giftCodeRedeem() async {
    isGiftRedeemLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "code": giftCodeController.text,
      };
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.giftRedeemEndpoint,
        data: requestBody,
      );
  ```
  Notice the absence of:
  `if (isGiftRedeemLoading.isTrue) return;`
- **Consequence**:
  Rapid double-tapping the "Redeem Gift Code" button dispatches two HTTP POST requests to `/user/gifts/redeem`. Because `/user/gifts/redeem` does not end with `/user/gifts`, it also lacks idempotency headers. This can trigger concurrent redeem attempts and confusing error toasts ("Code already redeemed").
- **Fix Required**:
  Add `if (isGiftRedeemLoading.isTrue) return;` at entry, and add `'/user/gifts/redeem'` to `_idempotentEndpointSuffixes`.

---

### 3.5 P1 Defect: Accepting Money Request Lacks Idempotency
- **Location**:
  `lib/src/presentation/screens/request_money/controller/received_request_controller.dart:98–105`
- **Mechanism**:
  ```dart
  final response = await Get.find<NetworkService>().post(
    endpoint: "${ApiPath.requestMoneyEndpoint}/$requestId/action?action=$action",
  );
  ```
  The resulting URL path is `/user/request-money/123/action`.
  The idempotency matcher checks `path.endsWith(suffix)`. No suffix matches `/action`.
- **Consequence**:
  Accepting a request debits the user's wallet and credits the requester. A network drop during confirmation can result in duplicate debits upon retry.
- **Fix Required**:
  Add `'/action'` to `_idempotentEndpointSuffixes`, or attach an explicit `X-Operation-ID` header in `submitRequestAction`.

---

### 3.6 P2 Defect: Inconsistent Network Timeout Recovery
- **Pattern Comparison**:
  - **Exemplary Implementations** (`TransferController:477`, `ExchangeController:743`, `CashOutController:387`):
    ```dart
    final isTimeout = NetworkErrorHelper.isTimeout(e) ||
        errStr.contains('timed out') ||
        (e is DioException && (e.type == DioExceptionType.connectionTimeout || ...));
    if (isTimeout) {
      ToastHelper().showWarningToast(
        l10nPickAuto(
          en: 'Request timed out on response. Please verify in Transaction History before trying again to prevent duplicate transaction.',
          ...
        ),
      );
    }
    ```
  - **Deficient Implementations** (`WithdrawController:392`, `MakePaymentController:245`, `AirtimeController:216`, `CreateGiftController:348`):
    ```dart
    } catch (e, stackTrace) {
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    }
    ```
- **Consequence**:
  On withdrawal or merchant payment timeout, the user is shown a red "Something went wrong" toast. Believing the transaction failed completely, users immediately tap the action button again.
- **Fix Required**:
  Standardize all financial controller catch blocks to run through `NetworkErrorHelper.isTimeout(e)` and show a cautionary warning toast.

---

## 4. Remediation Checklist

1. [ ] **Add Missing Endpoints to `NetworkService._idempotentEndpointSuffixes`**:
   - `'/user/payment/make'`
   - `'/user/gifts/redeem'`
   - `'/user/request-money'`
   - `'/action'`
2. [ ] **Correct Add Money Controller Routing on Aborted WebView**:
   - Route `paymentResult == null` to `AddMoneyPendingStepSection` or stay on step 1 with a toast: *"Deposit pending gateway confirmation"*.
3. [ ] **Align Withdrawal Receipt Status with Ledger**:
   - Change `WithdrawSuccessStepSection` to use `EcardoReceiptStatus.pending`.
4. [ ] **Add Double-Submit Guard to `GiftRedeemController`**:
   - Insert `if (isGiftRedeemLoading.isTrue) return;`.
5. [ ] **Standardize Timeout Handling Across All Financial Controllers**:
   - Port the `NetworkErrorHelper.isTimeout` warning toast block into `WithdrawController` and `MakePaymentController`.
