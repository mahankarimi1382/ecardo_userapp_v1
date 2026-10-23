import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/digit_normalization_formatter.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_language_pill.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/set_passcode_controller.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/visual_pin_dots_indicator.dart';

/// First-stage mandatory transaction passcode (exactly 4 digits).
/// Modernized with M3 tokens, AmbientAuthBackground, VisualPinDotsIndicator,
/// haptic feedback, and accessible touch targets.
class SetPasscodeScreen extends StatefulWidget {
  const SetPasscodeScreen({super.key});

  @override
  State<SetPasscodeScreen> createState() => _SetPasscodeScreenState();
}

class _SetPasscodeScreenState extends State<SetPasscodeScreen> {
  late final SetPasscodeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SetPasscodeController>()
        ? Get.find<SetPasscodeController>()
        : Get.put(SetPasscodeController());

    controller.passcodeController.addListener(_onInputChanged);
    controller.confirmController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.passcodeController.removeListener(_onInputChanged);
    controller.confirmController.removeListener(_onInputChanged);
    super.dispose();
  }

  static final _digitLimit = [const DigitNormalizationFormatter(maxLength: 4)];

  void _skip() {
    HapticFeedback.lightImpact();
    final route = controller.nextRoute;
    final args = controller.nextArgs;
    if (route == BaseRoute.navigation) {
      Get.offAllNamed(route);
    } else {
      Get.offNamed(route, arguments: args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextTertiary;

    final accentColor = isDark
        ? AppColors.darkAccent
        : AppColors.brandViolet;

    final cardBg = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.94)
        : AppColors.white.withValues(alpha: 0.96);
    final cardBorder = isDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder.withValues(alpha: 0.7);

    final passcodeText = controller.passcodeController.text;
    final confirmText = controller.confirmController.text;
    final isMismatch = passcodeText.length == 4 &&
        confirmText.length == 4 &&
        passcodeText != confirmText;
    final isMatch = passcodeText.length == 4 &&
        confirmText.length == 4 &&
        passcodeText == confirmText;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _skip();
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: const CommonDefaultAppBar(),
        body: AmbientAuthBackground(
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Top Navigation Bar
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Semantics(
                              button: true,
                              label: 'Back',
                              child: IconButton(
                                tooltip: 'Back',
                                onPressed: _skip,
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20.sp,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(
                                      alpha: isDark ? 0.16 : 0.25,
                                    ),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                PngAssets.appLogo,
                                fit: BoxFit.contain,
                                height: 30.h,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Semantics(
                                  button: true,
                                  label: l10nPick(
                                    context,
                                    en: 'Later',
                                    fa: 'بعداً',
                                    ar: 'لاحقاً',
                                    zh: '稍后',
                                  ),
                                  child: TextButton(
                                    onPressed: _skip,
                                    style: TextButton.styleFrom(
                                      minimumSize: Size(48.w, 48.h),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                      ),
                                    ),
                                    child: Text(
                                      l10nPick(
                                        context,
                                        en: 'Later',
                                        fa: 'بعداً',
                                        ar: 'لاحقاً',
                                        zh: '稍后',
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const AuthLanguagePill(),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Title & Subtitle
                      Text(
                        loc.generatePasscodeTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w900,
                          fontSize: 24.sp,
                          color: primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          loc.generatePasscodeSectionDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Form Glass Card
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 18.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 24.h,
                          ),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(28.r),
                            border: Border.all(
                              color: cardBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(
                                  alpha: isDark ? 0.35 : 0.08,
                                ),
                                blurRadius: 32,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Passcode Field
                              CommonRequiredLabelAndDynamicField(
                                labelText: loc.generatePasscodeLabelPasscode,
                                isLabelRequired: true,
                                dynamicField: Obx(
                                  () => CommonTextInputField(
                                    hintText: '••••',
                                    controller: controller.passcodeController,
                                    focusNode: controller.passcodeFocusNode,
                                    isFocused: controller.isPasscodeFocused.value,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    inputFormatters: _digitLimit,
                                  ),
                                ),
                              ),

                              // Visual 4-Dot Indicator for Passcode
                              SizedBox(height: 10.h),
                              VisualPinDotsIndicator(
                                length: 4,
                                filledCount: passcodeText.length,
                                isDark: isDark,
                                dotSize: 12.r,
                                spacing: 12.w,
                              ),

                              SizedBox(height: 20.h),

                              // Confirm Passcode Field
                              CommonRequiredLabelAndDynamicField(
                                labelText:
                                    loc.generatePasscodeLabelConfirmPasscode,
                                isLabelRequired: true,
                                dynamicField: Obx(
                                  () => CommonTextInputField(
                                    hintText: '••••',
                                    controller: controller.confirmController,
                                    focusNode: controller.confirmFocusNode,
                                    isFocused: controller.isConfirmFocused.value,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    inputFormatters: _digitLimit,
                                  ),
                                ),
                              ),

                              // Visual 4-Dot Indicator for Confirm
                              SizedBox(height: 10.h),
                              VisualPinDotsIndicator(
                                length: 4,
                                filledCount: confirmText.length,
                                isDark: isDark,
                                isError: isMismatch,
                                isSuccess: isMatch,
                                dotSize: 12.r,
                                spacing: 12.w,
                              ),

                              SizedBox(height: 28.h),

                              // Submit Button
                              CommonButton(
                                height: 52.h,
                                borderRadius: 16.r,
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  controller.submit();
                                },
                                width: double.infinity,
                                text: loc.generatePasscodeButtonConfirm,
                              ),

                              SizedBox(height: 16.h),

                              // Skip Button with Accessible Touch Target
                              Semantics(
                                button: true,
                                label: l10nPick(
                                  context,
                                  en: 'Skip for now',
                                  fa: 'فعلاً رد شو',
                                  ar: 'تخطي الآن',
                                  zh: '暂时跳过',
                                ),
                                child: TextButton(
                                  onPressed: _skip,
                                  style: TextButton.styleFrom(
                                    minimumSize: Size(double.infinity, 48.h),
                                  ),
                                  child: Text(
                                    l10nPick(
                                      context,
                                      en: 'Skip for now',
                                      fa: 'فعلاً رد شو',
                                      ar: 'تخطي الآن',
                                      zh: '暂时跳过',
                                    ),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),

              Obx(
                () => Visibility(
                  visible: controller.isLoading.value,
                  child: const CommonLoading(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
