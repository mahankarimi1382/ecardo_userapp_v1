import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';

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
    final displayNumber = card.displayNumber ?? card.cardNumber;
    final showNumber =
        card.display?.showPan == true &&
        card.capabilities?.canRevealPan == true &&
        (displayNumber ?? '').isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7445FF), Color(0xFF4C2BB3)],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.display?.title ?? 'Virtual Card',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showNumber) ...[
                SizedBox(height: 20.h),
                Obx(
                  () => Text(
                    controller.showAccountNumber.value
                        ? displayNumber!
                        : _maskNumber(displayNumber!),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18.sp,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              Text(
                card.display?.balanceLabel ?? 'Balance',
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                '$balance ${card.currency ?? ''}',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 12.h),
              _StatusChip(status: _statusLabel(card)),
            ],
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
        if (card.display?.showExpiry == true &&
            card.expirationMonth != null &&
            card.expirationYear != null) ...[
          SizedBox(height: 16.h),
          Text(
            'Expiry: ${card.expirationMonth}/'
            '${card.expirationYear.toString().substring(2)}',
          ),
        ],
        if (card.display?.showCvc == true && card.cvc != null) ...[
          SizedBox(height: 8.h),
          Text('CVC: ${card.cvc}'),
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

  static String _statusLabel(dynamic card) {
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

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isSuccess = normalized == 'active' || normalized == 'completed';
    final isFailure =
        normalized.contains('failed') || normalized == 'cancelled';
    final color = isSuccess
        ? AppColors.success
        : isFailure
        ? AppColors.error
        : const Color(0xFFFFA000);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
