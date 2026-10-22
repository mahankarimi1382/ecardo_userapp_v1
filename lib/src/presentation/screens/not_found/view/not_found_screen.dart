import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Modern 404 Screen — shown when an unknown route is accessed.
///
/// Adopts [EcardoEmptyState] with a themed 404/lost illustration,
/// dark mode support via semantic [AppColors], and a tactile "Back to Home" CTA.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final loc = AppLocalizations.of(context);

    final title = l10nPick(
      context,
      en: '404 - Page Not Found',
      fa: '۴۰۴ - صفحه یافت نشد',
      ar: '٤٠٤ - الصفحة غير موجودة',
      tr: '404 - Sayfa Bulunamadı',
      ru: '404 - Страница не найдена',
      zh: '404 - 找不到页面',
    );

    final description =
        loc?.allControllerLoadError ??
        l10nPick(
          context,
          en: 'This screen is not available or has been moved. Return to the home screen to continue.',
          fa: 'این صفحه در دسترس نیست یا منتقل شده است. برای ادامه به صفحه اصلی بازگردید.',
          ar: 'هذه الشاشة غير متوفرة أو تم نقلها. يرجى العودة إلى الصفحة الرئيسية للمتابعة.',
          tr: 'Bu ekran mevcut değil veya taşınmış. Devam etmek için ana sayfaya dönün.',
          ru: 'Этот экран недоступен или был перемещен. Вернитесь на главный экран, чтобы продолжить.',
          zh: '该页面不可用或已被移除。返回首页以继续。',
        );

    final backHomeLabel =
        loc?.addMoneySuccessBackHome ??
        l10nPick(
          context,
          en: 'Back to Home',
          fa: 'بازگشت به خانه',
          ar: 'العودة للرئيسية',
          tr: 'Ana Sayfaya Dön',
          ru: 'На главную',
          zh: '返回首页',
        );

    final canPop = Get.key.currentState?.canPop() == true;
    final secondaryLabel = canPop
        ? (loc?.updateGoBack ??
              l10nPick(
                context,
                en: 'Go Back',
                fa: 'بازگشت',
                ar: 'رجوع',
                tr: 'Geri Dön',
                ru: 'Назад',
                zh: '返回',
              ))
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: EcardoEmptyState(
              title: title,
              description: description,
              glowColor: isDark
                  ? AppColors.mainSoftBlue
                  : AppColors.brandViolet,
              customIllustration: _NotFoundIllustration(isDark: isDark),
              primaryActionLabel: backHomeLabel,
              onPrimaryAction: () {
                HapticFeedback.lightImpact();
                Get.offAllNamed(BaseRoute.navigation);
              },
              secondaryActionLabel: secondaryLabel,
              onSecondaryAction: canPop
                  ? () {
                      HapticFeedback.lightImpact();
                      Get.back();
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Themed 404 / lost radar illustration with glowing orbital rings and a floating 404 tag.
class _NotFoundIllustration extends StatelessWidget {
  final bool isDark;

  const _NotFoundIllustration({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Outer ambient glow aura
          Container(
            width: 136,
            height: 136,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: isDark ? 0.28 : 0.16),
                  accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                  AppColors.transparent,
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
            ),
          ),

          // Middle orbital boundary ring
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.50)
                  : AppColors.brandVioletContainer.withValues(alpha: 0.50),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
          ),

          // Inner solid icon pedestal
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkCard : AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(
                    alpha: isDark ? 0.40 : 0.08,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.explore_off_rounded,
                size: 38,
                color: accentColor,
              ),
            ),
          ),

          // Floating "404" neon pill badge
          Positioned(
            bottom: 4,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3.5,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandViolet.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                '404',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                  letterSpacing: 0.8,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
