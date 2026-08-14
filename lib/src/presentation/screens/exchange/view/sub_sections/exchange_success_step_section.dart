import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/route_return.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/money_display_text.dart';

/// Step 2 — Success. Renders an animated checkmark (draw-in via custom
/// painter — no Lottie, no confetti), a summary card with the same
/// typographic system used elsewhere, and two buttons: Share Receipt
/// (uses share_plus) and Back to Wallet.
class ExchangeSuccessStepSection extends StatefulWidget {
  const ExchangeSuccessStepSection({super.key});

  @override
  State<ExchangeSuccessStepSection> createState() =>
      _ExchangeSuccessStepSectionState();
}

class _ExchangeSuccessStepSectionState
    extends State<ExchangeSuccessStepSection>
    with SingleTickerProviderStateMixin {
  final ExchangeController controller = Get.find();
  final settingsService = Get.find<SettingsService>();

  late final AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Slight delay so the check appears after the page transition.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _checkController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Obx(
      () => controller.isExchangeWalletLoading.value
          ? CommonLoading()
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Animated checkmark — minimal, formal. No confetti.
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: CustomPaint(
                        painter: _CheckPainter(_checkController),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      loc.exchangeSuccessTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.lightTextPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSummaryCard(loc),
                    const SizedBox(height: 32),
                    // Share Receipt
                    CommonButton(
                      onPressed: _shareReceipt,
                      width: double.infinity,
                      text: loc.exchangeSuccessShareReceipt,
                      backgroundColor:
                          AppColors.lightPrimary.withValues(alpha: 0.06),
                      borderColor:
                          AppColors.lightPrimary.withValues(alpha: 0.60),
                      borderWidth: 2,
                      textColor: AppColors.lightPrimary,
                    ),
                    const SizedBox(height: 12),
                    // Exchange again
                    CommonButton(
                      onPressed: () {
                        controller.currentStep.value = 0;
                        controller.clearFields();
                      },
                      width: double.infinity,
                      text: loc.exchangeSuccessExchangeAgain,
                    ),
                    const SizedBox(height: 12),
                    // Back to wallet
                    CommonButton(
                      onPressed: () async {
                        Get.delete<ExchangeController>();
                        RouteReturn.complete();
                      },
                      width: double.infinity,
                      text: loc.exchangeSuccessBackToWallet,
                      backgroundColor:
                          AppColors.lightPrimary.withValues(alpha: 0.06),
                      borderColor:
                          AppColors.lightPrimary.withValues(alpha: 0.60),
                      borderWidth: 2,
                      textColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations loc) {
    final tx = controller.successExchangeData.value!;
    final bool isCrypto = tx["transaction"]["is_crypto"] == true;
    final decimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: tx["transaction"]["receive_currency"]?.toString() ?? "",
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: isCrypto,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _SuccessRow(
            title: loc.exchangeSuccessAmount,
            amount:
                double.tryParse(controller.amountController.text) ?? 0.0,
            decimals: decimals,
            currencyCode: tx["transaction"]["pay_currency"]?.toString(),
          ),
          _divider(),
          _SuccessRow(
            title: loc.exchangeSuccessTransactionId,
            text: tx["transaction"]["tnx"]?.toString() ?? '',
            copyable: true,
          ),
          _divider(),
          _SuccessRow(
            title: loc.exchangeSuccessPayAmount,
            amount: double.tryParse(
              tx["transaction"]["pay_amount"].toString(),
            ) ?? 0.0,
            decimals: decimals,
            currencyCode: tx["transaction"]["pay_currency"]?.toString(),
          ),
          _divider(),
          _SuccessRow(
            title: loc.exchangeSuccessConvertedAmount,
            amount: double.tryParse(
              tx["transaction"]["amount"].toString(),
            ) ?? 0.0,
            decimals: decimals,
            currencyCode: tx["transaction"]["receive_currency"]?.toString(),
          ),
          _divider(),
          _SuccessRow(
            title: loc.exchangeSuccessCharge,
            amount: double.tryParse(
              tx["transaction"]["charge"].toString(),
            ) ?? 0.0,
            decimals: decimals,
            currencyCode: tx["transaction"]["pay_currency"]?.toString(),
            amountColor: AppColors.warning,
          ),
          _divider(),
          _SuccessRow(
            title: loc.exchangeSuccessDate,
            text: tx["transaction"]["created_at"]?.toString() ?? '',
          ),
          _divider(),
          _SuccessRow(
            title: loc.exchangeSuccessFinalAmount,
            amount: double.tryParse(
              tx["transaction"]["final_amount"].toString(),
            ) ?? 0.0,
            decimals: decimals,
            currencyCode: tx["transaction"]["pay_currency"]?.toString(),
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
          height: 0,
          color: AppColors.black.withValues(alpha: 0.06),
        ),
      );

  void _shareReceipt() {
    HapticFeedback.selectionClick();
    final tx = controller.successExchangeData.value!;
    final t = tx["transaction"];
    final text = StringBuffer()
      ..writeln('eCardo — Exchange Receipt')
      ..writeln('========================')
      ..writeln('Tx ID:        ${t["tnx"]}')
      ..writeln('Date:         ${t["created_at"]}')
      ..writeln(
          'Amount:       ${t["pay_amount"]} ${t["pay_currency"]}')
      ..writeln(
          'Converted:    ${t["amount"]} ${t["receive_currency"]}')
      ..writeln('Charge:       ${t["charge"]} ${t["pay_currency"]}')
      ..writeln(
          'Final:        ${t["final_amount"]} ${t["pay_currency"]}')
      ..writeln('========================');
    Share.share(text.toString(), subject: 'eCardo Exchange Receipt');
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({
    required this.title,
    this.text,
    this.amount,
    this.decimals,
    this.currencyCode,
    this.amountColor,
    this.emphasize = false,
    this.copyable = false,
  });

  final String title;
  final String? text;
  final double? amount;
  final int? decimals;
  final String? currencyCode;
  final Color? amountColor;
  final bool emphasize;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (text != null)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      text!,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                        fontSize: emphasize ? 16 : 14,
                        color: AppColors.lightTextPrimary,
                        letterSpacing: 0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (copyable) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Clipboard.setData(
                          ClipboardData(text: text ?? ''),
                        );
                      },
                      child: Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            )
          else if (amount != null && decimals != null)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: MoneyDisplayText(
                  amount: amount!,
                  decimals: decimals!,
                  currencyCode: currencyCode,
                  integerColor: amountColor ?? AppColors.lightTextPrimary,
                  decimalColor: (amountColor ?? AppColors.lightTextPrimary)
                      .withValues(alpha: 0.55),
                  integerStyle: TextStyle(
                    fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                    fontSize: emphasize ? 18 : 15,
                    color: amountColor ?? AppColors.lightTextPrimary,
                  ),
                  decimalStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: emphasize ? 14 : 12,
                    color: (amountColor ?? AppColors.lightTextPrimary)
                        .withValues(alpha: 0.55),
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Draws a circular success ring that fills clockwise, then a checkmark
/// that draws in once the ring is complete. Minimal — no fill, no
/// gradient, single accent colour.
class _CheckPainter extends CustomPainter {
  _CheckPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;

    // Ring progress: 0 → 1 over the first 60% of the animation.
    final ringProgress = (animation.value / 0.6).clamp(0.0, 1.0);

    final ringPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ringProgress,
      false,
      ringPaint,
    );

    // Check draws in over the last 50% of the animation.
    if (animation.value > 0.5) {
      // 0..1 across the second half of the parent animation.
      final checkProgress =
          ((animation.value - 0.5) / 0.5).clamp(0.0, 1.0);
      final checkPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final p1 = Offset(center.dx - radius * 0.4, center.dy + radius * 0.05);
      final p2 = Offset(center.dx - radius * 0.10, center.dy + radius * 0.35);
      final p3 = Offset(center.dx + radius * 0.45, center.dy - radius * 0.30);

      // First segment: p1 → p2, occupies 0..0.5 of checkProgress.
      final seg1T = (checkProgress / 0.5).clamp(0.0, 1.0);
      final seg1End = Offset.lerp(p1, p2, seg1T)!;
      canvas.drawLine(p1, seg1End, checkPaint);

      // Second segment: p2 → p3, occupies 0.5..1.0 of checkProgress.
      if (checkProgress > 0.5) {
        final seg2T = ((checkProgress - 0.5) / 0.5).clamp(0.0, 1.0);
        final seg2End = Offset.lerp(p2, p3, seg2T)!;
        canvas.drawLine(p2, seg2End, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
