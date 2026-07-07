import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';

class BillPaymentScreen extends StatelessWidget {
  const BillPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final List<Map<String, dynamic>> paymentList = [
      {
        "title": localization!.billPaymentAirtime,
        "icon": PngAssets.commonAirtimeIcon,
        "navigate": BaseRoute.airtime,
      },
      {
        "title": localization.billPaymentElectricity,
        "icon": PngAssets.commonElectricityIcon,
        "navigate": BaseRoute.electricity,
      },
      {
        "title": localization.billPaymentInternet,
        "icon": PngAssets.commonInternetIcon,
        "navigate": BaseRoute.internet,
      },
      {
        "title": localization.billPaymentDataBundle,
        "icon": PngAssets.commonDataBundleIcon,
        "navigate": BaseRoute.dataBundle,
      },
      {
        "title": localization.billPaymentCables,
        "icon": PngAssets.commonCablesIcon,
        "navigate": BaseRoute.cable,
      },
      {
        "title": localization.billPaymentToll,
        "icon": PngAssets.commonTollIcon,
        "navigate": BaseRoute.toll,
      },
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        body: Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(
              title: localization.billPaymentScreenTitle,
              isBackLogicApply: true,
              backLogicFunction: () async {
                Get.offNamed(BaseRoute.navigation);
              },
              rightSideWidget: GestureDetector(
                onTap: () => Get.toNamed(BaseRoute.billPaymentHistory),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 18.w),
                  child: Image.asset(PngAssets.commonHistoryIcon, width: 30.w),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                itemCount: paymentList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.w,
                ),
                itemBuilder: (context, index) {
                  final payment = paymentList[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(payment["navigate"]);
                    },
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            payment["icon"],
                            width: 30.w,
                            height: 30.h,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            payment["title"],
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 12.sp,
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
