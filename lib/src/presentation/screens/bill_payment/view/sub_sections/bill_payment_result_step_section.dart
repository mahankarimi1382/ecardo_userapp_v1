// PAYMENT-FIX (P-2) — shared "bill payment result" step.
//
// All six bill payment services (airtime, electricity, internet,
// data_bundle, cable, toll) used to end a submission with only a toast and
// a silent form reset, so a backend "pending" payment looked exactly like a
// successful one. This widget renders the backend-driven result state after
// a completed pay-bill call:
//   * headline: the backend `message` (pass-through, hidden when absent),
//   * status row: the server status pass-through (`data['status']`) when
//     the backend provides one,
//   * amount / charge / payable rows from the values the user confirmed,
//   * a link into Bill Payment History where the authoritative server-side
//     status lives.
//
// TODO(lead): the exact success payload of `POST /user/pay-bill` is not
// contractual in the client (no response model exists). Message/status are
// therefore rendered as null-safe pass-throughs; once the backend confirms
// the payload shape (e.g. `data.status` / `data.tnx`), consider a typed
// model and a dedicated pending/success visual per status.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';

class BillPaymentResultStepSection extends StatelessWidget {
  const BillPaymentResultStepSection({
    super.key,
    required this.result,
    required this.amountLabel,
    required this.amountValue,
    required this.chargeLabel,
    required this.chargeValue,
    required this.payableLabel,
    required this.payableValue,
    required this.statusLabel,
    required this.historyButtonLabel,
    required this.closeButtonLabel,
    required this.onClose,
  });

  /// Raw backend response body of the last successful pay-bill call
  /// (pass-through only — no client model is imposed on it).
  final Map<String, dynamic>? result;

  final String amountLabel;
  final String amountValue;
  final String chargeLabel;
  final String chargeValue;
  final String payableLabel;
  final String payableValue;
  final String statusLabel;
  final String historyButtonLabel;
  final String closeButtonLabel;
  final VoidCallback onClose;

  String? get _headline {
    final message = result?['message']?.toString();
    return (message == null || message.isEmpty) ? null : message;
  }

  /// Server-driven payment status, e.g. "pending"/"Success". Surfaced only
  /// when the backend actually sends it (null-safe pass-through).
  String? get _statusText {
    final data = result?['data'];
    if (data is Map) {
      final status = data['status']?.toString();
      if (status != null && status.isNotEmpty && status != 'null') {
        return status;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 192,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(PngAssets.pendingAndSuccessFrame),
                  fit: BoxFit.contain,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(PngAssets.commonSuccessIcon, width: 80),
                  const SizedBox(height: 16),
                  if (_headline != null)
                    Text(
                      textAlign: TextAlign.center,
                      _headline!,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: primaryTextColor,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.black).withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildResultDynamicContent(
                    context: context,
                    title: amountLabel,
                    content: amountValue,
                    contentColor: primaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: dividerColor,
                  ),
                  const SizedBox(height: 16),
                  _buildResultDynamicContent(
                    context: context,
                    title: chargeLabel,
                    content: chargeValue,
                    contentColor: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: dividerColor,
                  ),
                  const SizedBox(height: 16),
                  _buildResultDynamicContent(
                    context: context,
                    title: payableLabel,
                    content: payableValue,
                    contentColor: primaryTextColor,
                  ),
                  if (_statusText != null) ...[
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: dividerColor,
                    ),
                    const SizedBox(height: 16),
                    _buildResultDynamicContent(
                      context: context,
                      title: statusLabel,
                      content: _statusText!,
                      contentColor: primaryTextColor,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 36),
            CommonButton(
              onPressed: () => Get.toNamed(BaseRoute.billPaymentHistory),
              width: double.infinity,
              text: historyButtonLabel,
            ),
            const SizedBox(height: 16),
            CommonButton(
              onPressed: onClose,
              width: double.infinity,
              text: closeButtonLabel,
              backgroundColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightPrimary.withValues(alpha: 0.06),
              borderColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightPrimary.withValues(alpha: 0.60),
              borderWidth: 1.5,
              textColor: primaryTextColor,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  static Widget _buildResultDynamicContent({
    required BuildContext context,
    required String title,
    required String content,
    required Color contentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextPrimary.withValues(alpha: 0.60),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: contentColor,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
