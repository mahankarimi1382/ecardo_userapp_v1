import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/assets_path/png/png_assets.dart';
import '../../../../app/constants/assets_path/svg/svg_assets.dart';
import '../../../../app/routes/routes.dart';
import '../../../../common/widgets/app_bar/common_app_bar.dart';
import '../../../../common/widgets/app_bar/common_default_app_bar.dart';
import '../controller/virtual_card_controller.dart';

class VirtualCardScreen extends StatefulWidget {
  const VirtualCardScreen({super.key});

  @override
  State<VirtualCardScreen> createState() => _VirtualCardScreenState();
}

class _VirtualCardScreenState extends State<VirtualCardScreen> {
  final VirtualCardController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.syncCardBackgroundImageFromSettings();
    controller.fetchVirtualCards();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Obx(() {
        return Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(title: localization!.virtualCardScreenAppBarTitle),
            Expanded(
              child: controller.isLoading.value
                  ? CommonLoading()
                  : RefreshIndicator(
                      onRefresh: () => controller.fetchVirtualCards(),
                      color: AppColors.lightPrimary,
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 30.h),
                        children: [
                          _buildCreateCardSection(),
                          SizedBox(height: 16.h),
                          ...List.generate(controller.virtualCardList.length, (
                            index,
                          ) {
                            final card = controller.virtualCardList[index];
                            final hasShowToggle =
                                index < controller.showAccountNumberList.length;
                            final rawAccountNo =
                                card.displayNumber ?? card.cardNumber ?? '';
                            final canShowPan =
                                card.display?.showPan != false &&
                                card.capabilities?.canRevealPan != false;
                            final accountNo = canShowPan ? rawAccountNo : '';

                            return Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: 18.w,
                                end: 18.w,
                                bottom: 16.h,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.r),
                                onTap: () {
                                  Get.toNamed(
                                    BaseRoute.virtualCardDetails,
                                    arguments: {
                                      "id": card.id.toString(),
                                      "card_id": card.cardId.toString(),
                                      "provider": card.provider,
                                    },
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 200.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 200.h,
                                          child: Obx(() {
                                            final bgImageUrl = controller
                                                .cardBackgroundImage
                                                .value
                                                .trim();

                                            if (bgImageUrl.isNotEmpty) {
                                              final isSvg = bgImageUrl
                                                  .toLowerCase()
                                                  .endsWith('.svg');

                                              if (isSvg) {
                                                return SvgPicture.network(
                                                  bgImageUrl,
                                                  fit: BoxFit.fill,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Image.asset(
                                                        PngAssets.cardMap,
                                                        fit: BoxFit.fill,
                                                      ),
                                                );
                                              } else {
                                                return Image.network(
                                                  bgImageUrl,
                                                  fit: BoxFit.fill,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Image.asset(
                                                        PngAssets.cardMap,
                                                        fit: BoxFit.fill,
                                                      ),
                                                );
                                              }
                                            }

                                            return Image.asset(
                                              PngAssets.cardMap,
                                              fit: BoxFit.contain,
                                            );
                                          }),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          start: 16.w,
                                          end: 16.w,
                                          bottom: 16.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              card.cardHolder?.name ??
                                                  card.display?.title ??
                                                  'Virtual Card',
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
                                                  final isVisible =
                                                      hasShowToggle
                                                      ? controller
                                                            .showAccountNumberList[index]
                                                            .value
                                                      : false;

                                                  final canReveal =
                                                      card.capabilities
                                                          ?.canRevealPan ==
                                                      true;
                                                  final shownNumber =
                                                      accountNo.isEmpty
                                                      ? '${card.amount ?? '0'} ${card.currency ?? ''}'
                                                      : isVisible && canReveal
                                                      ? formatAccountNumber(
                                                          accountNo,
                                                        ).trim()
                                                      : accountNo.length > 4
                                                      ? '**** **** **** ${accountNo.substring(accountNo.length - 4)}'
                                                      : accountNo;

                                                  return Text(
                                                    shownNumber,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 20.sp,
                                                      letterSpacing: 0,
                                                      color: AppColors.white,
                                                    ),
                                                  );
                                                }),
                                                SizedBox(width: 8.w),
                                                if (accountNo.isNotEmpty &&
                                                    canShowPan)
                                                  Obx(
                                                    () => GestureDetector(
                                                    onTap:
                                                        hasShowToggle &&
                                                            card.capabilities
                                                                    ?.canRevealPan !=
                                                                false
                                                        ? () {
                                                            controller
                                                                    .showAccountNumberList[index]
                                                                    .value =
                                                                !controller
                                                                    .showAccountNumberList[index]
                                                                    .value;
                                                          }
                                                        : null,
                                                    child: SvgPicture.asset(
                                                      hasShowToggle &&
                                                              controller
                                                                  .showAccountNumberList[index]
                                                                  .value
                                                          ? SvgAssets
                                                                .hideEyeIcon
                                                          : SvgAssets
                                                                .showEyeIcon,
                                                      width: 18.w,
                                                      height: 18.h,
                                                      colorFilter:
                                                          ColorFilter.mode(
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      card.display?.showExpiry ==
                                                                  false ||
                                                              card.expirationMonth ==
                                                                  null ||
                                                              card.expirationYear ==
                                                                  null
                                                          ? card.display
                                                                    ?.balanceLabel ??
                                                                'Balance'
                                                          : localization
                                                                .virtualCardCardExpiryDateLabel,
                                                      style: TextStyle(
                                                        letterSpacing: 0,
                                                        fontSize: 11.sp,
                                                        color: AppColors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      card.display?.showExpiry ==
                                                                  false ||
                                                              card.expirationMonth ==
                                                                  null ||
                                                              card.expirationYear ==
                                                                  null
                                                          ? card.display
                                                                    ?.balanceLabel ??
                                                                'Balance'
                                                          : "${card.expirationMonth}/${card.expirationYear.toString().substring(2)}",
                                                      style: TextStyle(
                                                        letterSpacing: 0,
                                                        fontSize: 14.sp,
                                                        color: AppColors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          card.display?.showCvc ==
                                                                      false ||
                                                                  card.cvc ==
                                                                      null
                                                              ? 'Currency'
                                                              : localization
                                                                    .virtualCardCardCvcLabel,
                                                          style: TextStyle(
                                                            letterSpacing: 0,
                                                            fontSize: 11.sp,
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Text(
                                                          card.display?.showCvc ==
                                                                      false ||
                                                                  card.cvc ==
                                                                      null
                                                              ? '${card.amount ?? '0'} ${card.currency ?? ''}'
                                                              : card.cvc!,
                                                          style: TextStyle(
                                                            letterSpacing: 0,
                                                            fontSize: 14.sp,
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(width: 40.w),
                                                    Container(
                                                      width: 70.w,
                                                      height: 24.h,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            card.status ==
                                                                "active"
                                                            ? Color(0xFFDBFFDA)
                                                            : const Color(
                                                                0xFFF8D8D8,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          (card.lifecycleStatus ??
                                                                      card.status ??
                                                                      '')
                                                                  .isNotEmpty
                                                              ? (card.lifecycleStatus ??
                                                                        card.status ??
                                                                        '')[0]
                                                                        .toUpperCase() +
                                                                    (card.lifecycleStatus ??
                                                                            card.status ??
                                                                            '')
                                                                        .substring(
                                                                          1,
                                                                        )
                                                              : "",
                                                          style: TextStyle(
                                                            letterSpacing: 0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 12.sp,
                                                            color:
                                                                card.status ==
                                                                    "active"
                                                                ? AppColors
                                                                      .success
                                                                : AppColors
                                                                      .error,
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
                                        top: 16.h,
                                        start: 16.w,
                                        child: Image.asset(
                                          PngAssets.cardChip,
                                          width: 38.w,
                                          height: 28.h,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        top: 16.h,
                                        end: 16.w,
                                        child: Image.asset(
                                          PngAssets.cardVisa,
                                          width: 48.w,
                                          height: 15.h,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  String formatAccountNumber(String number) {
    return number.replaceAllMapped(
      RegExp(r".{4}"),
      (match) => "${match.group(0)} ",
    );
  }

  Widget _buildCreateCardSection() {
    final localization = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(PngAssets.createVirtualCardImage, fit: BoxFit.fill),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 60.w),
                child: Column(
                  children: [
                    Text(
                      localization!.virtualCardCreateCardTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                        color: AppColors.lightTextPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CommonIconButton(
                      onPressed: () {
                        Get.toNamed(BaseRoute.getCardInfo);
                      },
                      width: 120,
                      height: 33,
                      text: localization.virtualCardCreateCardButton,
                      icon: PngAssets.addCommonIcon,
                      iconWidth: 17,
                      iconHeight: 17,
                      iconAndTextSpace: 4,
                      fontSize: 13,
                      borderRadius: 8,
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
}
