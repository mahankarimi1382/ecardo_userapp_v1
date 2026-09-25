import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/kyc_error_handler.dart';
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
/// v1.0.90: دو اصلاح ناوبری که فقط بعد از هم‌راستا شدن سرور با این قرارداد
/// دیده شدند:
///   ۱) دکمهٔ اصلی دیگر از `offAllNamed(navigation)` + push با تأخیر ۳۰۰ms
///      استفاده نمی‌کند. آن الگو هم به یک صفحهٔ گاردشده تکیه می‌کرد (که خودش
///      دوباره ۴۰۳ می‌داد) و هم با درخواست هم‌زمانِ صفحهٔ خانه مسابقهٔ ناوبری
///      می‌ساخت. حالا یک ناوبری تمیز و مستقیم به صفحهٔ احراز هویت است.
///   ۲) دکمهٔ «بعداً» و دکمهٔ بازگشت فقط وقتی نمایش داده می‌شوند که مسدودی
///      فقط یک feature را بسته باشد. در مسدودی سراسری (level_required) هر
///      صفحهٔ دیگری در اپ هم ۴۰۳ می‌دهد، پس «بعداً» فقط کاربر را به همان
///      دیوار برمی‌گرداند.
///
/// همه‌ی متن‌ها از کاتالوگ l10n می‌آیند (en/fa/zh/ar/ru/tr) — کلید جدیدی
/// اضافه نشده، چون فایل‌های تولیدشدهٔ l10n در این ریپو STALE هستند و CI
/// آن‌ها را بازتولید می‌کند (see l10n.yaml).
class UpgradeRequiredScreen extends StatefulWidget {
  final int? requiredLevel;
  final int? currentLevel;
  final String? featureName;

  /// 'level_required' (مسدودی سراسری) | 'feature_required' | null.
  /// null یعنی «نامشخص» و مثل feature_required رفتار می‌شود (بازگشتی‌ها
  /// مثل tile های KYC-locked که فقط feature را می‌فرستند).
  final String? blockType;

  const UpgradeRequiredScreen({
    super.key,
    this.requiredLevel,
    this.currentLevel,
    this.featureName,
    this.blockType,
  });

  @override
  State<UpgradeRequiredScreen> createState() => _UpgradeRequiredScreenState();
}

class _UpgradeRequiredScreenState extends State<UpgradeRequiredScreen> {
  final NetworkService _networkService = Get.find<NetworkService>();

  int? _requiredLevel;
  int? _currentLevel;
  String? _feature;
  String? _blockType;
  bool _resolving = false;

  /// مسدودی سراسری: سرور کل گروه روت‌های کاربر را بسته، پس هیچ «بعداً»ای
  /// وجود ندارد که کاربر را به جای امنی برساند.
  bool get _isAppWideBlock =>
      _blockType == KycErrorHandler.blockTypeLevelRequired;

  @override
  void initState() {
    super.initState();
    _readArguments();
    if (_requiredLevel == null) {
      _resolveRequiredLevel();
    }
  }

  @override
  void dispose() {
    // QC-M3: re-arm the upgrade-screen navigation guard so a subsequent
    // KYC block navigates immediately even within the dedupe window.
    KycErrorHandler.resetRoutingGuard();
    super.dispose();
  }

  /// خواندن defensive آرگومان‌ها — سِروِر ممکن است اعداد را int، num یا
  /// string بفرستد و arguments می‌تواند Map یا مقدار مستقیم باشد.
  void _readArguments() {
    _requiredLevel = _asInt(widget.requiredLevel);
    _currentLevel = _asInt(widget.currentLevel);
    _feature = widget.featureName;
    _blockType = widget.blockType;

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
      final argBlockType = args['block_type']?.toString();
      if ((_blockType == null || _blockType!.isEmpty) &&
          argBlockType != null &&
          argBlockType.isNotEmpty) {
        _blockType = argBlockType;
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
        leading: _isAppWideBlock
            // مسدودی سراسری: بازگشت، کاربر را به صفحه‌ای می‌برد که دوباره
            // ۴۰۳ می‌دهد. به‌جای دکمهٔ بی‌اثر، هیچ ناوبری پیشنهاد نمی‌شود.
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.lightTextPrimary),
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
                        // v1.0.90: the old `_currentLevel ?? 1` told a
                        // level-0 (never-verified) user their level was 1,
                        // which contradicts the server's current_level=0 and
                        // the "0 = Unverified" level row. Show the real value
                        // and only fall back to 0, the honest unknown.
                        level: _currentLevel ?? 0,
                        color: AppColors.warning,
                        chipText: localization?.kycUpgradeLevelChip(
                              _currentLevel ?? 0,
                            ) ??
                            'Level ${_currentLevel ?? 0}',
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
                  // v1.0.90: one clean navigation straight to the (unguarded)
                  // KYC submission route. The previous
                  // `Get.offAllNamed(navigation)` + 300ms-delayed
                  // `Get.toNamed(idVerification)` both depended on a guarded
                  // screen and raced with the home screen's own request.
                  onPressed: () => Get.offAllNamed(BaseRoute.idVerification),
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

              // Secondary button — only when a non-app-wide screen exists to
              // return to. See _isAppWideBlock.
              if (!_isAppWideBlock) ...[
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    localization?.kycUpgradeLater ?? "I'll do it later",
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.lightTextSecondary),
                  ),
                ),
              ],
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
