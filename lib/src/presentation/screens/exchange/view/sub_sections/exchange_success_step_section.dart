import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/route_return.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart';

/// Step 2 — Celebratory Success.
///
/// Features:
///   - Custom animated celebration checkmark with expanding success aura
///   - Digital receipt ticket summary (notched ticket with QR payload and share/download actions)
///   - Primary and secondary navigation actions with haptics
///   - Complete dark mode and RTL support
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

  late final AnimationController _celebrationController;
  late final Animation<double> _checkAnimation;
  late final Animation<double> _auraAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _checkAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
    );

    _auraAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        HapticFeedback.heavyImpact();
        _celebrationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = ExchangeDesignTokens.isDark(context);

    return Obx(
      () => controller.isExchangeWalletLoading.value
          ? const CommonLoading()
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    // Celebratory animated checkmark with aura
                    Center(
                      child: SizedBox(
                        width: 104,
                        height: 104,
                        child: AnimatedBuilder(
                          animation: _celebrationController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _CelebrationCheckPainter(
                                checkProgress: _checkAnimation.value,
                                auraProgress: _auraAnimation.value,
                                isDark: isDark,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      loc.exchangeSuccessTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: ExchangeDesignTokens.textPrimary(context),
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSummaryCard(loc),
                    const SizedBox(height: AppSpacing.xl),
                    // Exchange again
                    CommonButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.currentStep.value = 0;
                        controller.clearFields();
                      },
                      width: double.infinity,
                      backgroundColor: isDark
                          ? AppColors.mainSoftBlue
                          : AppColors.lightPrimary,
                      textColor:
                          isDark ? AppColors.deepBlack : AppColors.white,
                      text: loc.exchangeSuccessExchangeAgain,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Back to wallet
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Get.delete<ExchangeController>();
                        RouteReturn.complete();
                      },
                      width: double.infinity,
                      text: loc.exchangeSuccessBackToWallet,
                      backgroundColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightPrimary.withValues(alpha: 0.05),
                      borderColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightPrimary.withValues(alpha: 0.40),
                      borderWidth: 1.5,
                      textColor: ExchangeDesignTokens.textPrimary(context),
                    ),
                    const SizedBox(height: AppSpacing.huge),
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

    final payAmount =
        double.tryParse(t["pay_amount"]?.toString() ?? '') ?? 0.0;
    final convertedAmount =
        double.tryParse(t["amount"]?.toString() ?? '') ?? 0.0;
    final charge = double.tryParse(t["charge"]?.toString() ?? '') ?? 0.0;
    final finalAmount =
        double.tryParse(t["final_amount"]?.toString() ?? '') ?? 0.0;
    final tnx = t["tnx"]?.toString() ?? '';

    // Calculate approximate exchange rate if available
    String? exchangeRateText;
    if (payAmount > 0 && convertedAmount > 0) {
      final rate = convertedAmount / payAmount;
      exchangeRateText =
          '1 $payCurrencyCode ≈ ${rate.toStringAsFixed(4)} $receiveCurrencyCode';
    }

    final receiptItems = <EcardoReceiptItem>[
      EcardoReceiptItem(
        label: loc.exchangeSuccessPayAmount,
        amount: payAmount,
        currency: payCurrencyCode,
        decimals: payDecimals,
      ),
      EcardoReceiptItem(
        label: loc.exchangeSuccessConvertedAmount,
        amount: convertedAmount,
        currency: receiveCurrencyCode,
        decimals: receiveDecimals,
        isHighlighted: true,
        valueColor: AppColors.success,
      ),
      if (charge > 0)
        EcardoReceiptItem(
          label: loc.exchangeReviewCharge,
          amount: charge,
          currency: payCurrencyCode,
          decimals: payDecimals,
        ),
      EcardoReceiptItem(
        label: loc.exchangeSuccessFinalAmount,
        amount: finalAmount,
        currency: payCurrencyCode,
        decimals: payDecimals,
      ),
      if (exchangeRateText != null)
        EcardoReceiptItem(
          label: loc.exchangeReviewExchangeRate,
          value: exchangeRateText,
        ),
      EcardoReceiptItem(
        label: loc.exchangeReviewFromWallet,
        value: payCurrencyCode.isNotEmpty ? '$payCurrencyCode Wallet' : '—',
      ),
      EcardoReceiptItem(
        label: loc.exchangeReviewToWallet,
        value: receiveCurrencyCode.isNotEmpty
            ? '$receiveCurrencyCode Wallet'
            : '—',
      ),
      EcardoReceiptItem(
        label: 'Transaction ID',
        value: tnx,
        isCopyable: true,
        copyText: tnx,
      ),
    ];

    return EcardoDigitalReceipt(
      title: loc.exchangeSuccessTitle,
      transactionReference: tnx,
      timestamp: dt,
      formattedTimestamp: formattedDate,
      primaryAmount: convertedAmount,
      primaryCurrency: receiveCurrencyCode,
      primaryDecimals: receiveDecimals,
      status: EcardoReceiptStatus.success,
      items: receiptItems,
      showBarcode: true,
      showWatermark: true,
    );
  }
}

/// Celebratory checkmark with smooth expanding ring and animated check mark.
class _CelebrationCheckPainter extends CustomPainter {
  const _CelebrationCheckPainter({
    required this.checkProgress,
    required this.auraProgress,
    required this.isDark,
  });

  final double checkProgress;
  final double auraProgress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 8;

    // 1. Subtle expanding aura wave
    if (auraProgress > 0) {
      final auraRadius = radius + (14 * auraProgress);
      final auraOpacity = (1.0 - auraProgress).clamp(0.0, 1.0) * 0.25;
      final auraPaint = Paint()
        ..color = AppColors.success.withValues(alpha: auraOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, auraRadius, auraPaint);
    }

    // 2. Soft filled inner background disk
    final bgPaint = Paint()
      ..color = isDark
          ? AppColors.success.withValues(alpha: 0.15)
          : AppColors.successContainer
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 3. Ring progress: fills clockwise over checkProgress (0 -> 0.6)
    final ringProgress = (checkProgress / 0.6).clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ringProgress,
      false,
      ringPaint,
    );

    // 4. Checkmark progress (0.6 -> 1.0)
    if (checkProgress > 0.6) {
      final segProgress = ((checkProgress - 0.6) / 0.4).clamp(0.0, 1.0);

      final p1 = Offset(center.dx - radius * 0.35, center.dy);
      final p2 = Offset(center.dx - radius * 0.05, center.dy + radius * 0.30);
      final p3 = Offset(center.dx + radius * 0.40, center.dy - radius * 0.25);

      final checkPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      final seg1 = (segProgress / 0.4).clamp(0.0, 1.0);
      final curP2 = Offset.lerp(p1, p2, seg1)!;
      path.lineTo(curP2.dx, curP2.dy);

      if (segProgress > 0.4) {
        final seg2 = ((segProgress - 0.4) / 0.6).clamp(0.0, 1.0);
        final curP3 = Offset.lerp(p2, p3, seg2)!;
        path.lineTo(curP3.dx, curP3.dy);
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CelebrationCheckPainter oldDelegate) {
    return oldDelegate.checkProgress != checkProgress ||
        oldDelegate.auraProgress != auraProgress ||
        oldDelegate.isDark != isDark;
  }
}
