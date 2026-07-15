import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
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
    final showNumber =
        card.display?.showPan == true &&
        card.capabilities?.canRevealPan == true &&
        rawNumber.isNotEmpty;

    final status = _statusLabel(card);
    final expiry =
        card.display?.showExpiry == true &&
            card.expirationMonth != null &&
            card.expirationYear != null
        ? '${card.expirationMonth}/${card.expirationYear.toString().substring(2)}'
        : '$balance ${card.currency ?? ''}';
    final cvc =
        card.display?.showCvc == true && card.cvc != null
        ? card.cvc!
        : card.currency ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => CommonVirtualCardView(
            title: card.display?.title ?? 'Virtual Card',
            value: showNumber
                ? controller.showAccountNumber.value
                      ? rawNumber
                      : maskedNumber
                : maskedNumber.isNotEmpty
                ? maskedNumber
                : '$balance ${card.currency ?? ''}',
            firstLabel: card.display?.showExpiry == true
                ? card.display?.expiryLabel ?? 'Expiry'
                : card.display?.balanceLabel ?? 'Balance',
            firstValue: expiry,
            secondLabel: card.display?.showCvc == true
                ? card.display?.cvcLabel ?? 'CVC'
                : card.display?.currencyLabel ?? 'Currency',
            secondValue: cvc,
            status: status,
            canReveal: showNumber,
            isRevealed: controller.showAccountNumber.value,
            onReveal: () {
              controller.showAccountNumber.value =
                  !controller.showAccountNumber.value;
            },
            backgroundImage: card.display?.backgroundImage,
            brandImage: card.display?.brandImage,
            network: card.display?.network,
            primaryColor: card.display?.primaryColor,
            secondaryColor: card.display?.secondaryColor,
          ),
        ),
        if ((card.display?.subtitle ?? '').isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            card.display!.subtitle!,
            style: TextStyle(
              color: AppColors.lightTextTertiary,
              fontSize: 14.sp,
            ),
          ),
        ],
        if ((card.cardHolder?.name ?? '').isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            card.cardHolder!.name!,
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if ((card.physicalStatus ?? '').isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text('Physical card: ${_humanize(card.physicalStatus!)}'),
        ],
      ],
    );
  }

  static String _maskNumber(String value) {
    if (value.length <= 4) return value;
    return '•••• •••• •••• ${value.substring(value.length - 4)}';
  }

  static String _statusLabel(VirtualCardDetailsData card) {
    final status =
        card.lifecycleStatus ?? card.virtualStatus ?? card.status ?? 'pending';
    return _humanize(status.toString());
  }

  static String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
