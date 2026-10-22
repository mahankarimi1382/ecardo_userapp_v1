import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Multi-step onboarding progress bar for the flagship sign-up journey:
/// Step 1: Account Info
/// Step 2: Verification
/// Step 3: Security Setup
class AuthStepProgressBar extends StatelessWidget {
  final int currentStep; // 1, 2, or 3

  const AuthStepProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final steps = [
      _StepData(
        stepNumber: 1,
        title: l10nPick(
          context,
          en: 'Account',
          fa: 'حساب',
          ar: 'الحساب',
          zh: '账户',
          tr: 'Hesap',
          ru: 'Аккаунт',
        ),
        subtitle: l10nPick(
          context,
          en: 'Email Info',
          fa: 'اطلاعات ایمیل',
          ar: 'البريد',
          zh: '邮箱信息',
          tr: 'E-posta',
          ru: 'Эл. почта',
        ),
        icon: Icons.alternate_email_rounded,
      ),
      _StepData(
        stepNumber: 2,
        title: l10nPick(
          context,
          en: 'Verify',
          fa: 'تأیید',
          ar: 'التحقق',
          zh: '验证',
          tr: 'Doğrulama',
          ru: 'Проверка',
        ),
        subtitle: l10nPick(
          context,
          en: 'One-Time Code',
          fa: 'کد یک‌بارمصرف',
          ar: 'رمز التحقق',
          zh: '一次性代码',
          tr: 'Doğrulama Kodu',
          ru: 'Код из письма',
        ),
        icon: Icons.mark_email_read_outlined,
      ),
      _StepData(
        stepNumber: 3,
        title: l10nPick(
          context,
          en: 'Security',
          fa: 'امنیت',
          ar: 'الأمان',
          zh: '安全',
          tr: 'Güvenlik',
          ru: 'Безопасность',
        ),
        subtitle: l10nPick(
          context,
          en: 'Password & Terms',
          fa: 'رمز عبور و قوانین',
          ar: 'كلمة المرور والشروط',
          zh: '密码与条款',
          tr: 'Şifre & Koşullar',
          ru: 'Пароль и условия',
        ),
        icon: Icons.shield_outlined,
      ),
    ];

    final activeGradient = LinearGradient(
      colors: isDark
          ? const [AppColors.mainSoftBlue, AppColors.brandViolet]
          : const [AppColors.brandViolet, AppColors.brandVioletDeep],
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.white.withValues(alpha: 0.04)
            : AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildStepNode(
                  context,
                  step: steps[i],
                  isCompleted: steps[i].stepNumber < currentStep,
                  isActive: steps[i].stepNumber == currentStep,
                  isDark: isDark,
                  activeGradient: activeGradient,
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: _buildConnector(
                      isPassed: steps[i].stepNumber < currentStep,
                      isDark: isDark,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(
    BuildContext context, {
    required _StepData step,
    required bool isCompleted,
    required bool isActive,
    required bool isDark,
    required Gradient activeGradient,
  }) {
    Color circleBg;
    Color iconColor;
    Border? border;
    List<BoxShadow>? shadow;

    if (isCompleted) {
      circleBg = AppColors.success;
      iconColor = AppColors.white;
      shadow = [
        BoxShadow(
          color: AppColors.success.withValues(alpha: 0.35),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isActive) {
      circleBg = AppColors.brandViolet;
      iconColor = AppColors.white;
      border = Border.all(
        color: isDark ? AppColors.mainSoftBlue : AppColors.brandVioletDeep,
        width: 2.2,
      );
      shadow = [
        BoxShadow(
          color: AppColors.brandViolet.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      circleBg = isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant;
      iconColor = isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextTertiary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleBg,
            border: border,
            boxShadow: shadow,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, size: 20.sp, color: AppColors.white)
                : Icon(step.icon, size: 18.sp, color: iconColor),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          step.title,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: isActive || isCompleted
                ? FontWeight.w900
                : FontWeight.w600,
            color: isActive
                ? (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                : (isCompleted
                      ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary)
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary)),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          step.subtitle,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                : AppColors.lightTextTertiary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isPassed, required bool isDark}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Container(
        height: 3.h,
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.r),
          color: isPassed
              ? AppColors.brandViolet
              : (isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant),
          gradient: isPassed
              ? const LinearGradient(
                  colors: [AppColors.brandViolet, AppColors.brandVioletDeep],
                )
              : null,
        ),
      ),
    );
  }
}

class _StepData {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepData({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
