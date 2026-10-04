import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/epay_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_cards_model.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/epay_cards_section.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';

/// Locale-aware fallback string helper for virtual cards.
String _vcL(
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

class VirtualCardScreen extends StatefulWidget {
  /// v1.0.46: when embedded as a bottom-nav tab there is no pushed route to
  /// pop — the app-bar back arrow then jumps to the home tab instead of the
  /// dead `Get.back()` (the reported broken back button).
  final bool embeddedInTabs;

  const VirtualCardScreen({super.key, this.embeddedInTabs = false});

  @override
  State<VirtualCardScreen> createState() => _VirtualCardScreenState();
}

class _VirtualCardScreenState extends State<VirtualCardScreen> {
  late final VirtualCardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<VirtualCardController>()
        ? Get.find<VirtualCardController>()
        : Get.put(VirtualCardController());
    controller.syncCardBackgroundImageFromSettings();
    controller.fetchVirtualCards();
    // WAVE-REVIEW: PayCardo (ePay) cards — USDT-funded, USD-spending.
    if (!Get.isRegistered<EpayCardController>()) {
      Get.put(EpayCardController());
    }
    Get.find<EpayCardController>().fetchEpayCards();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    if (localization == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CommonDefaultAppBar(),
      body: Obx(
        () => Column(
          children: [
            SizedBox(height: AppSpacing.lg.h),
            CommonAppBar(
              title: localization.virtualCardScreenAppBarTitle,
              selectedIndex: widget.embeddedInTabs ? 0 : null,
            ),
            Expanded(
              child: _buildBody(localization, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations localization, bool isDark) {
    // 1. Loading State
    if (controller.isLoading.value) {
      return const CommonLoading();
    }

    // 2. Error State
    if (controller.isError.value && controller.virtualCardList.isEmpty) {
      return Center(
        child: EcardoErrorView(
          title: localization.allControllerLoadError,
          message: _vcL(
            context,
            en: 'Could not load your virtual cards. Please check your network and try again.',
            fa: 'بارگذاری کارت‌های مجازی ممکن نشد. لطفاً اتصال شبکه را بررسی کرده و مجدداً تلاش کنید.',
            ar: 'تعذر تحميل بطاقاتك الافتراضية. يرجى التحقق من الشبكة والمحاولة مرة أخرى.',
          ),
          retryLabel: localization.noInternetConnectionRetryButton,
          onRetry: controller.fetchVirtualCards,
        ),
      );
    }

    // 3. Empty State (if no cards at all)
    if (controller.virtualCardList.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.fetchVirtualCards,
        color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 30.h),
          children: [
            _buildCreateCardSection(localization, isDark),
            SizedBox(height: AppSpacing.xl.h),
            Center(
              child: EcardoEmptyState(
                iconData: Icons.credit_card_off_rounded,
                title: _vcL(
                  context,
                  en: 'No Virtual Cards Yet',
                  fa: 'هنوز کارت مجازی ایجاد نشده است',
                  ar: 'لا توجد بطاقات افتراضية بعد',
                ),
                description: _vcL(
                  context,
                  en: 'Issue an instant prepaid Visa or Shetab card for secure international and local payments.',
                  fa: 'برای پرداخت‌های امن بین‌المللی و محلی، فوراً یک کارت مجازی پیش‌پرداخت صادر کنید.',
                  ar: 'أصدر بطاقة مسبقة الدفع فورية للمدفوعات الآمنة الدولية والمحلية.',
                ),
                primaryActionLabel: localization.virtualCardCreateCardButton,
                onPrimaryAction: () => Get.toNamed(BaseRoute.getCardInfo),
              ),
            ),
            SizedBox(height: 16.h),
            const EpayCardsSection(),
          ],
        ),
      );
    }

    // 4. Content State with Card Limits Overview and Card List
    return RefreshIndicator(
      onRefresh: controller.fetchVirtualCards,
      color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 30.h),
        children: [
          _buildLimitsAndSecurityBanner(context, isDark),
          SizedBox(height: 12.h),
          _buildCreateCardSection(localization, isDark),
          SizedBox(height: 16.h),
          ...List.generate(controller.virtualCardList.length, (index) {
            return _cardItem(
              controller.virtualCardList[index],
              index,
            );
          }),
          // WAVE-REVIEW: PayCardo (ePay) section — USDT-funded, USD-spending cards
          SizedBox(height: 12.h),
          const EpayCardsSection(),
        ],
      ),
    );
  }

  Widget _buildLimitsAndSecurityBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : AppColors.mutedBlue.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      size: AppSpacing.iconSm,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _vcL(
                        context,
                        en: 'Daily Card Spend Limit',
                        fa: 'سقف تراکنش روزانه کارت',
                        ar: 'حد الإنفاق اليومي للبطاقة',
                      ),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '78% ${_vcL(context, en: 'Available', fa: 'باقی‌مانده', ar: 'متاح')}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              child: LinearProgressIndicator(
                value: 0.22,
                minHeight: 5,
                backgroundColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardItem(VirtualCardsData card, int index) {
    final rawNumber = card.cardNumber ?? '';
    final maskedNumber = card.displayNumber ??
        (rawNumber.isNotEmpty ? _maskNumber(rawNumber) : '');
    final canReveal =
        rawNumber.isNotEmpty &&
        card.display?.showPan != false &&
        card.capabilities?.canRevealPan == true;
    final revealed =
        index < controller.showAccountNumberList.length &&
        controller.showAccountNumberList[index].value;
    final value = maskedNumber.isEmpty
        ? '${card.amount ?? '0'} ${card.currency ?? ''}'
        : revealed
        ? _formatNumber(rawNumber)
        : maskedNumber;
    final showExpiry =
        card.display?.showExpiry == true &&
        card.expirationMonth != null &&
        card.expirationYear != null;
    final showCvc = card.display?.showCvc == true && card.cvc != null;

    final status =
        card.lifecycleStatus ?? card.virtualStatus ?? card.status ?? '';

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 18.w,
        end: 18.w,
        bottom: 16.h,
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(
            BaseRoute.virtualCardDetails,
            arguments: {
              'id': card.id.toString(),
              'card_id': card.cardId.toString(),
              'provider': card.provider,
            },
          );
        },
        child: CommonVirtualCardView(
          title: card.display?.title ?? 'Virtual Card',
          value: value,
          firstLabel: showExpiry
              ? card.display?.expiryLabel ?? 'Expiry'
              : card.display?.balanceLabel ?? 'Balance',
          firstValue: showExpiry
              ? '${card.expirationMonth}/${card.expirationYear.toString().substring(2)}'
              : '${card.amount ?? '0'} ${card.currency ?? ''}',
          secondLabel: showCvc
              ? card.display?.cvcLabel ?? 'CVC'
              : card.display?.currencyLabel ?? 'Currency',
          secondValue: showCvc ? card.cvc! : card.currency ?? '',
          status: status,
          canReveal: canReveal,
          isRevealed: revealed,
          onReveal: canReveal
              ? () {
                  controller.showAccountNumberList[index].value = !revealed;
                }
              : null,
          backgroundImage:
              card.display?.backgroundImage ??
              controller.cardBackgroundImage.value,
          brandImage: card.display?.brandImage,
          network: card.display?.network,
          primaryColor: card.display?.primaryColor,
          secondaryColor: card.display?.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildCreateCardSection(AppLocalizations localization, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                PngAssets.createVirtualCardImage,
                fit: BoxFit.fill,
                errorBuilder: (_, _, _) => Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Column(
                  children: [
                    Text(
                      localization.virtualCardCreateCardTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CommonIconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.getCardInfo);
                      },
                      width: 130,
                      height: 36,
                      text: localization.virtualCardCreateCardButton,
                      icon: PngAssets.addCommonIcon,
                      iconWidth: 17,
                      iconHeight: 17,
                      iconAndTextSpace: 6,
                      fontSize: 13,
                      borderRadius: AppSpacing.radiusSm,
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

  static String _formatNumber(String value) {
    return value
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();
  }

  static String _maskNumber(String value) {
    if (value.length <= 4) return value;
    return '•••• •••• •••• ${value.substring(value.length - 4)}';
  }
}
