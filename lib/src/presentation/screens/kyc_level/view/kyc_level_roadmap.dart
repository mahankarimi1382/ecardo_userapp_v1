import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_labels.dart';

/// KycLevelRoadmap — visual verification roadmap and tier comparison cards
class KycLevelRoadmap extends StatelessWidget {
  final VoidCallback? onLevelTap;

  const KycLevelRoadmap({super.key, this.onLevelTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycLevelController>();
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.warmWhite : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Obx(() {
      if (controller.isLoading.value && controller.levels.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.levels.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single, clean roadmap header with title & crystal clear guidance
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization?.kycRoadmapTitle ??
                      l10nPick(
                        context,
                        en: 'Verification Roadmap',
                        fa: 'سطوح احراز هویت',
                        ar: 'خريطة مستويات التحقق',
                        zh: '认证等级路线',
                      ),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10nPick(
                    context,
                    en: 'Progress through tiers to increase limits and unlock premium banking features.',
                    fa: 'با ارتقای سطح، سقف تراکنش‌ها و امکانات مالی پیشرفته را فعال کنید.',
                    ar: 'ارتقِ بمستواك لزيادة حدود المعاملات وفتح الخدمات المالية المتقدمة.',
                    tr: 'Limitleri artırmak ve gelişmiş finansal hizmetleri açmak için seviyenizi yükseltin.',
                    ru: 'Повышайте уровень для увеличения лимитов и доступа к финансовым сервисам.',
                    zh: '逐步提升等级以提高交易限额并解锁高级金融服务。',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: secondaryTextColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Levels list
          ...controller.levels.map((level) => _LevelCard(
                level: level,
                onTap: onLevelTap,
              )),

          // Upgrade CTA button (if next level is available)
          if (controller.nextLevel != null && !controller.isPending) ...[
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: onLevelTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.lightPrimary,
                    foregroundColor:
                        isDark ? AppColors.deepBlack : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    localization?.kycRoadmapContinueForLevel(
                          controller.nextLevel!.level,
                        ) ??
                        'Continue verification — level ${controller.nextLevel!.level}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Pending review notification
          if (controller.isPending) ...[
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF78350F).withValues(alpha: 0.35)
                    : AppColors.warningContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.warning,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      localization?.kycRoadmapPending ??
                          'Your documents are under review. This usually takes 1–2 business days.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: primaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Rejection notification
          if (controller.isRejected) ...[
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF450A0A).withValues(alpha: 0.35)
                    : AppColors.errorContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _rejectedText(localization, controller),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: primaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Rejection message: server reason when present, localized guidance
  /// otherwise — both halves localized.
  String _rejectedText(
    AppLocalizations? localization,
    KycLevelController controller,
  ) {
    final title = localization?.kycRoadmapRejectedTitle ??
        'Your verification was rejected.';
    final reason = controller.status.value?.rejectionReason;
    if (reason != null && reason.isNotEmpty) return '$title $reason';
    return '$title ${localization?.kycRoadmapRejectedAction ?? "Please resubmit your documents."}';
  }
}

/// A single KYC tier card with clean modern icons, crystal clear descriptions,
/// spec chips, and ripple touch targets >= 44px.
class _LevelCard extends StatelessWidget {
  final KycLevel level;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(level.colorValue);
    final statusColor = _statusColor(level, color);
    final statusIcon = _statusIcon(level);
    final primaryTextColor =
        isDark ? AppColors.warmWhite : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final cardBg = isDark
        ? AppColors.darkSurface
        : (level.isLocked ? AppColors.lightBackground : AppColors.lightSurface);
    final borderColor = isDark
        ? (level.isCurrent
            ? color
            : AppColors.lightWarmGray.withValues(alpha: 0.15))
        : (level.isCurrent ? color : AppColors.lightBorder);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h, left: 18.w, right: 18.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: level.isCurrent ? 2 : 1,
        ),
        boxShadow: !isDark && !level.isLocked
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: level.isAvailable ? onTap : null,
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level status icon badge
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // Level information & crystal clear tier description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            localization?.kycUpgradeLevelChip(level.level) ??
                                'Level ${level.level}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: secondaryTextColor,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusLabel(level, localization),
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        level.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: level.isLocked
                              ? (isDark
                                  ? AppColors.softGray
                                  : AppColors.lightTextHint)
                              : primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      // Crystal clear tier description
                      Text(
                        _tierDescription(context, level),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          height: 1.35,
                          color: secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Feature & Limit Highlight micro-chips
                      _buildTierHighlights(context, isDark, level),

                      // Required docs (for current or available tiers)
                      if ((level.isCurrent || level.isAvailable) &&
                          level.requiredDocs.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 4.w,
                          runSpacing: 4.h,
                          children: level.requiredDocs.map((doc) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: isDark
                                    ? Border.all(
                                        color: AppColors.lightWarmGray
                                            .withValues(alpha: 0.12),
                                      )
                                    : null,
                              ),
                              child: Text(
                                KycDocLabels.label(localization, doc),
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: secondaryTextColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Server-defined dynamic transaction limits
                      if (level.isAvailable && level.limits.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _LimitsSection(
                          localization: localization,
                          level: level,
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Lock icon or chevron indicator
                if (level.isLocked)
                  Icon(
                    Icons.lock_outline_rounded,
                    color:
                        isDark ? AppColors.softGray : AppColors.lightTextHint,
                    size: 18.sp,
                  )
                else if (level.isAvailable)
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: color,
                    size: 22.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Crystal clear, comprehensive tier descriptions
  String _tierDescription(BuildContext context, KycLevel level) {
    if (level.description.trim().length > 25) {
      return level.description.trim();
    }
    return switch (level.level) {
      1 => l10nPick(
          context,
          en: 'Email & phone verified. \$1,000/day limit, 1 virtual card, basic transfers.',
          fa: 'تأیید ایمیل و شماره موبایل. سقف تراکنش روزانه ۱,۰۰۰ دلار، ۱ کارت مجازی و انتقال پایه.',
          ar: 'توثيق الهاتف والبريد. حد يومي 1,000 دولار، بطاقة افتراضية واحدة، تحويلات أساسية.',
          tr: 'E-posta ve telefon doğrulandı. Günlük 1.000 \$ limit, 1 sanal kart, temel transferler.',
          ru: 'Email и телефон подтверждены. Лимит 1 000 \$ в день, 1 карта, базовые переводы.',
          zh: '邮箱与手机认证。每日限额 \$1,000，1 张虚拟卡，基础转账。',
        ),
      2 => l10nPick(
          context,
          en: 'National ID / Passport verified. \$10,000/day limit, 3 virtual cards, currency exchange & travel booking.',
          fa: 'احراز هویت با مدارک شناسایی. سقف روزانه ۱۰,۰۰۰ دلار، ۳ کارت مجازی، تبدیل ارز و رزرو خدمات سفر.',
          ar: 'توثيق الهوية الوطنية أو الجواز. حد يومي 10,000 دولار، 3 بطاقات، صرافة وحجوزات سفر.',
          tr: 'Kimlik veya pasaport doğrulandı. Günlük 10.000 \$ limit, 3 sanal kart, döviz ve seyahat.',
          ru: 'Паспорт или ID-карта. Лимит 10 000 \$ в день, 3 карты, обмен валют и сервисы путешествий.',
          zh: '身份证/护照认证。每日限额 \$10,000，3 张虚拟卡，支持货币兑换与商旅出行。',
        ),
      3 => l10nPick(
          context,
          en: 'Address proof & video liveness. \$100,000 / Unlimited daily limit, unlimited cards, loan access & VIP support.',
          fa: 'تأیید آدرس و اسکن زنده بودن چهره. سقف روزانه تا ۱۰۰,۰۰۰ دلار، کارت‌های نامحدود، تسهیلات و پشتیبانی VIP.',
          ar: 'إثبات العنوان والتحقق الحيوي. حد 100,000 دولار/غير محدود، بطاقات غير محدودة، قروض ودعم VIP.',
          tr: 'Adres ve canlılık doğrulaması. Günlük 100.000 \$ / Sınırsız limit, sınırsız kart, kredi ve VIP destek.',
          ru: 'Подтверждение адреса и биометрии. Лимит до 100 000 \$, безлимитные карты, кредиты и VIP-сервис.',
          zh: '住址证明与活体视频认证。每日最高 \$100,000 限额，无限量虚拟卡，信贷授信与专属客服。',
        ),
      _ => level.description.isNotEmpty
          ? level.description
          : l10nPick(
              context,
              en: 'Commercial verification. Enterprise limits, merchant settlements & dedicated account manager.',
              fa: 'احراز هویت تجاری شرکتی. سقف‌های اختصاصی، درگاه پرداخت و مدیر حساب اختصاصی.',
              ar: 'توثيق الشركات والمؤسسات. حدود مؤسسية مخصصة، تسويات تجارية ومدير حساب مخصص.',
              tr: 'Kurumsal doğrulama. Özel limitler, üye işyeri posu ve özel hesap yöneticisi.',
              ru: 'Корпоративная верификация. Индивидуальные лимиты, эквайринг и персональный менеджер.',
              zh: '企业资质认证。专属定制限额，商户结算通道与专属客户经理。',
            ),
    };
  }

  /// Compact highlight badges for immediate tier comparison
  Widget _buildTierHighlights(
    BuildContext context,
    bool isDark,
    KycLevel level,
  ) {
    final chipBg =
        isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9);
    final borderCol = isDark
        ? AppColors.lightWarmGray.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    final (limitText, cardText, featureText) = switch (level.level) {
      1 => (
          '\$1,000 / day',
          l10nPick(
            context,
            en: '1 Card',
            fa: '۱ کارت',
            ar: 'بطاقة 1',
            zh: '1张卡',
          ),
          l10nPick(
            context,
            en: 'Transfers',
            fa: 'انتقال پایه',
            ar: 'تحويلات',
            zh: '转账',
          ),
        ),
      2 => (
          '\$10,000 / day',
          l10nPick(
            context,
            en: '3 Cards',
            fa: '۳ کارت',
            ar: '3 بطاقات',
            zh: '3张卡',
          ),
          l10nPick(
            context,
            en: 'Travel & FX',
            fa: 'صرافی و سفر',
            ar: 'سفر وصرافة',
            zh: '商旅兑换',
          ),
        ),
      3 => (
          '\$100,000 / day',
          l10nPick(
            context,
            en: 'Unlimited Cards',
            fa: 'کارت نامحدود',
            ar: 'بطاقات غير محدودة',
            zh: '无限卡',
          ),
          l10nPick(
            context,
            en: 'Loans & VIP',
            fa: 'وام و VIP',
            ar: 'قروض وVIP',
            zh: '信贷VIP',
          ),
        ),
      _ => (
          'Custom Limits',
          l10nPick(
            context,
            en: 'Corporate',
            fa: 'شرکتی',
            ar: 'شركات',
            zh: '企业卡',
          ),
          l10nPick(
            context,
            en: 'Merchant Facilities',
            fa: 'امکانات تجاری',
            ar: 'بوابات تجارية',
            zh: '商户设施',
          ),
        ),
    };

    Widget microChip(IconData icon, String text) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderCol, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.sp, color: Color(level.colorValue)),
            SizedBox(width: 4.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: [
        microChip(Icons.payments_outlined, limitText),
        microChip(Icons.credit_card_outlined, cardText),
        microChip(Icons.stars_outlined, featureText),
      ],
    );
  }

  Color _statusColor(KycLevel level, Color levelColor) {
    if (level.isCompleted) return AppColors.success;
    if (level.isCurrent) return levelColor;
    if (level.isAvailable) return AppColors.info;
    return AppColors.lightTextHint;
  }

  IconData _statusIcon(KycLevel level) {
    if (level.isCompleted) return Icons.check_circle_rounded;
    if (level.isCurrent) return Icons.play_circle_rounded;
    if (level.isAvailable) return Icons.lock_open_rounded;
    return Icons.lock_rounded;
  }

  String _statusLabel(KycLevel level, AppLocalizations? localization) {
    if (level.isCompleted) {
      return localization?.kycRoadmapStatusCompleted ?? 'Completed';
    }
    if (level.isCurrent) {
      return localization?.kycRoadmapStatusCurrent ?? 'Current';
    }
    if (level.isAvailable) {
      return localization?.kycRoadmapStatusAvailable ?? 'Ready to upgrade';
    }
    return localization?.kycRoadmapStatusLocked ?? 'Locked';
  }
}

/// Per-level limits section
class _LimitsSection extends StatelessWidget {
  final AppLocalizations? localization;
  final KycLevel level;
  final bool isDark;

  const _LimitsSection({
    required this.localization,
    required this.level,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final rows = KycLimitLabels.rows(localization, level.limits);
    if (rows.isEmpty) return const SizedBox.shrink();

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final chipBg = isDark ? AppColors.darkSurface : AppColors.white;
    final chipBorder = isDark
        ? AppColors.lightWarmGray.withValues(alpha: 0.12)
        : AppColors.lightBorder;
    final primaryTextColor =
        isDark ? AppColors.warmWhite : AppColors.lightTextPrimary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization?.kycLimitsSectionTitle ?? 'Transaction limits',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: rows
                .map(
                  (row) => Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: chipBorder),
                    ),
                    child: Text(
                      row.measureLabel == null
                          ? '${row.groupLabel}: ${row.value}'
                          : '${row.groupLabel} — ${row.measureLabel}: ${row.value}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
