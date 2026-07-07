import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/bsicards/bsicards_card_top_up_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/bsicards/bsicards_provider.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/stripe/stripe_card_top_up_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/stripe/stripe_provider.dart';

import '../../../../../app/constants/app_colors.dart';
import '../../../../../app/constants/assets_path/png/png_assets.dart';
import '../../../../../common/widgets/app_bar/common_app_bar.dart';
import '../../../../../common/widgets/app_bar/common_default_app_bar.dart';

class VirtualCardDetails extends StatefulWidget {
  const VirtualCardDetails({super.key});

  @override
  State<VirtualCardDetails> createState() => _VirtualCardDetailsState();
}

class _VirtualCardDetailsState extends State<VirtualCardDetails> {
  final VirtualCardDetailsController controller = Get.find();
  final String id = Get.arguments?["id"] ?? "";
  final String cardId = Get.arguments?["card_id"] ?? "";
  final String initialProvider = (Get.arguments?["provider"] ?? "")
      .toString()
      .toLowerCase();

  Future<void> _fetchCardDetailsByProvider() {
    if (initialProvider == "bsicards") {
      return controller.fetchVirtualCardDetailsBsiCardProvider(cardId: id);
    }

    return controller.fetchVirtualCardDetails(cardId: id);
  }

  @override
  void initState() {
    super.initState();
    _fetchCardDetailsByProvider();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Obx(() {
      final fetchedProvider =
          controller.virtualCardDetailsModel.value.data?.provider
              ?.toLowerCase() ??
          "";
      final provider = initialProvider.isNotEmpty
          ? initialProvider
          : fetchedProvider;

      return Scaffold(
        appBar: const CommonDefaultAppBar(),
        body: Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(
              title: localization!.virtualCardDetailsAppBarTitle,
              rightSideWidget: GestureDetector(
                onTap: () {
                  Get.toNamed(
                    BaseRoute.virtualCardTransaction,
                    arguments: {"card_id": cardId},
                  );
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 18.w),
                  child: Image.asset(PngAssets.commonHistoryIcon, width: 30.w),
                ),
              ),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const CommonLoading()
                  : RefreshIndicator(
                      onRefresh: _fetchCardDetailsByProvider,
                      color: AppColors.lightPrimary,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: provider == "stripe"
                            ? const StripeProvider()
                            : provider == "bsicards"
                            ? const BsicardsProvider()
                            : const SizedBox.shrink(),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: controller.isLoading.value
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: SizedBox(
                  height: 40.h,
                  width: 120.w,
                  child: FloatingActionButton(
                    heroTag: null,
                    elevation: 0,
                    onPressed: () {
                      if (provider == "stripe") {
                        Get.bottomSheet(StripeCardTopUpBottomSheet(cardId: id));
                      } else if (provider == "bsicards") {
                        Get.bottomSheet(BsicardsCardTopUpBottomSheet());
                      }
                    },
                    backgroundColor: const Color(0xFF7445FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(PngAssets.addCommonIcon, width: 18.w),
                        SizedBox(width: 4.w),
                        Text(
                          localization.virtualCardDetailsFloatingButton,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
