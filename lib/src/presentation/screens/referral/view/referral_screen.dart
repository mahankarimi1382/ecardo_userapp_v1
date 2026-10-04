import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referral_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/model/referral_model.dart';

/// Multilingual string selector for referral terms not yet in AppLocalizations.
String _refL(
  BuildContext context, {
  required String en,
  required String fa,
  required String ar,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'fa':
      return fa;
    case 'ar':
      return ar;
    default:
      return en;
  }
}

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralController controller = Get.find<ReferralController>();
  bool _codeCopied = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _onCopy(String code, String successMessage) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _codeCopied = true);
    ToastHelper().showSuccessToast(successMessage);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _codeCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
            child: CommonAppBar(
              title: localization.referralScreenTitle,
              rightSideWidget: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                tooltip: _refL(
                  context,
                  en: 'Referral Options',
                  fa: 'گزینه‌های ارجاع',
                  ar: 'خيارات الإحالة',
                ),
                onPressed: () => _buildHistoryNavigation(context, localization, isDark),
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // 1. Loading State
              if (controller.isLoading.value) {
                return const CommonLoading();
              }

              // 2. Error State
              if (controller.isError.value) {
                return Center(
                  child: EcardoErrorView(
                    title: localization.allControllerLoadError,
                    message: _refL(
                      context,
                      en: 'Unable to load your referral rewards program. Please try again.',
                      fa: 'بارگذاری اطلاعات برنامه پاداش دعوت ممکن نشد. لطفاً دوباره تلاش کنید.',
                      ar: 'تعذر تحميل برنامج مكافآت الإحالة. يرجى المحاولة مرة أخرى.',
                    ),
                    retryLabel: localization.noInternetConnectionRetryButton,
                    onRetry: controller.fetchReferral,
                  ),
                );
              }

              final referral = controller.referralModel.value.data;

              // 3. Empty State
              if (referral == null || (referral.code == null && referral.amount == null)) {
                return Center(
                  child: EcardoEmptyState(
                    iconData: Icons.group_add_rounded,
                    title: _refL(
                      context,
                      en: 'Referral Program Unavailable',
                      fa: 'برنامه دعوت در دسترس نیست',
                      ar: 'برنامج الإحالة غير متاح',
                    ),
                    description: _refL(
                      context,
                      en: 'The referral rewards program is temporarily closed. Please check back later.',
                      fa: 'برنامه پاداش دعوت موقتاً در دسترس نیست. لطفاً بعداً دوباره بررسی کنید.',
                      ar: 'برنامج مكافآت الإحالة مغلق مؤقتاً. يرجى التحقق مرة أخرى لاحقاً.',
                    ),
                    primaryActionLabel: localization.noInternetConnectionRetryButton,
                    onPrimaryAction: controller.fetchReferral,
                  ),
                );
              }

              // 4. Content State
              return RefreshIndicator(
                onRefresh: controller.fetchReferral,
                color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _buildHeroCard(context, referral, localization, isDark),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTierBonusCard(context, isDark),
                      const SizedBox(height: AppSpacing.lg),
                      _buildCodeCard(context, referral, localization, isDark),
                      const SizedBox(height: AppSpacing.xl),
                      CommonButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          SharePlus.instance.share(
                            ShareParams(text: referral.code ?? ''),
                          );
                        },
                        width: double.infinity,
                        text: localization.referralScreenShareButton,
                      ),
                      if (referral.isShownReferralRules == true &&
                          referral.rules != null &&
                          referral.rules!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        _buildRulesSection(context, referral.rules!, isDark),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    ReferralData referral,
    AppLocalizations localization,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isDark
              ? AppColors.mainSoftBlue.withValues(alpha: 0.22)
              : AppColors.mutedBlue.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.mutedBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              PngAssets.referralImage,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.card_giftcard_rounded,
                size: 72,
                color: AppColors.mainSoftBlue,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${localization.referralScreenEarnAmount} ${referral.amount ?? '0'} ',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                localization.referralScreenAfterInviting,
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            localization.referralScreenOneMember,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBonusCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.darkSurfaceVariant,
                  AppColors.darkCard,
                ]
              : [
                  AppColors.lightSecondaryContainer.withValues(alpha: 0.7),
                  AppColors.white,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightOutlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.warning.withValues(alpha: 0.16),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.warning,
                      size: AppSpacing.iconSm,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _refL(
                      context,
                      en: 'Tier 1 • Ambassador',
                      fa: 'سطح ۱ • سفیر',
                      ar: 'المستوى ١ • سفير',
                    ),
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '+10% ${_refL(context, en: 'Bonus', fa: 'پاداش', ar: 'مكافأة')}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            child: LinearProgressIndicator(
              value: 0.45,
              minHeight: 6,
              backgroundColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _refL(
                  context,
                  en: '3 of 5 invites to Tier 2 (Silver)',
                  fa: '۳ از ۵ دعوت تا سطح ۲ (نقره‌ای)',
                  ar: '٣ من ٥ دعوات للمستوى ٢ (فضي)',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 11.5,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(BaseRoute.referralTree),
                child: Row(
                  children: [
                    Text(
                      _refL(
                        context,
                        en: 'View Tree',
                        fa: 'مشاهده نمودار',
                        ar: 'عرض الشجرة',
                      ),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(
    BuildContext context,
    ReferralData referral,
    AppLocalizations localization,
    bool isDark,
  ) {
    final code = referral.code ?? localization.referralScreenNoCode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _refL(
              context,
              en: 'Your Unique Invite Code',
              fa: 'کد اختصاصی دعوت شما',
              ar: 'رمز الدعوة الخاص بك',
            ),
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: _codeCopied
                    ? AppColors.success
                    : (isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
                    child: SelectableText(
                      code,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      onTap: () => _onCopy(
                        code,
                        localization.referralScreenCodeCopied,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _codeCopied
                              ? AppColors.success.withValues(alpha: 0.16)
                              : (isDark
                                  ? AppColors.mainSoftBlue.withValues(alpha: 0.14)
                                  : AppColors.deepBlack.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _codeCopied
                                  ? Icons.check_circle_rounded
                                  : Icons.copy_rounded,
                              size: AppSpacing.iconSm,
                              color: _codeCopied
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.mainSoftBlue
                                      : AppColors.lightPrimary),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _codeCopied
                                  ? _refL(context, en: 'Copied', fa: 'کپی شد', ar: 'تم')
                                  : _refL(context, en: 'Copy', fa: 'کپی', ar: 'نسخ'),
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _codeCopied
                                    ? AppColors.success
                                    : (isDark
                                        ? AppColors.mainSoftBlue
                                        : AppColors.lightPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (referral.joinedText != null && referral.joinedText!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
              child: Text(
                referral.joinedText!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesSection(
    BuildContext context,
    List<Rules> rules,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule_rounded,
                size: AppSpacing.iconSm,
                color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _refL(
                  context,
                  en: 'How Referral Rewards Work',
                  fa: 'قوانین و شرایط دریافت پاداش',
                  ar: 'كيف تعمل مكافآت الإحالة',
                ),
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...rules.map((item) {
            final isTick = item.icon == 'tick';
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isTick ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 18,
                    color: isTick ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.rule ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _buildHistoryNavigation(
    BuildContext context,
    AppLocalizations localization,
    bool isDark,
  ) {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                      : AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Icon(
                  Icons.people_outline_rounded,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                title: Text(
                  localization.referralScreenReferredFriends,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(BaseRoute.referredFriends);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.account_tree_outlined,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                title: Text(
                  localization.referredFriendsScreenReferralTreeButton,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(BaseRoute.referralTree);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
