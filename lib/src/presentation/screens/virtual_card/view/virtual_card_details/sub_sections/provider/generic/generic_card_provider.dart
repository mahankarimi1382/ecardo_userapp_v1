import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';

class GenericCardProvider extends StatelessWidget {
  const GenericCardProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final VirtualCardDetailsController controller = Get.find();
    final card = controller.virtualCardDetailsModel.value.data;
    if (card == null) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: 30.h),
        _UniversalVirtualCard(card: card, controller: controller),
        SizedBox(height: 30.h),
        _UniversalCardDetails(card: card, controller: controller),
        SizedBox(height: 30.h),
      ],
    );
  }
}

class _UniversalVirtualCard extends StatelessWidget {
  final VirtualCardDetailsData card;
  final VirtualCardDetailsController controller;

  const _UniversalVirtualCard({
    required this.card,
    required this.controller,
  });

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
    final maskedNumber = card.displayNumber ??
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

    return Obx(
      () => CommonVirtualCardView(
        title: card.display?.title ?? card.cardHolder?.name ?? 'Virtual Card',
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
        status: _status(card),
        canReveal: canReveal,
        isRevealed: controller.showAccountNumber.value,
        onReveal: canReveal
            ? () {
                controller.showAccountNumber.value =
                    !controller.showAccountNumber.value;
              }
            : null,
        backgroundImage: card.display?.backgroundImage,
        brandImage: card.display?.brandImage,
        network: card.display?.network,
        primaryColor: card.display?.primaryColor,
        secondaryColor: card.display?.secondaryColor,
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

  const _UniversalCardDetails({
    required this.card,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
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
    final status = _status(card);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.cardDetailsInfoTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _Divider(),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _HeadlineValue(
                  value: localization.cardDetailsCardTypeValue,
                  label: localization.cardDetailsCardTypeLabel,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _HeadlineValue(
                  value: '${card.amount ?? '0'} '
                      '${card.currency?.toUpperCase() ?? ''}',
                  label: card.display?.balanceLabel ?? 'Balance',
                  alignEnd: true,
                  valueColor: AppColors.success,
                ),
              ),
            ],
          ),
          if ((card.display?.subtitle ?? '').isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              card.display!.subtitle!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: AppColors.lightTextTertiary,
              ),
            ),
          ],
          if ((holder?.name ?? '').isNotEmpty) ...[
            SizedBox(height: 24.h),
            _DetailRow(label: 'Cardholder', value: holder!.name!),
          ],
          if (addressLines.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              localization.cardDetailsBillingAddressLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            ...addressLines.map(
              (line) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  line,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 24.h),
          _DetailRow(
            label: localization.cardDetailsCardCurrencyLabel,
            value: card.currency?.toUpperCase() ?? '',
          ),
          if (createdAt != null) ...[
            SizedBox(height: 22.h),
            _DetailRow(
              label: localization.cardDetailsCardCreatedLabel,
              value: DateFormat('MMM dd, yyyy').format(createdAt),
            ),
          ],
          if ((card.physicalStatus ?? '').isNotEmpty) ...[
            SizedBox(height: 22.h),
            _DetailRow(
              label: 'Physical Card',
              value: _humanize(card.physicalStatus!),
            ),
          ],
          SizedBox(height: 22.h),
          _DetailRow(label: 'Status', value: _humanize(status)),
          if (canChangeStatus) ...[
            SizedBox(height: 20.h),
            Obx(
              () => CommonButton(
                backgroundColor: status.toLowerCase() == 'active'
                    ? AppColors.error
                    : AppColors.lightPrimary,
                text: status.toLowerCase() == 'active'
                    ? localization.cardDetailsStatusButtonInactive
                    : localization.cardDetailsStatusButtonActive,
                height: 40,
                borderRadius: 10,
                fontSize: 14,
                onPressed: () =>
                    controller.cardUpdateStatus(
                      cardId: card.cardId ?? card.id.toString(),
                    ),
                isLoading: controller.isUpdateCardStatusLoading.value,
              ),
            ),
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

  const _HeadlineValue({
    required this.value,
    required this.label,
    this.alignEnd = false,
    this.valueColor = AppColors.lightTextPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: valueColor,
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
            color: AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: AppColors.lightTextTertiary,
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
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            Colors.grey.shade400,
            AppColors.white,
          ],
        ),
      ),
    );
  }
}

String _status(VirtualCardDetailsData card) {
  return card.lifecycleStatus ?? card.virtualStatus ?? card.status ?? 'pending';
}

String _humanize(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
