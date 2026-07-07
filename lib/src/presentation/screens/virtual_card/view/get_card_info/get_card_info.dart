import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

class GetCardInfo extends StatelessWidget {
  const GetCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          CommonAppBar(title: localization!.getCardInfoAppBarTitle),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildCardSection(context),
                  SizedBox(height: 20.h),
                  _buildInfoSection(context),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 18.w),
                    child: CommonButton(
                      text: localization.getCardInfoButtonContinue,
                      onPressed: () =>
                          Get.offNamed(BaseRoute.createVirtualCard),
                    ),
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsetsGeometry.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildDynamicInfoSection(
            title: localization!.getCardInfoBenefitSecurityTitle,
            subtitle: localization.getCardInfoBenefitSecuritySubtitle,
            icon: PngAssets.betterSecurityIcon,
          ),
          Divider(
            height: 0,
            color: AppColors.lightPrimary.withValues(alpha: 0.10),
          ),
          _buildDynamicInfoSection(
            title: localization.getCardInfoBenefitShoppingTitle,
            subtitle: localization.getCardInfoBenefitShoppingSubtitle,
            icon: PngAssets.safeOnlineShoppingIcon,
          ),
          Divider(
            height: 0,
            color: AppColors.lightPrimary.withValues(alpha: 0.10),
          ),
          _buildDynamicInfoSection(
            title: localization.getCardInfoBenefitActivationTitle,
            subtitle: localization.getCardInfoBenefitActivationSubtitle,
            icon: PngAssets.fastAndEasyActivationIcon,
          ),
        ],
      ),
    );
  }

  Padding _buildDynamicInfoSection({
    required String title,
    required String subtitle,
    required String icon,
  }) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(icon, width: 30.w),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: AppColors.lightTextTertiary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization!.getCardInfoBenefitsTitle,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: Color(0xFFB69EFD),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 290.w,
                    height: 130.h,
                    child: Image.asset(PngAssets.cardMap, fit: BoxFit.contain),
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
                        "XXXX",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          letterSpacing: 0,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "**** **** **** ****",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.sp,
                          letterSpacing: 0,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "xxxx xxxx",
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 11.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "xx. xx. xxxx",
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 14.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
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
                                    "xxx",
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontSize: 11.sp,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "xxx",
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontSize: 14.sp,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 40.w),
                              Container(
                                width: 70.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  color: Color(0xFFDBFFDA),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    "xxxx",
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.sp,
                                      color: Color(0xFF468C45),
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
                  top: 6.h,
                  end: 6.w,
                  bottom: 6.h,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.12,
                      child: SvgPicture.asset(
                        SvgAssets.cardShape,
                        fit: BoxFit.fill,
                        colorFilter: ColorFilter.mode(
                          Color(0xFFB69EFD),
                          BlendMode.overlay,
                        ),
                      ),
                    ),
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
        ],
      ),
    );
  }
}
