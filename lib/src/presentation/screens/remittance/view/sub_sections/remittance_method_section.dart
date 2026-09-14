// remittance_method_section.dart — Step 1: Amount + Send Currency + Payout Method + Quote.
//
// Task-12 (USER-REPORTED BUG FIX) — the previous layout rendered the
// payout-method cards FIRST and the "Send Amount" input at the BOTTOM of
// the column. On the user's device the 4+ method cards pushed the amount
// field below the fold: the user saw method selection, a gray send-currency
// box, and NO place to type — then "Get Quote" failed with "please enter a
// valid amount". The flow never advanced.
//
// NEW LAYOUT (amount-first, Western-Union style):
//   1. "You send" card  — amount input + send-currency picker INLINE,
//      always the first thing on screen (immediately visible + typeable).
//   2. Limits hint      — min/max of the active admin rate (from the
//      quote payload) when known.
//   3. Delivery method  — payout-method cards with the receive-currency
//      badge (e.g. "→ CNY").
//   4. Quote preview    — rate lock countdown, receive amount, system fee,
//      total payable (fee transparency).
//
// Nothing here changes the API contract: same endpoints, same payloads.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

/// Step 1: Enter amount + select currency + select payout method + see quote.
class RemittanceMethodSection extends StatelessWidget {
  const RemittanceMethodSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemittanceController>();
    final l = AppLocalizations.of(context)!;

    return Obx(() {
      // Empty-methods state now carries a RETRY action so a transient
      // backend failure never dead-ends the flow.
      if (controller.methods.isEmpty) {
        return _NoMethodsState(
          message: l.remittanceNoMethods,
          onRetry: () => controller.fetchMethods(),
          retryLabel: l.remittanceRetry,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. YOU SEND (amount + currency) — FIRST, always visible ──
          _YouSendCard(controller: controller, l: l),

          // ── 2. Limits hint (from the active admin rate, if known) ──
          Obx(() {
            final min = controller.minSendAmount.value;
            final max = controller.maxSendAmount.value;
            if (min == null && max == null) return const SizedBox.shrink();
            final minText = min != null ? controller.formatAmount(min) : '0';
            final maxText = (max != null && max > 0)
                ? controller.formatAmount(max)
                : '∞';
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(children: [
                Icon(Icons.rule, size: 14.sp, color: AppColors.lightTextSecondary),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    l.remittanceAmountLimitHint(minText, maxText),
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.lightTextSecondary),
                  ),
                ),
              ]),
            );
          }),

          SizedBox(height: 24.h),

          // ── 3. DELIVERY METHOD — payout-method cards ──
          Text(
            l.remittanceDeliveryMethod,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l.remittanceSelectPayoutMethod,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          ...controller.methods.map((m) => _MethodCard(
                method: m,
                isSelected: controller.selectedMethod.value?.id == m.id,
                onTap: () => controller.selectMethod(m),
                unknownLabel: l.remittanceUnknownMethod,
              )),

          SizedBox(height: 16.h),

          // ── 4. QUOTE PREVIEW (rate lock + fee transparency) ──
          Obx(() {
            final q = controller.currentQuote.value;
            if (q == null) return const SizedBox.shrink();
            return _QuotePreview(quote: q, controller: controller, l: l);
          }),
        ],
      );
    });
  }
}

/// "You send" card — the amount input and the send-currency picker live in
/// ONE row so the whole send side is a single, top-of-screen unit.
class _YouSendCard extends StatelessWidget {
  final RemittanceController controller;
  final AppLocalizations l;
  const _YouSendCard({required this.controller, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.lightPrimaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.remittanceYouSend,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Amount — Expanded so it fills the card; keyboardType number;
              // digits + one decimal point only (same formatter as before).
              Expanded(
                flex: 5,
                child: CommonTextInputField(
                  controller: controller.amountController,
                  focusNode: controller.amountFocusNode,
                  hintText: l.remittanceEnterAmount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  isBorderShow: false,
                  backgroundColor: AppColors.white,
                ),
              ),
              SizedBox(width: 10.w),
              // Send-currency picker — fixed-width so the amount keeps most
              // of the row; vertically centered with the input.
              Expanded(
                flex: 4,
                child: Obx(() => _SendCurrencyPicker(
                      controller: controller,
                      label: l.remittanceSelectSendCurrency,
                      loadingLabel: l.remittanceLoadingCurrencies,
                      emptyLabel: l.remittanceNoCurrencies,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoMethodsState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  const _NoMethodsState({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text(retryLabel, style: TextStyle(fontSize: 13.sp)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final RemittanceMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final String unknownLabel;
  const _MethodCard({required this.method, required this.isSelected, required this.onTap, required this.unknownLabel});

  @override
  Widget build(BuildContext context) {
    // Task-12 — receive-currency badge: the card now shows what currency
    // the receiver gets (e.g. "→ CNY"), so the user can tell payout
    // methods apart BEFORE requesting a quote.
    final rcCode = (method.receiveCurrencyCode ?? '').toUpperCase();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimaryContainer : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w, height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.lightPrimaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.account_balance, color: AppColors.lightPrimary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name ?? unknownLabel,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
                  if (method.countryCode != null) ...[
                    SizedBox(height: 2.h),
                    Text(method.countryCode!.toUpperCase(),
                        style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
                  ],
                ],
              ),
            ),
            if (rcCode.isNotEmpty) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('→ $rcCode',
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextSecondary)),
              ),
            ],
            SizedBox(width: 8.w),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.lightPrimary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

/// Dropdown picker for the SEND currency.
///
/// Renders one of three states based on the controller's Rx state:
///   - Loading: a disabled DropdownButton with a "Loading…" hint.
///   - Empty:    a disabled DropdownButton with an "No currencies" hint.
///   - Ready:    a DropdownButton bound to `selectedSendCurrencyId`.
class _SendCurrencyPicker extends StatelessWidget {
  const _SendCurrencyPicker({
    required this.controller,
    required this.label,
    required this.loadingLabel,
    required this.emptyLabel,
  });

  final RemittanceController controller;
  final String label;
  final String loadingLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (controller.isCurrenciesLoading.value) {
      return _pickerContainer(
        child: Row(children: [
          SizedBox(width: 14.w, height: 14.w, child: const CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(loadingLabel, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );
    }

    if (controller.sendCurrencies.isEmpty) {
      return _pickerContainer(
        child: Text(emptyLabel, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
      );
    }

    // Find the currently selected currency object (or null if none).
    final selectedId = controller.selectedSendCurrencyId.value;
    CurrenciesData? selected;
    if (selectedId != 0) {
      try {
        selected = controller.sendCurrencies.firstWhere((c) => c.id == selectedId);
      } catch (_) {
        selected = null;
      }
    }

    return _pickerContainer(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CurrenciesData>(
          value: selected,
          isExpanded: true,
          hint: Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
          items: controller.sendCurrencies.map((c) {
            final code = (c.code ?? '').toUpperCase();
            final name = c.name ?? '';
            final display = name.isEmpty ? code : '$code — $name';
            return DropdownMenuItem<CurrenciesData>(
              value: c,
              child: Text(display,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary),
                  overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) controller.selectSendCurrency(value);
          },
        ),
      ),
    );
  }

  Widget _pickerContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder, width: 1),
      ),
      child: child,
    );
  }
}

class _QuotePreview extends StatelessWidget {
  final RemittanceQuote quote;
  final RemittanceController controller;
  final AppLocalizations l;
  const _QuotePreview({required this.quote, required this.controller, required this.l});

  @override
  Widget build(BuildContext context) {
    // Task-12 — rate-source badge: 'admin' = operator-guaranteed rate,
    // 'auto' = market rate + margin. Additive quote field; unknown values
    // hide the badge.
    final source = quote.rateSource;
    final sourceLabel = source == 'admin'
        ? l.remittanceRateSourceAdmin
        : source == 'auto'
            ? l.remittanceRateSourceAuto
            : null;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.lightPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.lock_clock, color: AppColors.lightPrimary, size: 16.sp),
            SizedBox(width: 6.w),
            Obx(() => Text(l.remittanceRateLocked(controller.rateExpiresInSeconds.value),
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightPrimary, fontWeight: FontWeight.w600))),
            const Spacer(),
            if (sourceLabel != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.3)),
                ),
                child: Text(sourceLabel,
                    style: TextStyle(fontSize: 10.sp, color: AppColors.lightPrimary, fontWeight: FontWeight.w600)),
              ),
          ]),
          SizedBox(height: 12.h),
          _Row(l.remittanceReceiverGets, controller.formatAmount(quote.receiveAmount, currencyId: quote.receiveCurrencyId), bold: true),
          SizedBox(height: 6.h),
          _Row(l.remittanceExchangeRate, '1 = ${quote.exchangeRate.toStringAsFixed(4)}'), // TODO(lead): exchange-rate precision is not exposed by the quote API — 4 kept as-is.
          SizedBox(height: 6.h),
          // M-7 — decimals now come from DynamicDecimalsHelper via the
          // controller (API-driven); falls back to 2 like before.
          _Row(l.remittanceSystemFee, controller.formatAmount(quote.systemFee, currencyId: quote.sendCurrencyId)),
          SizedBox(height: 8.h),
          Divider(color: AppColors.lightBorder, height: 1),
          SizedBox(height: 8.h),
          _Row(l.remittanceTotalPayable, controller.formatAmount(quote.totalPayable, currencyId: quote.sendCurrencyId), bold: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppColors.lightTextSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: 13.sp, color: AppColors.lightTextPrimary, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}
