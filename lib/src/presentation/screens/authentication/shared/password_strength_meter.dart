import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Real-time animated password strength indicator with checklist requirements
/// (Length 8+, Number, Letter, Special character) and strength score.
class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  final String? confirmPassword;

  const PasswordStrengthMeter({
    super.key,
    required this.password,
    this.confirmPassword,
  });

  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get hasLetter => RegExp(r'[a-zA-Z]').hasMatch(password);
  bool get hasSpecialChar =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\\/\[\]~`]').hasMatch(password);

  int get strengthScore {
    if (password.isEmpty) return 0;
    int score = 0;
    if (hasMinLength) score++;
    if (hasNumber) score++;
    if (hasLetter) score++;
    if (hasSpecialChar) score++;
    return score;
  }

  String _strengthLabel(BuildContext context, int score) {
    if (score == 0) return '';
    if (score <= 1) {
      return l10nPick(
        context,
        en: 'Weak',
        fa: 'ضعیف',
        ar: 'ضعيف',
        zh: '弱',
        tr: 'Zayıf',
        ru: 'Слабый',
      );
    }
    if (score <= 3) {
      return l10nPick(
        context,
        en: 'Medium',
        fa: 'متوسط',
        ar: 'متوسط',
        zh: '中等',
        tr: 'Orta',
        ru: 'Средний',
      );
    }
    return l10nPick(
      context,
      en: 'Strong',
      fa: 'قوی',
      ar: 'قوي',
      zh: '强',
      tr: 'Güçlü',
      ru: 'Надёжный',
    );
  }

  Color _strengthColor(int score) {
    if (score == 0) return Colors.transparent;
    if (score <= 1) return const Color(0xFFEF4444); // Weak - Red
    if (score <= 3) return const Color(0xFFF59E0B); // Medium - Amber
    return const Color(0xFF10B981); // Strong - Emerald
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = strengthScore;
    final color = _strengthColor(score);
    final label = _strengthLabel(context, score);

    final showConfirmMatch =
        confirmPassword != null && confirmPassword!.isNotEmpty;
    final isMatch = password.isNotEmpty && password == confirmPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top strength bar row
        if (password.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Security Level:',
                  fa: 'سطح امنیت:',
                  ar: 'مستوى الأمان:',
                  zh: '安全级别:',
                  tr: 'Güvenlik Seviyesi:',
                  ru: 'Уровень надёжности:',
                ),
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextTertiary,
                ),
              ),
              const Spacer(),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
                child: Text(label),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // 4-segment progress bar
          Row(
            children: [
              for (int i = 1; i <= 4; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      color: i <= score
                          ? color
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFE2E8F0)),
                      boxShadow: i <= score
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
        ],

        // 4 requirement checkmarks grid
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            _buildCheckmarkChip(
              context,
              label: l10nPick(
                context,
                en: '8+ chars',
                fa: 'حداقل ۸ حرف',
                ar: '٨+ أحرف',
                zh: '8位以上',
                tr: '8+ karakter',
                ru: '8+ симв.',
              ),
              isMet: hasMinLength,
              isDark: isDark,
            ),
            _buildCheckmarkChip(
              context,
              label: l10nPick(
                context,
                en: 'Number (0-9)',
                fa: 'شامل عدد',
                ar: 'أرقام (0-9)',
                zh: '包含数字',
                tr: 'Rakam (0-9)',
                ru: 'Цифра (0-9)',
              ),
              isMet: hasNumber,
              isDark: isDark,
            ),
            _buildCheckmarkChip(
              context,
              label: l10nPick(
                context,
                en: 'Letter (A-Z)',
                fa: 'شامل حروف',
                ar: 'حروف (A-Z)',
                zh: '包含字母',
                tr: 'Harf (A-Z)',
                ru: 'Буква (A-Z)',
              ),
              isMet: hasLetter,
              isDark: isDark,
            ),
            _buildCheckmarkChip(
              context,
              label: l10nPick(
                context,
                en: 'Special (@#\$)',
                fa: 'نماد خاص',
                ar: 'رمز خاص (@#\$)',
                zh: '特殊符号',
                tr: 'Özel karakter',
                ru: 'Спецсимвол',
              ),
              isMet: hasSpecialChar,
              isDark: isDark,
            ),
          ],
        ),

        // Confirm password match feedback
        if (showConfirmMatch) ...[
          SizedBox(height: 8.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isMatch
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isMatch
                    ? const Color(0xFF10B981).withValues(alpha: 0.40)
                    : const Color(0xFFEF4444).withValues(alpha: 0.40),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 14.sp,
                  color:
                      isMatch ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
                SizedBox(width: 6.w),
                Text(
                  isMatch
                      ? l10nPick(
                          context,
                          en: 'Passwords match',
                          fa: 'رمزهای عبور مطابقت دارند',
                          ar: 'كلمتا المرور متطابقتان',
                          zh: '密码匹配',
                          tr: 'Şifreler eşleşiyor',
                          ru: 'Пароли совпадают',
                        )
                      : l10nPick(
                          context,
                          en: 'Passwords do not match',
                          fa: 'رمزهای عبور مطابقت ندارند',
                          ar: 'كلمتا المرور غير متطابقتين',
                          zh: '密码不匹配',
                          tr: 'Şifreler uyuşmuyor',
                          ru: 'Пароли не совпадают',
                        ),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isMatch
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckmarkChip(
    BuildContext context, {
    required String label,
    required bool isMet,
    required bool isDark,
  }) {
    final chipBg = isMet
        ? const Color(0xFF10B981).withValues(alpha: 0.12)
        : (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F5F9));
    final chipBorder = isMet
        ? const Color(0xFF10B981).withValues(alpha: 0.40)
        : (isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0));
    final textColor = isMet
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
        : (isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextTertiary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: chipBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
            size: 13.sp,
            color: isMet ? const Color(0xFF10B981) : textColor,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isMet ? FontWeight.w800 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
