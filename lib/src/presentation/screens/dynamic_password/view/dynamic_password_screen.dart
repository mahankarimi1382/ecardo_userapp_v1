import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/settings_screen.dart';

class DynamicPasswordScreen extends StatefulWidget {
  const DynamicPasswordScreen({super.key});

  @override
  State<DynamicPasswordScreen> createState() => _DynamicPasswordScreenState();
}

class _DynamicPasswordScreenState extends State<DynamicPasswordScreen> {
  String? _otpCode;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ensureUserData();
  }

  Future<void> _ensureUserData() async {
    final home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put<HomeController>(HomeController());
    if (home.userModel.value.data?.accountNumber == null ||
        home.userModel.value.data!.accountNumber!.isEmpty) {
      await home.loadData();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generateOtp() async {
    if (_isLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    _timer?.cancel();

    try {
      final home = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : Get.put<HomeController>(HomeController());
      if (home.userModel.value.data?.accountNumber == null ||
          home.userModel.value.data!.accountNumber!.isEmpty) {
        await home.loadData();
      }
      final accountNumber = home.userModel.value.data?.accountNumber ?? '';

      if (accountNumber.isEmpty) {
        final loc = Get.context == null ? null : AppLocalizations.of(Get.context!);
        ToastHelper().showErrorToast(
          loc?.dynamicPasswordUserNotFound ?? 'Account number not found',
        );
        setState(() => _isLoading = false);
        return;
      }

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.generateDynamicPasswordOtpEndpoint,
        data: {'account_number': accountNumber},
      );

      if (response.status == Status.completed && response.data != null) {
        final responseData = response.data!;
        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          setState(() {
            _otpCode = data['code']?.toString() ?? '';
            _secondsRemaining = data['expires_in'] ?? 60;
            _isLoading = false;
          });
          HapticFeedback.mediumImpact();
          _startCountdown();
        } else {
          ToastHelper().showErrorToast(
            responseData['message'] ??
                AppLocalizations.of(Get.context!)!
                    .dynamicPasswordGenerateError,
          );
          setState(() => _isLoading = false);
        }
      } else {
        ToastHelper().showErrorToast(
          response.message ?? AppLocalizations.of(Get.context!)!.dynamicPasswordServerError,
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.dynamicPasswordConnectionError,
      );
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        setState(() => _otpCode = null);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    final accountNumber = home?.userModel.value.data?.accountNumber ?? '';

    if (home == null || accountNumber.isEmpty) {
      final code = Localizations.localeOf(context).languageCode;
      String title;
      String subtitle;
      String back;
      if (code == 'fa') {
        title = 'حساب آماده نیست';
        subtitle =
            'ابتدا صفحهٔ اصلی را باز کنید تا شماره حساب بارگذاری شود، سپس دوباره تلاش کنید.';
        back = 'بازگشت';
      } else if (code == 'ar') {
        title = 'الحساب غير جاهز';
        subtitle =
            'افتح الشاشة الرئيسية أولاً لتحميل رقم الحساب ثم حاول مرة أخرى.';
        back = 'رجوع';
      } else {
        title = 'Account not ready';
        subtitle =
            'Open the home screen first so your account number is loaded, then try again.';
        back = 'Go back';
      }

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.dynamicPasswordHeading,
            style: AppTextStyles.titleMedium.copyWith(color: primaryTextColor),
          ),
          backgroundColor: bgColor,
          foregroundColor: primaryTextColor,
          elevation: 0,
        ),
        body: Center(
          child: EcardoEmptyState(
            animateGlow: false,
            iconData: Icons.lock_outline_rounded,
            title: title,
            description: subtitle,
            primaryActionLabel: back,
            onPrimaryAction: () => Get.back(),
          ),
        ),
      );
    }

    final iconStyle = SettingsIconTokens.paymentOtp(isDark: isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.dynamicPasswordTitle,
          style: AppTextStyles.titleMedium.copyWith(color: primaryTextColor),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        foregroundColor: primaryTextColor,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.lg),

              // Animated payment OTP icon container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(
                    color: iconStyle.iconColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.password_rounded,
                  size: 34,
                  color: iconStyle.iconColor,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              Text(
                AppLocalizations.of(context)!.dynamicPasswordHeading,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                AppLocalizations.of(context)!.dynamicPasswordSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxl),

              if (_isLoading)
                CircularProgressIndicator(
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                )
              else if (_otpCode != null && _secondsRemaining > 0) ...[
                // Active OTP Card with pulsating glow
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                          .withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                            .withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Monospace OTP Digits
                      Text(
                        _otpCode!,
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                          letterSpacing: 8,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Countdown timer badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _secondsRemaining <= 10
                              ? AppColors.error.withValues(alpha: 0.12)
                              : (isDark
                                  ? AppColors.mainSoftBlue.withValues(alpha: 0.15)
                                  : AppColors.lightPrimary.withValues(alpha: 0.10)),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: _secondsRemaining <= 10
                                  ? AppColors.error
                                  : (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              _formattedTime,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _secondsRemaining <= 10
                                    ? AppColors.error
                                    : (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        AppLocalizations.of(context)!.dynamicPasswordValidity,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Copy code button
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: _otpCode!));
                    ToastHelper().showSuccessToast(
                      AppLocalizations.of(Get.context!)!.dynamicPasswordCopied,
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.dynamicPasswordCopy,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    elevation: 0,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),

                TextButton.icon(
                  onPressed: _generateOtp,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    AppLocalizations.of(context)!.dynamicPasswordRegenerate,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    ),
                  ),
                ),
              ] else ...[
                // Initial generate button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _generateOtp,
                    icon: const Icon(Icons.shield_outlined, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.dynamicPasswordGenerate,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Usage hint bottom card
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF78350F).withValues(alpha: 0.25)
                      : AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.dynamicPasswordUsageHint,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.bottomSafe(context, AppSpacing.lg)),
            ],
          ),
        ),
      ),
    );
  }
}
