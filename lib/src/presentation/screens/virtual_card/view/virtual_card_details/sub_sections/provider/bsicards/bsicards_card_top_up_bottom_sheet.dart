import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';

import '../../../../../../../../app/constants/app_colors.dart';

class BsicardsCardTopUpBottomSheet extends StatelessWidget {
  const BsicardsCardTopUpBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final VirtualCardDetailsController controller = Get.find();
    final localization = AppLocalizations.of(context)!;
    final card =
        controller.virtualCardDetailsBsiCardProviderModel.value.data?.data;
    final depositAddresses = <_CryptoAddressItem>[
      _CryptoAddressItem(
        title: 'USDC (Polygon)',
        address: card?.depositAddress ?? '',
      ),
      _CryptoAddressItem(
        title: 'USDT (BSC/BEP20)',
        address: card?.usdtDepositAddress ?? '',
      ),
      _CryptoAddressItem(title: 'BTC', address: card?.btcDepositAddress ?? ''),
      _CryptoAddressItem(title: 'ETH', address: card?.ethDepositAddress ?? ''),
      _CryptoAddressItem(title: 'SOL', address: card?.solDepositAddress ?? ''),
      _CryptoAddressItem(
        title: 'BNB (BSC)',
        address: card?.bnbDepositAddress ?? '',
      ),
      _CryptoAddressItem(
        title: 'XRP (BSC)',
        address: card?.xrpDepositAddress ?? '',
      ),
      _CryptoAddressItem(
        title: 'PAXG',
        address: card?.paxgDepositAddress ?? '',
      ),
    ].where((item) => item.address.isNotEmpty).toList();

    return AnimatedContainer(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Row(
            children: [
              const Spacer(),
              Text(
                localization.virtualCardDetailsFloatingButton,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: Get.back,
                child: Icon(
                  Icons.close,
                  size: 24.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5C2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFFFC107)),
                    ),
                    child: Text(
                      localization.bsicardsTopUpInfoMessage,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: AppColors.lightTextPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ...depositAddresses.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildAddressCard(item, localization),
                    ),
                  ),
                  SizedBox(height: 18.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    _CryptoAddressItem item,
    AppLocalizations localization,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: AppColors.lightTextPrimary,
                    letterSpacing: 0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: item.address));
                  ToastHelper().showSuccessToast(
                    localization.bsicardsTopUpCopySuccess,
                  );
                },
                child: Text(
                  localization.bsicardsTopUpCopyButton,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: AppColors.lightPrimary,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            item.address,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              color: AppColors.lightTextTertiary,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CryptoAddressItem {
  final String title;
  final String address;

  const _CryptoAddressItem({required this.title, required this.address});
}
