import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/route_return.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/receipt/digital_receipt_ticket.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';

/// Step 2 — Success. Renders an animated checkmark (draw-in via custom
/// painter — no Lottie, no confetti), a digital receipt ticket (with
/// ticket clipper notches, perforated dashed line, barcode, QR code,
/// and high-resolution PNG & PDF export actions), and navigation buttons
/// ("Exchange again" and "Back to wallet").
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
                    const SizedBox(height: 28),
                    _buildSummaryCard(loc),
                    const SizedBox(height: 20),
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
    final tx = controller.successExchangeData.value;
    if (tx == null || tx["transaction"] is! Map) {
      return const SizedBox.shrink();
    }
    final t = Map<String, dynamic>.from(tx["transaction"] as Map);
    final bool isCrypto = t["is_crypto"] == true;

    final payCurrencyCode = t["pay_currency"]?.toString() ?? '';
    final receiveCurrencyCode = t["receive_currency"]?.toString() ?? '';
    final siteCurrency = settingsService.getSetting("site_currency") ?? "";
    final siteCurrencyDecimals =
        settingsService.getSetting("site_currency_decimals") ?? "2";

    final payDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: payCurrencyCode,
      siteCurrencyCode: siteCurrency,
      siteCurrencyDecimals: siteCurrencyDecimals,
      isCrypto: isCrypto,
    );
    final receiveDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: receiveCurrencyCode,
      siteCurrencyCode: siteCurrency,
      siteCurrencyDecimals: siteCurrencyDecimals,
      isCrypto: isCrypto,
    );

    final createdStr = t["created_at"]?.toString() ?? '';
    final dt = DateTime.tryParse(createdStr);
    String formattedDate;
    if (dt != null) {
      try {
        formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dt);
      } catch (_) {
        formattedDate = createdStr;
      }
    } else {
      formattedDate = createdStr;
    }

    final payAmount = double.tryParse(t["pay_amount"]?.toString() ?? '') ?? 0.0;
    final convertedAmount = double.tryParse(t["amount"]?.toString() ?? '') ?? 0.0;
    final charge = double.tryParse(t["charge"]?.toString() ?? '') ?? 0.0;
    final finalAmount = double.tryParse(t["final_amount"]?.toString() ?? '') ?? 0.0;
    final tnx = t["tnx"]?.toString() ?? '';

    // Calculate approximate exchange rate if available
    String? exchangeRateText;
    if (payAmount > 0 && convertedAmount > 0) {
      final rate = convertedAmount / payAmount;
      exchangeRateText = '1 $payCurrencyCode ≈ ${rate.toStringAsFixed(4)} $receiveCurrencyCode';
    }

    final extraRows = <ReceiptRowData>[
      ReceiptRowData(
        label: loc.exchangeSuccessPayAmount,
        amount: payAmount,
        decimals: payDecimals,
        currencyCode: payCurrencyCode,
      ),
      ReceiptRowData(
        label: loc.exchangeSuccessConvertedAmount,
        amount: convertedAmount,
        decimals: receiveDecimals,
        currencyCode: receiveCurrencyCode,
        isHighlighted: true,
      ),
      ReceiptRowData(
        label: loc.exchangeSuccessFinalAmount,
        amount: finalAmount,
        decimals: payDecimals,
        currencyCode: payCurrencyCode,
      ),
    ];

    final qrPayload = {
      'iss': 'eCardo',
      'type': 'exchange',
      'tnx': tnx,
      'pay_amount': payAmount,
      'pay_currency': payCurrencyCode,
      'amount': convertedAmount,
      'receive_currency': receiveCurrencyCode,
      'charge': charge,
      'final_amount': finalAmount,
      'created_at': createdStr,
      'status': 'success',
    };

    return DigitalReceiptTicket(
      title: loc.exchangeSuccessTitle,
      status: ReceiptStatus.success,
      transactionId: tnx,
      dateTime: dt,
      formattedDateTime: formattedDate,
      primaryAmount: convertedAmount,
      primaryCurrency: receiveCurrencyCode,
      primaryDecimals: receiveDecimals,
      fee: charge > 0 ? charge : null,
      feeCurrency: payCurrencyCode,
      feeDecimals: payDecimals,
      fromAccount: payCurrencyCode.isNotEmpty ? '$payCurrencyCode Wallet' : null,
      toAccount: receiveCurrencyCode.isNotEmpty ? '$receiveCurrencyCode Wallet' : null,
      exchangeRate: exchangeRateText,
      extraRows: extraRows,
      qrPayload: qrPayload,
      showBarcode: true,
      showQrCode: true,
      showActions: true,
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

    // Checkmark progress: 0 → 1 over the remaining 40% of the animation.
    if (animation.value > 0.6) {
      final checkProgress = ((animation.value - 0.6) / 0.4).clamp(0.0, 1.0);

      // Checkmark geometry centered in the circle.
      final p1 = Offset(center.dx - radius * 0.35, center.dy);
      final p2 = Offset(center.dx - radius * 0.05, center.dy + radius * 0.30);
      final p3 = Offset(center.dx + radius * 0.40, center.dy - radius * 0.25);

      final checkPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      // First segment: p1 → p2 (first 40% of check animation).
      final seg1Progress = (checkProgress / 0.4).clamp(0.0, 1.0);
      final currentP2 = Offset.lerp(p1, p2, seg1Progress)!;
      path.lineTo(currentP2.dx, currentP2.dy);

      // Second segment: p2 → p3 (remaining 60% of check animation).
      if (checkProgress > 0.4) {
        final seg2Progress = ((checkProgress - 0.4) / 0.6).clamp(0.0, 1.0);
        final currentP3 = Offset.lerp(p2, p3, seg2Progress)!;
        path.lineTo(currentP3.dx, currentP3.dy);
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => true;
}
