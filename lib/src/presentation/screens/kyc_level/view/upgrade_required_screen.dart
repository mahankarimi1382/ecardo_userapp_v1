import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

/// UpgradeRequiredScreen — صفحه‌ی "ارتقا مورد نیاز" به‌جای خطای خام
///
/// v1.1 (KYC-ERR): با قرارداد خطای یکپارچه‌ی سرور، این صفحه مقصد همه‌ی
/// مسدودسازی‌های KYC است:
///   - KYC_LEVEL_REQUIRED  → arguments شامل required_level (+ current_level)
///   - KYC_FEATURE_REQUIRED → arguments فقط شامل feature؛ سطح لازم از
///     GET /user/kyc-level/levels استخراج می‌شود (حداقل سطحی که آن
///     feature را دارد) و اگر استخراج شکست خورد، پیام جنریک نشان داده
///     می‌شود — هیچ‌وقت کرش نمی‌کند.
///
/// همه‌ی متن‌ها از کاتالوگ l10n می‌آیند (en/fa/zh/ar/ru/tr).
class UpgradeRequiredScreen extends StatefulWidget {
  final int? requiredLevel;
  final int? currentLevel;
  final String? featureName;

  const UpgradeRequiredScreen({
    super.key,
    this.requiredLevel,
    this.currentLevel,
    this.featureName,
  });

  @override
  State<UpgradeRequiredScreen> createState() => _UpgradeRequiredScreenState();
}

class _UpgradeRequiredScreenState extends State<UpgradeRequiredScreen> {
  final NetworkService _networkService = Get.find<NetworkService>();

  int? _requiredLevel;
  int? _currentLevel;
  String? _feature;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _readArguments();
    if (_requiredLevel == null) {
      _resolveRequiredLevel();
    }
  }

  /// خواندن defensive آرگومان‌ها — سِروِر ممکن است اعداد را int، num یا
  /// string بفرستد و arguments می‌تواند Map یا مقدار مستقیم باشد.
  void _readArguments() {
    _requiredLevel = _asInt(widget.requiredLevel);
    _currentLevel = _asInt(widget.currentLevel);
    _feature = widget.featureName;

    final args = Get.arguments;
    if (args is Map) {
      _requiredLevel ??= _asInt(args['required_level']);
      _currentLevel ??= _asInt(args['current_level']);
      final argFeature = args['feature']?.toString();
      if ((_feature == null || _feature!.isEmpty) &&
          argFeature != null &&
          argFeature.isNotEmpty) {
        _feature = argFeature;
      }
    }
  }

  /// KYC_FEATURE_REQUIRED: حداقل سطحی که feature را دارد از levels
  /// استخراج می‌شود. هر خطایی فقط پیام جنریک را فعال می‌کند — بدون کرش.
  Future<void> _resolveRequiredLevel() async {
    final feature = _feature;
    if (feature == null || feature.isEmpty) return;

    setState(() => _resolving = true);
    try {
      final response = await _networkService.get(
        endpoint: ApiPath.kycLevelLevelsEndpoint,
      );
      if (response.status == Status.completed && mounted) {
        final data = response.data?['data'] as List<dynamic>?;
        if (data != null) {
          int? minLevel;
          for (final raw in data) {
            if (raw is! Map) continue;
            final features = (raw['features'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const <String>[];
            if (features.contains(feature)) {
              final levelNum = _asInt(raw['level']);
              if (levelNum != null &&
                  (minLevel == null || levelNum < minLevel)) {
                minLevel = levelNum;
              }
            }
          }
          if (minLevel != null) {
            setState(() {
              _requiredLevel = minLevel;
              _resolving = false;
            });
            return;
          }
        }
      }
    } catch (_) {
      // intentional fall-through → generic message
    }
    if (mounted) setState(() => _resolving = false);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final hasResolvedLevel = _requiredLevel != null;
    final featureLabel = _featureDisplayLabel(localization, _feature);

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppColors.warning,
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Text(
                localization?.kycUpgradeRequiredTitle ??
                    'Verification upgrade required',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Description
              if (_resolving && !hasResolvedLevel)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Text(
                  hasResolvedLevel
                      ? (localization?.kycUpgradeBodyForLevel(
                            _requiredLevel!,
                          ) ??
                          'To use this feature, your identity verification '
                              'must reach level $_requiredLevel.')
                      : (localization?.kycUpgradeBodyGeneric ??
                          'Your current verification level does not allow '
                              'this action. Please complete or upgrade your '
                              'identity verification.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.lightTextSecondary,
                    height: 1.6,
                  ),
                ),

              // Feature chip (only when the server told us which feature)
              if (featureLabel != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    featureLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.h),

              // Level comparison
              if (hasResolvedLevel) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _LevelInfo(
                        label: localization?.kycUpgradeCurrentLevel ??
                            'Your level',
                        level: _currentLevel ?? 1,
                        color: AppColors.warning,
                        chipText: localization?.kycUpgradeLevelChip(
                              _currentLevel ?? 1,
                            ) ??
                            'Level ${_currentLevel ?? 1}',
                      ),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppColors.lightBorder),
                      _LevelInfo(
                        label: localization?.kycUpgradeRequiredLevel ??
                            'Required level',
                        level: _requiredLevel!,
                        color: AppColors.lightPrimary,
                        chipText: localization?.kycUpgradeLevelChip(
                              _requiredLevel!,
                            ) ??
                            'Level $_requiredLevel',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
              ] else
                SizedBox(height: 32.h),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(BaseRoute.navigation);
                    // Navigate to KYC verification
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Get.toNamed(BaseRoute.idVerification);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    localization?.kycUpgradeStartVerification ??
                        'Start verification',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Secondary button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  localization?.kycUpgradeLater ?? "I'll do it later",
                  style: TextStyle(
                      fontSize: 14.sp, color: AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// نام نمایشی feature — کلیدهای شناخته‌شده ترجمه می‌شوند، بقیه به‌صورت
  /// کلید خوانا رندر می‌شوند (بدون کرش، بدون متن خام انگلیسیِ فنی).
  String? _featureDisplayLabel(
    AppLocalizations? localization,
    String? feature,
  ) {
    if (feature == null || feature.isEmpty) return null;
    switch (feature) {
      case 'transfer':
        return localization?.kycFeatureTransfer ?? 'Transfer';
      case 'exchange':
        return localization?.kycFeatureExchange ?? 'Exchange';
      case 'withdraw':
        return localization?.kycFeatureWithdraw ?? 'Withdrawal';
      case 'cashout':
        return localization?.kycFeatureCashout ?? 'Cash-out';
      case 'gift_send':
      case 'gift-send':
        return localization?.kycFeatureGiftSend ?? 'Gift sending';
      case 'gift_redeem':
      case 'gift-redeem':
        return localization?.kycFeatureGiftRedeem ?? 'Gift redeeming';
      case 'pay-bill':
      case 'pay_bill':
        return localization?.kycFeaturePayBill ?? 'Bill payment';
      case 'request-money':
      case 'request_money':
        return localization?.kycFeatureRequestMoney ?? 'Money requests';
      case 'payment':
        return localization?.kycFeaturePayment ?? 'Merchant payment';
      case 'invoices':
      case 'invoice':
        return localization?.kycFeatureInvoices ?? 'Invoice payment';
      case 'payment-links':
      case 'payment_links':
        return localization?.kycFeaturePaymentLinks ?? 'Payment links';
      case 'travel':
        return localization?.kycFeatureTravel ?? 'Travel booking';
      case 'remittance':
        return localization?.kycFeatureRemittance ?? 'Remittance';
      case 'epay':
        return localization?.kycFeatureEpay ?? 'ePay';
      default:
        // کلید ناشناخته: خوانا و امن — بدون کرش.
        return feature.replaceAll('_', ' ').replaceAll('-', ' ');
    }
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class _LevelInfo extends StatelessWidget {
  final String label;
  final int level;
  final Color color;
  final String chipText;

  const _LevelInfo({
    required this.label,
    required this.level,
    required this.color,
    required this.chipText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11.sp, color: AppColors.lightTextSecondary)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            chipText,
            style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}
