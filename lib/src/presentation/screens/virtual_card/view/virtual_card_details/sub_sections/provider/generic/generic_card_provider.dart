import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_top_up_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart';

class GenericCardProvider extends StatelessWidget {
  const GenericCardProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final VirtualCardDetailsController controller = Get.find();
    final card = controller.virtualCardDetailsModel.value.data;
    if (card == null) return const SizedBox.shrink();

    controller.syncFreezeState(card);

    final hasGenericContract =
        card.display != null ||
        card.capabilities != null ||
        card.funding != null ||
        card.actions != null;
    final canViewTransactions =
        !hasGenericContract || card.capabilities?.canViewTransactions == true;
    final canTopUp = !hasGenericContract || card.capabilities?.canTopup == true;
    final cardIdStr = card.cardId ?? card.id.toString();

    return Column(
      children: [
        SizedBox(height: 16.h),

        // 1. Interactive 3D Flip Card with 1-Tap Copy & Reveal
        _UniversalVirtualCard(card: card, controller: controller),

        SizedBox(height: 16.h),

        // 2. Security Controls Quick Action Grid (Freeze, Online, Limits, Transactions, Top-up)
        Obx(
          () => VirtualCardSecurityControls(
            isFrozen: controller.isCardFrozen.value,
            isFreezeLoading: controller.isUpdateCardStatusLoading.value,
            onToggleFreeze: (val) {
              controller.toggleCardFreeze(cardId: cardIdStr);
            },
            isOnlinePaymentsEnabled: controller.isOnlinePaymentsEnabled.value,
            onToggleOnlinePayments: (val) {
              controller.toggleOnlinePayments();
            },
            cardId: cardIdStr,
            dailySpendLimit: controller.dailySpendLimit.value,
            monthlySpendLimit: controller.monthlySpendLimit.value,
            currency: card.currency?.toUpperCase() ?? 'USD',
            onUpdateSpendingLimits: (daily, monthly) {
              controller.submitSpendingLimits(
                cardId: cardIdStr,
                daily: daily,
                monthly: monthly,
              );
            },
            onChangePin: () {
              VirtualCardSecurityControls.showCardPinChange(
                context,
                cardId: cardIdStr,
              );
            },
            onReplaceCard: () {
              VirtualCardSecurityControls.showCardReplacement(
                context,
                cardId: cardIdStr,
              );
            },
            canViewTransactions: canViewTransactions,
            onViewTransactions: () {
              Get.toNamed(
                BaseRoute.virtualCardTransaction,
                arguments: {
                  'card_id': cardIdStr,
                  'endpoint': card.actions?.transactionsEndpoint,
                },
              );
            },
            canTopUp: canTopUp,
            onTopUp: () {
              Get.bottomSheet(
                GenericCardTopUpBottomSheet(cardId: card.id?.toString() ?? ''),
                isScrollControlled: true,
              );
            },
          ),
        ),

        SizedBox(height: 20.h),

        // 3. Detailed Card Specifications & Billing Information
        _UniversalCardDetails(card: card, controller: controller),

        SizedBox(height: 30.h),
      ],
    );
  }
}

class _UniversalVirtualCard extends StatelessWidget {
  final VirtualCardDetailsData card;
  final VirtualCardDetailsController controller;

  const _UniversalVirtualCard({required this.card, required this.controller});

  @override
  Widget build(BuildContext context) {
    final decimals = card.currency?.toUpperCase() == 'IRR'
        ? 0
        : card.display?.currencyDecimals ?? 2;
    final balance = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
    ).format(num.tryParse(card.amount ?? '') ?? 0).trim();
    final rawNumber = card.cardNumber ?? '';
    final maskedNumber =
        card.displayNumber ??
        (rawNumber.isNotEmpty ? _maskNumber(rawNumber) : '');
    final canReveal =
        card.display?.showPan == true &&
        card.capabilities?.canRevealPan == true &&
        rawNumber.isNotEmpty;
    final showExpiry =
        card.display?.showExpiry == true &&
        card.expirationMonth != null &&
        card.expirationYear != null;
    final showCvc = card.display?.showCvc == true && card.cvc != null;

    return Obx(() {
      final isFrozen = controller.isCardFrozen.value;
      final currentStatus = isFrozen ? 'frozen' : _status(card);

      return CardFreezeOverlay(
        isFrozen: isFrozen,
        showToggle:
            false, // The toggle switch lives in the quick action grid below
        onToggleFreeze: (val) {
          controller.toggleCardFreeze(
            cardId: card.cardId ?? card.id.toString(),
          );
        },
        child: CommonVirtualCardView(
          title: card.display?.title ?? card.cardHolder?.name ?? 'Virtual Card',
          cardHolderName: card.cardHolder?.name,
          rawCardNumber: rawNumber,
          cvv: card.cvc,
          value: maskedNumber.isEmpty
              ? '$balance ${card.currency ?? ''}'
              : controller.showAccountNumber.value && canReveal
              ? _formatNumber(rawNumber)
              : maskedNumber,
          firstLabel: showExpiry
              ? card.display?.expiryLabel ?? 'Expiry'
              : card.display?.balanceLabel ?? 'Balance',
          firstValue: showExpiry
              ? '${card.expirationMonth}/${_shortYear(card.expirationYear)}'
              : '$balance ${card.currency ?? ''}',
          secondLabel: showCvc
              ? card.display?.cvcLabel ?? 'CVC'
              : card.display?.currencyLabel ?? 'Currency',
          secondValue: showCvc ? card.cvc! : card.currency ?? '',
          status: currentStatus,
          canReveal: canReveal && !isFrozen,
          isRevealed: controller.showAccountNumber.value,
          enableFlip: true,
          showFlipIndicator: true,
          onReveal: canReveal && !isFrozen
              ? () {
                  controller.authenticateAndTogglePan(context);
                }
              : null,
          onRevealCvv: () => controller.authenticateAndRevealCvv(context),
          backgroundImage: card.display?.backgroundImage,
          brandImage: card.display?.brandImage,
          network: card.display?.network,
          primaryColor: card.display?.primaryColor,
          secondaryColor: card.display?.secondaryColor,
          isFrozen: isFrozen,
        ),
      );
    });
  }

  static String _formatNumber(String value) {
    return value
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();
  }

  static String _maskNumber(String value) {
    if (value.length <= 4) return value;
    return '**** **** **** ${value.substring(value.length - 4)}';
  }

  static String _shortYear(Object? value) {
    final year = value?.toString() ?? '';
    return year.length > 2 ? year.substring(year.length - 2) : year;
  }
}

class _UniversalCardDetails extends StatelessWidget {
  final VirtualCardDetailsData card;
  final VirtualCardDetailsController controller;

  const _UniversalCardDetails({required this.card, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final holder = card.cardHolder;
    final addressLines = [
      holder?.address,
      [
        holder?.city,
        holder?.state,
        holder?.country,
        holder?.postalCode,
      ].whereType<String>().where((value) => value.isNotEmpty).join(' · '),
    ].whereType<String>().where((value) => value.isNotEmpty).toList();
    final createdAt = DateTime.tryParse(card.createdAt ?? '');
    final canChangeStatus = card.capabilities?.canFreeze == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.mutedBlue.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.cardDetailsInfoTitle,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          _Divider(isDark: isDark),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _HeadlineValue(
                  value: localization.cardDetailsCardTypeValue,
                  label: localization.cardDetailsCardTypeLabel,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _HeadlineValue(
                  value:
                      '${card.amount ?? '0'} '
                      '${card.currency?.toUpperCase() ?? ''}',
                  label: card.display?.balanceLabel ?? 'Balance',
                  alignEnd: true,
                  valueColor: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if ((card.display?.subtitle ?? '').isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              card.display!.subtitle!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
          if ((holder?.name ?? '').isNotEmpty) ...[
            SizedBox(height: 20.h),
            _DetailRow(
              label: l10nPick(
                context,
                en: 'Cardholder',
                fa: 'دارنده کارت',
                ar: 'حامل البطاقة',
                tr: 'Kart Sahibi',
                ru: 'Держатель карты',
                zh: '持卡人',
              ),
              value: holder!.name!,
              isDark: isDark,
            ),
          ],
          if (addressLines.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              localization.cardDetailsBillingAddressLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5.sp,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            ...addressLines.map(
              (line) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  line,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 20.h),
          _DetailRow(
            label: localization.cardDetailsCardCurrencyLabel,
            value: card.currency?.toUpperCase() ?? '',
            isDark: isDark,
          ),
          if (createdAt != null) ...[
            SizedBox(height: 18.h),
            _DetailRow(
              label: localization.cardDetailsCardCreatedLabel,
              value: DateFormat('MMM dd, yyyy').format(createdAt),
              isDark: isDark,
            ),
          ],
          if ((card.physicalStatus ?? '').isNotEmpty) ...[
            SizedBox(height: 18.h),
            _DetailRow(
              label: l10nPick(
                context,
                en: 'Physical Card',
                fa: 'کارت فیزیکی',
                ar: 'بطاقة فعلية',
                tr: 'Fiziksel Kart',
                ru: 'Физическая карта',
                zh: '实体卡',
              ),
              value: _humanize(card.physicalStatus!),
              isDark: isDark,
            ),
          ],
          SizedBox(height: 18.h),
          Obx(() {
            final isFrozen = controller.isCardFrozen.value;
            final currentStatus = isFrozen ? 'frozen' : _status(card);
            return _DetailRow(
              label: l10nPick(
                context,
                en: 'Card Status',
                fa: 'وضعیت کارت',
                ar: 'حالة البطاقة',
                tr: 'Kart Durumu',
                ru: 'Статус карты',
                zh: '卡状态',
              ),
              value: _humanize(currentStatus),
              isDark: isDark,
            );
          }),
          if (canChangeStatus) ...[
            SizedBox(height: 20.h),
            Obx(() {
              final isFrozen = controller.isCardFrozen.value;
              final currentStatus = isFrozen ? 'frozen' : _status(card);
              final isActive = currentStatus.toLowerCase() == 'active';
              return CommonButton(
                backgroundColor: isActive
                    ? AppColors.error
                    : AppColors.lightPrimary,
                text: isActive
                    ? localization.cardDetailsStatusButtonInactive
                    : localization.cardDetailsStatusButtonActive,
                height: 42,
                borderRadius: 12,
                fontSize: 13.5,
                onPressed: () => controller.toggleCardFreeze(
                  cardId: card.cardId ?? card.id.toString(),
                ),
                isLoading: controller.isUpdateCardStatusLoading.value,
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _HeadlineValue extends StatelessWidget {
  final String value;
  final String label;
  final bool alignEnd;
  final Color valueColor;
  final bool isDark;

  const _HeadlineValue({
    required this.value,
    required this.label,
    this.alignEnd = false,
    this.valueColor = AppColors.lightTextPrimary,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: valueColor != AppColors.lightTextPrimary
                ? valueColor
                : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Flexible(
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333330) : const Color(0xFFE5E7EB),
      ),
    );
  }
}

String _status(VirtualCardDetailsData card) {
  return card.lifecycleStatus ?? card.virtualStatus ?? card.status ?? 'pending';
}

String _humanize(String value) {
  if (value.isEmpty) return 'Active';
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
