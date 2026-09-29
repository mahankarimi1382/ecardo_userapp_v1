import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

import '../../../../../../../../app/constants/app_colors.dart';
import '../../../../../../../../app/constants/assets_path/png/png_assets.dart';
import '../../../../../../../../app/constants/assets_path/svg/svg_assets.dart';
import '../../../../../controller/virtual_card_details_controller.dart';

class BsicardsVirtualCard extends StatelessWidget {
  const BsicardsVirtualCard({super.key});

  @override
  Widget build(BuildContext context) {
    final VirtualCardDetailsController controller = Get.find();
    final card = controller.virtualCardDetailsBsiCardProviderModel.value.data;
    final status = card?.data?.status ?? '';
    final formattedStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : '';
    final localization = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBEA8FD), Color(0xFF9876F5)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E7EF8).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 200.h,
              child: Obx(() {
                final bgImageUrl = Get.find<SettingsService>().getSetting(
                  "card_bg_image",
                );

                if (bgImageUrl!.isNotEmpty) {
                  final isSvg = bgImageUrl.toLowerCase().endsWith('.svg');

                  if (isSvg) {
                    return SvgPicture.network(
                      bgImageUrl,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) =>
                          Opacity(opacity: 0.18, child: Image.asset(PngAssets.cardMap, fit: BoxFit.contain)),
                    );
                  } else {
                    return Image.network(
                      bgImageUrl,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) =>
                          Opacity(opacity: 0.18, child: Image.asset(PngAssets.cardMap, fit: BoxFit.contain)),
                    );
                  }
                }

                return Opacity(opacity: 0.18, child: Image.asset(PngAssets.cardMap, fit: BoxFit.contain));
              }),
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.14,
                child: SvgPicture.asset(
                  SvgAssets.cardShape,
                  fit: BoxFit.fill,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 16.w,
              end: 16.w,
              bottom: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  card?.data?.nameOnCard ?? '—',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    letterSpacing: 0,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Obx(() {
                      return Text(
                        () {
                          // phase1-fix (P0-10): no force-unwrap on short/absent PAN
                          final pan = card?.data?.cardNumber ?? '';
                          return controller.showAccountNumber.value
                              ? formatAccountNumber(pan).trim()
                              : '**** **** **** ${pan.length >= 4 ? pan.substring(pan.length - 4) : '----'}';
                        }(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.sp,
                          letterSpacing: 0,
                          color: AppColors.white,
                        ),
                      );
                    }),
                    SizedBox(width: 8.w),
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          controller.showAccountNumber.value =
                              !controller.showAccountNumber.value;
                        },
                        child: SvgPicture.asset(
                          controller.showAccountNumber.value
                              ? SvgAssets.hideEyeIcon
                              : SvgAssets.showEyeIcon,
                          width: 18.w,
                          height: 18.h,
                          colorFilter: ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization!.virtualCardExpiryDateLabel,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 11.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${card?.data?.expiryMonth ?? '--'}/${(card?.data?.expiryYear?.toString() ?? '').padLeft(4, '0').substring(2)}",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 14.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.virtualCardCvcLabel,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontSize: 11.sp,
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            GestureDetector(
                              // phase1-fix (P0-10): CVV masked by default,
                              // tap to reveal for 10s only.
                              onTap: controller.revealCvvTemporarily,
                              child: Obx(
                                () => Text(
                                  controller.showCvv.value
                                      ? (card?.data?.cvv ?? '---')
                                      : '•••',
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontSize: 14.sp,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 40.w),
                        Container(
                          width: 70.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: card?.data?.status == "active"
                                ? const Color(0xFFD4F4D2)
                                : const Color(0xFFFDE8E8),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              formattedStatus,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                                color: card?.data?.status == "active"
                                    ? const Color(0xFF2E7238)
                                    : const Color(0xFFC53030),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 18.h,
            start: 18.w,
            child: Image.asset(PngAssets.cardVisa, width: 48.w, height: 16.h),
          ),
          PositionedDirectional(
            top: 18.h,
            end: 18.w,
            child: Image.asset(PngAssets.cardChip, width: 38.w, height: 28.h),
          ),
        ],
      ),
    );
  }

  String formatAccountNumber(String number) {
    return number.replaceAllMapped(
      RegExp(r".{4}"),
      (match) => "${match.group(0)} ",
    );
  }
}
