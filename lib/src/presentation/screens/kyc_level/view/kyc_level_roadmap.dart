import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_labels.dart';

/// KycLevelRoadmap — Visual verification roadmap and tier progression stepper.
///
/// Elevated to modern fintech standards (Onfido, Sumsub, Stripe Identity):
///   - Tier 1 (Basic / شماره تماس): $1,000/day limit, 1 Virtual Card, Basic Transfers.
///   - Tier 2 (ID Document / کارت ملی و شناسنامه): $10,000/day limit, 3 Virtual Cards, P2P Trading access, FX & Travel.
///   - Tier 3 (Selfie Video & Address / احراز ویدیویی): $100,000/Unlimited limit, Unlimited Virtual Cards, Loans & VIP Concierge.
///
/// Visual Features:
///   - Horizontal progression stepper with connected progress bar showing unlocked milestones.
///   - Status indicators: Verified (emerald green with shield), Pending Review (amber with clock/pulse),
///     Rejected (crimson with explanation reason and "Retry Verification" CTA).
///   - Full Dark mode and RTL support with AppColors, AppSpacing, and l10nPick.
class KycLevelRoadmap extends StatefulWidget {
  final VoidCallback? onLevelTap;

  const KycLevelRoadmap({super.key, this.onLevelTap});

  @override
  State<KycLevelRoadmap> createState() => _KycLevelRoadmapState();
}

class _KycLevelRoadmapState extends State<KycLevelRoadmap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _shouldReduceMotion(BuildContext context) {
    return (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ||
        (WidgetsBinding.instance is! WidgetsFlutterBinding);
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldReduceMotion(context)) {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
      _pulseController.value = 1.0;
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleRetry(KycLevelController controller) {
    HapticFeedback.mediumImpact();
    if (widget.onLevelTap != null) {
      widget.onLevelTap!();
    } else {
      final target = controller.nextLevel?.level ??
          (controller.status.value?.currentLevel ?? 2);
      Get.toNamed(
        BaseRoute.kycSubmitWizard,
        arguments: {'target_level': target},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycLevelController>();
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Obx(() {
      if (controller.isLoading.value && controller.levels.isEmpty) {
        return _buildLoadingSkeleton(isDark);
      }

      if (controller.levels.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: EcardoEmptyState(
            animateGlow: false,
            iconData: Icons.verified_user_outlined,
            title: localization?.kycRoadmapTitle ??
                l10nPick(
                  context,
                  en: 'Verification Roadmap',
                  fa: 'سطوح احراز هویت',
                  ar: 'خريطة التحقق',
                  zh: '认证等级路线',
                ),
            description: l10nPick(
              context,
              en: 'No verification tiers available at the moment.',
              fa: 'در حال حاضر اطلاعات سطوح احراز هویت در دسترس نیست.',
              ar: 'لا توجد مستويات تحقق متاحة حالياً.',
              zh: '当前暂无可用的认证等级。',
            ),
            primaryActionLabel: l10nPick(context, en: 'Retry', fa: 'تلاش مجدد'),
            onPrimaryAction: () => controller.fetchStatus(),
          ),
        );
      }

      final levelsList = controller.levels.toList();
      final currentLevel = controller.currentLevel;
      final isPending = controller.isPending;
      final isRejected = controller.isRejected;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localization?.kycRoadmapTitle ??
                                l10nPick(
                                  context,
                                  en: 'Verification Roadmap & Tiers',
                                  fa: 'مسیر و سطوح احراز هویت',
                                  ar: 'مستويات وخريطة التحقق',
                                  zh: '身份认证等级路线',
                                ),
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Upgrade tiers to unlock higher limits and premium banking.',
                              fa: 'با ارتقای هر سطح، سقف تراکنش‌ها و امکانات مالی جدید فعال می‌شوند.',
                              ar: 'ارتقِ بمستواك لزيادة الحدود وفتح الخدمات المالية.',
                              zh: '升级认证等级以提高额度并解锁高级金融功能。',
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: secondaryTextColor,
                              fontSize: 11.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Visual Progress Stepper across Tier 1, Tier 2, Tier 3
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return _KycProgressionHeader(
                currentLevel: currentLevel,
                isPending: isPending,
                isRejected: isRejected,
                pulseFactor: _pulseAnimation.value,
                isDark: isDark,
              );
            },
          ),
          SizedBox(height: AppSpacing.md),

          // Prominent Status Banner (Verified / Pending Review / Rejected)
          if (isRejected) ...[
            _buildRejectedBanner(context, isDark, controller),
            SizedBox(height: AppSpacing.md),
          ] else if (isPending) ...[
            _buildPendingBanner(context, isDark),
            SizedBox(height: AppSpacing.md),
          ] else if (currentLevel >= 1) ...[
            _buildVerifiedBanner(context, isDark, currentLevel),
            SizedBox(height: AppSpacing.md),
          ],

          // Stepper Level Cards
          ...List.generate(levelsList.length, (index) {
            final level = levelsList[index];
            final isLast = index == levelsList.length - 1;
            return _StepperLevelCard(
              level: level,
              isLast: isLast,
              isUserPending: isPending,
              isUserRejected: isRejected,
              onTap: widget.onLevelTap,
            );
          }),

          // Upgrade CTA button (if next level is available and not pending)
          if (controller.nextLevel != null && !isPending && !isRejected) ...[
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (widget.onLevelTap != null) {
                      widget.onLevelTap!();
                    } else {
                      Get.toNamed(
                        BaseRoute.kycSubmitWizard,
                        arguments: {'target_level': controller.nextLevel!.level},
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    foregroundColor:
                        isDark ? AppColors.deepBlack : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  label: Text(
                    localization?.kycRoadmapContinueForLevel(
                          controller.nextLevel!.level,
                        ) ??
                        'Continue verification — level ${controller.nextLevel!.level}',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.deepBlack : AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Crimson Banner for Rejected submissions with reason and CTA
  Widget _buildRejectedBanner(
    BuildContext context,
    bool isDark,
    KycLevelController controller,
  ) {
    final reason = controller.status.value?.rejectionReason ??
        controller.rejectionData.value?.message ??
        l10nPick(
          context,
          en: 'Document verification failed. Please check your photos and resubmit.',
          fa: 'مدارک ارسالی تأیید نشد. لطفاً وضوح و گوشه‌های مدرک را بررسی کرده و مجدداً ارسال کنید.',
          ar: 'فشل التحقق من المستندات. يرجى التأكد من وضوح الصور وإعادة الإرسال.',
          zh: '文件验证未通过。请检查照片清晰度并重新提交。',
        );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.errorContainer.withValues(alpha: 0.2)
            : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Verification Rejected',
                        fa: 'احراز هویت رد شده است',
                        ar: 'تم رفض التحقق',
                        zh: '认证已拒绝',
                      ),
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      reason,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () => _handleRetry(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                l10nPick(
                  context,
                  en: 'Retry Verification',
                  fa: 'تلاش مجدد احراز هویت',
                  ar: 'إعادة المحاولة',
                  zh: '重新提交认证',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Amber Banner for Pending Review submissions with clock icon
  Widget _buildPendingBanner(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warningContainer.withValues(alpha: 0.2)
            : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.warning,
              size: 20.sp,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(
                    context,
                    en: 'Under Review',
                    fa: 'مدارک در انتظار بررسی',
                    ar: 'قيد المراجعة',
                    zh: '资料审核中',
                  ),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10nPick(
                    context,
                    en: 'Your documents have been submitted and are being verified. Review typically takes 1–2 business days.',
                    fa: 'مدارک شما با موفقیت ارسال شد و در صف اعتبارسنجی قرار دارد. بررسی معمولاً ۱ تا ۲ روز کاری زمان می‌برد.',
                    ar: 'تم إرسال مستنداتك وهي قيد المراجعة. تستغرق المراجعة عادةً من يوم إلى يومي عمل.',
                    zh: '您的资料已提交，目前正在人工审核中。通常需 1–2 个工作日。',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Emerald Green Banner for Verified accounts
  Widget _buildVerifiedBanner(
    BuildContext context,
    bool isDark,
    int currentLevel,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.successContainer.withValues(alpha: 0.2)
            : AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              color: AppColors.success,
              size: 20.sp,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Tier $currentLevel Verified',
                        fa: 'سطح $currentLevel تأیید شده',
                        ar: 'المستوى $currentLevel موثق',
                        zh: '第 $currentLevel 级已认证',
                      ),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        l10nPick(context, en: 'ACTIVE', fa: 'فعال'),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  l10nPick(
                    context,
                    en: 'All benefits and limits for this level are fully unlocked.',
                    fa: 'تمام سقف‌های تراکنش و خدمات مالی این سطح فعال می‌باشند.',
                    ar: 'جميع مزايا وحدود هذا المستوى مفعلة بالكامل.',
                    zh: '该等级的所有限额与权益均已生效。',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
          height: 120.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal Stepper Header with Visual Progress Bar and Benefits Milestones
class _KycProgressionHeader extends StatelessWidget {
  final int currentLevel;
  final bool isPending;
  final bool isRejected;
  final double pulseFactor;
  final bool isDark;

  const _KycProgressionHeader({
    required this.currentLevel,
    required this.isPending,
    required this.isRejected,
    required this.pulseFactor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    // Progress calculation across 3 tiers (0, 33%, 66%, 100%)
    final progressFraction = (currentLevel / 3.0).clamp(0.0, 1.0);
    final percentInt = (progressFraction * 100).toInt();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Progression percentage & level badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Verification Progress',
                  fa: 'پیشرفت احراز هویت',
                  ar: 'تقدم التحقق',
                  zh: '认证进度',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '$percentInt% ${l10nPick(context, en: 'Completed', fa: 'تکمیل شده')}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    fontSize: 10.5.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Visual Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 8.h,
                  color: isDark ? AppColors.darkBackground : AppColors.lightOutlineVariant,
                ),
                FractionallySizedBox(
                  widthFactor: progressFraction,
                  child: Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.brandViolet,
                          AppColors.success,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Connected 3-Step Nodes: Tier 1, Tier 2, Tier 3
          Row(
            children: [
              _buildStepNode(
                context: context,
                tier: 1,
                titleFa: 'شماره تماس',
                titleEn: 'Basic',
                subtitleFa: 'ایمیل و موبایل',
                subtitleEn: 'Phone & Email',
              ),
              _buildStepConnector(tierFrom: 1),
              _buildStepNode(
                context: context,
                tier: 2,
                titleFa: 'کارت ملی و شناسنامه',
                titleEn: 'ID Document',
                subtitleFa: 'مدارک هویتی',
                subtitleEn: 'National ID',
              ),
              _buildStepConnector(tierFrom: 2),
              _buildStepNode(
                context: context,
                tier: 3,
                titleFa: 'احراز ویدیویی',
                titleEn: 'Selfie Video',
                subtitleFa: 'اسکن زنده و آدرس',
                subtitleEn: 'Liveness & Address',
              ),
            ],
          ),
          SizedBox(height: 14.h),

          const Divider(height: 1),
          SizedBox(height: 12.h),

          // Unlocked Benefits Summary Strip
          Text(
            l10nPick(
              context,
              en: 'Benefits Unlocked by Level',
              fa: 'امکانات بازگشایی‌شده بر اساس سطح',
              ar: 'المزايا المتاحة حسب المستوى',
              zh: '各等级解锁权益对比',
            ),
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: secondaryTextColor,
            ),
          ),
          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                child: _buildBenefitPill(
                  icon: Icons.payments_outlined,
                  title: l10nPick(context, en: 'Daily Limit', fa: 'سقف روزانه'),
                  value: currentLevel >= 3
                      ? '\$100,000 / نامحدود'
                      : (currentLevel == 2 ? '\$10,000' : '\$1,000'),
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildBenefitPill(
                  icon: Icons.credit_card_outlined,
                  title: l10nPick(context, en: 'Virtual Cards', fa: 'کارت مجازی'),
                  value: currentLevel >= 3
                      ? l10nPick(context, en: 'Unlimited', fa: 'نامحدود')
                      : (currentLevel == 2 ? '۳ کارت' : '۱ کارت'),
                  color: AppColors.brandViolet,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildBenefitPill(
                  icon: Icons.swap_horiz_rounded,
                  title: l10nPick(context, en: 'P2P Trading', fa: 'معاملات P2P'),
                  value: currentLevel >= 2
                      ? l10nPick(context, en: 'Unlocked', fa: 'فعال')
                      : l10nPick(context, en: 'Locked', fa: 'قفل'),
                  color: currentLevel >= 2
                      ? AppColors.mutedBlue
                      : AppColors.softGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required int tierFrom}) {
    final isPassed = currentLevel > tierFrom;
    return Expanded(
      child: Container(
        height: 2.5.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: isPassed
              ? AppColors.success
              : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildStepNode({
    required BuildContext context,
    required int tier,
    required String titleFa,
    required String titleEn,
    required String subtitleFa,
    required String subtitleEn,
  }) {
    final isVerified = currentLevel >= tier && !isRejected;
    final isCurrent = currentLevel == tier;
    final isNext = currentLevel == tier - 1;

    // Status colors & icons
    Color nodeColor;
    IconData nodeIcon;

    if (isVerified) {
      nodeColor = AppColors.success; // Emerald green with shield
      nodeIcon = Icons.shield_rounded;
    } else if (isNext && isPending) {
      nodeColor = AppColors.warning; // Amber with clock/pulse
      nodeIcon = Icons.hourglass_top_rounded;
    } else if (isNext && isRejected) {
      nodeColor = AppColors.error; // Crimson
      nodeIcon = Icons.error_outline_rounded;
    } else if (isNext) {
      nodeColor = isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary;
      nodeIcon = Icons.arrow_upward_rounded;
    } else {
      nodeColor = isDark ? AppColors.softGray : AppColors.lightTextHint;
      nodeIcon = Icons.lock_outline_rounded;
    }

    final isPulsing = isNext && isPending;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: nodeColor.withValues(
              alpha: isPulsing ? 0.25 * pulseFactor : 0.15,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: nodeColor,
              width: (isCurrent || isPulsing) ? 2.5 : 1.5,
            ),
            boxShadow: isVerified
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : (isPulsing
                    ? [
                        BoxShadow(
                          color: AppColors.warning.withValues(
                            alpha: 0.45 * pulseFactor,
                          ),
                          blurRadius: 10 * pulseFactor,
                          spreadRadius: 1.5,
                        ),
                      ]
                    : null),
          ),
          child: Icon(
            nodeIcon,
            color: nodeColor,
            size: 18.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          l10nPick(context, en: 'Tier $tier', fa: 'سطح $tier'),
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 10.sp,
            color: nodeColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          l10nPick(context, en: titleEn, fa: titleFa),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBenefitPill({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: color),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 8.5.sp,
                    color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A single KYC tier card connected with visual stepper lines and rich benefit chips
class _StepperLevelCard extends StatelessWidget {
  final KycLevel level;
  final bool isLast;
  final bool isUserPending;
  final bool isUserRejected;
  final VoidCallback? onTap;

  const _StepperLevelCard({
    required this.level,
    required this.isLast,
    required this.isUserPending,
    required this.isUserRejected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(level.colorValue);
    final statusColor = _statusColor(level, color);
    final statusIcon = _statusIcon(level);
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final cardBg = isDark
        ? AppColors.darkSurface
        : (level.isLocked ? AppColors.lightBackground : AppColors.lightSurface);
    final borderColor = isDark
        ? (level.isCurrent ? color : AppColors.darkBorder)
        : (level.isCurrent ? color : AppColors.lightBorder);

    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Stepper Column: Step Circle + Connecting Line
            Column(
              children: [
                // Step Indicator Node
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor,
                      width: level.isCurrent ? 2.5 : 1.5,
                    ),
                    boxShadow: level.isCurrent
                        ? [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 18.sp,
                  ),
                ),
                // Stepper Line to next step
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: level.isCompleted
                          ? AppColors.success.withValues(alpha: 0.6)
                          : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    ),
                  ),
              ],
            ),
            SizedBox(width: AppSpacing.md),

            // Main Tier Information Card
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                constraints: const BoxConstraints(minHeight: 44.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: borderColor,
                    width: level.isCurrent ? 2 : 1,
                  ),
                  boxShadow: !isDark && !level.isLocked
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    onTap: level.isAvailable && !isUserPending
                        ? () {
                            HapticFeedback.lightImpact();
                            if (onTap != null) {
                              onTap!();
                            } else {
                              Get.toNamed(
                                BaseRoute.kycSubmitWizard,
                                arguments: {'target_level': level.level},
                              );
                            }
                          }
                        : null,
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level Chip & Status Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6.w,
                                children: [
                                  Text(
                                    localization?.kycUpgradeLevelChip(level.level) ??
                                        'Level ${level.level}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    ),
                                    child: Text(
                                      _statusLabel(level, localization),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w800,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (level.isLocked)
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: isDark ? AppColors.softGray : AppColors.lightTextHint,
                                  size: 16.sp,
                                )
                              else if (level.isAvailable)
                                Icon(
                                  Directionality.of(context) == TextDirection.rtl
                                      ? Icons.chevron_left_rounded
                                      : Icons.chevron_right_rounded,
                                  color: color,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),

                          // Tier Name
                          Text(
                            _tierTitle(context, level),
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: level.isLocked
                                  ? (isDark ? AppColors.softGray : AppColors.lightTextHint)
                                  : primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),

                          // Tier Description
                          Text(
                            _tierDescription(context, level),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: secondaryTextColor,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),

                          // Benefits unlocked micro-chips (Daily Limit, Cards, P2P, etc.)
                          _buildTierHighlights(context, isDark, level),

                          // Required docs
                          if ((level.isCurrent || level.isAvailable) &&
                              level.requiredDocs.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.sm),
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
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    KycDocLabels.label(localization, doc),
                                    style: AppTextStyles.labelSmall.copyWith(
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
                            SizedBox(height: AppSpacing.sm),
                            _LimitsSection(
                              localization: localization,
                              level: level,
                              isDark: isDark,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tierTitle(BuildContext context, KycLevel level) {
    if (level.name.isNotEmpty) return level.name;
    return switch (level.level) {
      1 => l10nPick(
          context,
          en: 'Tier 1 — Basic',
          fa: 'سطح ۱ — پایه (شماره تماس و ایمیل)',
          ar: 'المستوى 1 — الأساسي (الهاتف والبريد)',
          zh: '第 1 级 — 基础认证 (手机与邮箱)',
        ),
      2 => l10nPick(
          context,
          en: 'Tier 2 — Standard',
          fa: 'سطح ۲ — استاندارد (کارت ملی و شناسنامه)',
          ar: 'المستوى 2 — المعياري (الهوية وجواز السفر)',
          zh: '第 2 级 — 标准认证 (身份证与护照)',
        ),
      3 => l10nPick(
          context,
          en: 'Tier 3 — VIP',
          fa: 'سطح ۳ — طلایی (احراز ویدیویی و نشانی)',
          ar: 'المستوى 3 — الذهبي (الفيديو والعنوان)',
          zh: '第 3 级 — 尊享认证 (视频活体与地址)',
        ),
      _ => 'Level ${level.level}',
    };
  }

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
          zh: '邮箱与手机认证。每日限额 \$1,000，1 张虚拟卡，基础转账。',
        ),
      2 => l10nPick(
          context,
          en: 'National ID / Passport verified. \$10,000/day limit, 3 virtual cards, P2P trading access & travel booking.',
          fa: 'احراز با کارت ملی و شناسنامه. سقف روزانه ۱۰,۰۰۰ دلار، ۳ کارت مجازی، دسترسی به معاملات P2P و رزرو سفر.',
          ar: 'توثيق الهوية الوطنية أو الجواز. حد 10,000 دولار، 3 بطاقات، تداول P2P وحجوزات سفر.',
          zh: '身份证/护照认证。每日限额 \$10,000，3 张虚拟卡，P2P 交易与商旅兑换。',
        ),
      3 => l10nPick(
          context,
          en: 'Address proof & video liveness. \$100,000 / Unlimited daily limit, unlimited cards, loan access & VIP concierge.',
          fa: 'تأیید آدرس و اسکن ویدیویی چهره. سقف روزانه تا ۱۰۰,۰۰۰ دلار/نامحدود، کارت‌های نامحدود، تسهیلات و پشتیبانی VIP.',
          ar: 'إثبات العنوان والتحقق الحيوي. حد 100,000 دولار/غير محدود، بطاقات غير محدودة، قروض ودعم VIP.',
          zh: '住址证明与活体视频认证。每日最高 \$100,000 限额，无限量虚拟卡，信贷与专属客服。',
        ),
      _ => level.description.isNotEmpty
          ? level.description
          : l10nPick(
              context,
              en: 'Commercial verification. Enterprise limits, merchant settlements & dedicated account manager.',
              fa: 'احراز هویت تجاری شرکتی. سقف‌های اختصاصی، درگاه پرداخت و مدیر حساب اختصاصی.',
              ar: 'توثيق الشركات والمؤسسات. حدود مؤسسية مخصصة، تسويات تجارية ومدير حساب مخصص.',
              zh: '企业资质认证。专属定制限额，商户结算通道与专属客户经理。',
            ),
    };
  }

  Widget _buildTierHighlights(
    BuildContext context,
    bool isDark,
    KycLevel level,
  ) {
    final chipBg = isDark ? AppColors.darkBackground : AppColors.lightSurfaceVariant;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    final (limitText, cardText, featureText) = switch (level.level) {
      1 => (
          '\$1,000 / day',
          l10nPick(context, en: '1 Card', fa: '۱ کارت', ar: 'بطاقة 1', zh: '1张卡'),
          l10nPick(context, en: 'Transfers', fa: 'انتقال پایه', ar: 'تحويلات', zh: '转账'),
        ),
      2 => (
          '\$10,000 / day',
          l10nPick(context, en: '3 Cards', fa: '۳ کارت', ar: '3 بطاقات', zh: '3张卡'),
          l10nPick(context, en: 'P2P & FX', fa: 'معاملات P2P و صرافی', ar: 'تداول P2P وصرافة', zh: 'P2P交易与兑换'),
        ),
      3 => (
          '\$100,000 / day',
          l10nPick(context, en: 'Unlimited Cards', fa: 'کارت نامحدود', ar: 'بطاقات غير محدودة', zh: '无限卡'),
          l10nPick(context, en: 'Loans & VIP', fa: 'تسهیلات و VIP', ar: 'قروض وVIP', zh: '信贷与VIP'),
        ),
      _ => (
          'Custom Limits',
          l10nPick(context, en: 'Corporate', fa: 'شرکتی', ar: 'شركات', zh: '企业卡'),
          l10nPick(context, en: 'Facilities', fa: 'امکانات تجاری', ar: 'بوابات تجارية', zh: '商户设施'),
        ),
    };

    Widget microChip(IconData icon, String text) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          border: Border.all(color: borderCol, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.sp, color: Color(level.colorValue)),
            SizedBox(width: 4.w),
            Text(
              text,
              style: AppTextStyles.labelSmall.copyWith(
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
    if (level.isCompleted) return Icons.verified_user_rounded;
    if (level.isCurrent) return Icons.play_circle_rounded;
    if (level.isAvailable) return Icons.lock_open_rounded;
    return Icons.lock_rounded;
  }

  String _statusLabel(KycLevel level, AppLocalizations? localization) {
    if (level.isCompleted) {
      return localization?.kycRoadmapStatusCompleted ?? 'Verified';
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
    final chipBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization?.kycLimitsSectionTitle ?? 'Transaction limits',
            style: AppTextStyles.labelSmall.copyWith(
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
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      border: Border.all(color: chipBorder, width: 0.8),
                    ),
                    child: Text(
                      '${row.groupLabel}${row.measureLabel != null ? ' (${row.measureLabel})' : ''}: ${row.value}',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 9.sp,
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
