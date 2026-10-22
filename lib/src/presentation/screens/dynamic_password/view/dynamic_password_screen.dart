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
  int _totalSeconds = 60;
  Timer? _timer;
  bool _isLoading = false;
  bool _isCopied = false;

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
          final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 60;
          setState(() {
            _otpCode = data['code']?.toString() ?? '';
            _secondsRemaining = expiresIn;
            _totalSeconds = expiresIn > 0 ? expiresIn : 60;
            _isLoading = false;
            _isCopied = false;
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
        setState(() {
          _otpCode = null;
          _isCopied = false;
        });
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _copyCode() {
    if (_otpCode == null || _otpCode!.isEmpty) return;
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: _otpCode!));
    setState(() => _isCopied = true);
    ToastHelper().showSuccessToast(
      AppLocalizations.of(Get.context!)?.dynamicPasswordCopied ??
          'Code copied to clipboard',
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

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
              const SizedBox(height: AppSpacing.lg),

              Text(
                AppLocalizations.of(context)!.dynamicPasswordHeading,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppLocalizations.of(context)!.dynamicPasswordSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              if (_isLoading)
                CircularProgressIndicator(
                  color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                )
              else if (_otpCode != null && _secondsRemaining > 0) ...[
                // Active OTP Card with countdown timer ring & tap-to-copy
                _buildActiveOtpCard(isDark, primaryTextColor, secondaryTextColor),
                const SizedBox(height: AppSpacing.lg),

                // Tokenized Copy code button
                _buildCopyButton(isDark),
                const SizedBox(height: AppSpacing.sm),

                // Regenerate button
                TextButton.icon(
                  onPressed: _isLoading ? null : _generateOtp,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    AppLocalizations.of(context)!.dynamicPasswordRegenerate,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else ...[
                // Initial generate button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateOtp,
                    icon: const Icon(Icons.shield_outlined, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.dynamicPasswordGenerate,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
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
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: AppSpacing.sm),
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

  /// Modern active OTP card with tap-to-copy and dynamic timer ring
  Widget _buildActiveOtpCard(
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final timerColor = _secondsRemaining <= 10
        ? AppColors.error
        : (_secondsRemaining <= 20
            ? AppColors.warning
            : (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet));

    final cardBorderColor = (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
        .withValues(alpha: 0.35);

    final timerTrackColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightOutlineVariant.withValues(alpha: 0.60);

    final timerProgress = _totalSeconds > 0
        ? (_secondsRemaining / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: cardBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                .withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Monospace OTP Digits (interactive tap-to-copy)
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: _copyCode,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _otpCode!,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                        letterSpacing: 7,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                      size: 18,
                      color: _isCopied
                          ? AppColors.success
                          : (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                              .withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tokenized OTP Generator Timer Ring
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Timer Ring
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: timerProgress,
                      strokeWidth: 4.0,
                      strokeCap: StrokeCap.round,
                      backgroundColor: timerTrackColor,
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    ),
                    Text(
                      '$_secondsRemaining',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Countdown timer badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: timerColor.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: timerColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: timerColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formattedTime,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          Text(
            AppLocalizations.of(context)!.dynamicPasswordValidity,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Tokenized Copy Code Action CTA
  Widget _buildCopyButton(bool isDark) {
    final buttonColor = _isCopied
        ? AppColors.success
        : (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet);
    final textColor = _isCopied
        ? AppColors.white
        : (isDark ? AppColors.deepBlack : AppColors.white);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _copyCode,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
            key: ValueKey(_isCopied),
            size: 18,
          ),
        ),
        label: Text(
          _isCopied
              ? (AppLocalizations.of(context)?.dynamicPasswordCopied ?? 'Copied')
              : AppLocalizations.of(context)!.dynamicPasswordCopy,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
          shadowColor: buttonColor.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
