import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_provider.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_top_up_bottom_sheet.dart';

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
  Future<void> _fetchCardDetailsByProvider() {
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
      final card = controller.virtualCardDetailsModel.value.data;
      final hasGenericContract =
          card?.display != null ||
          card?.capabilities != null ||
          card?.funding != null ||
          card?.actions != null;
      final canViewTransactions =
          !hasGenericContract || card?.capabilities?.canViewTransactions == true;
      final canTopUp =
          !hasGenericContract || card?.capabilities?.canTopup == true;

      return Scaffold(
        appBar: const CommonDefaultAppBar(),
        body: Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(
              title: localization!.virtualCardDetailsAppBarTitle,
              rightSideWidget: canViewTransactions
                  ? GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          BaseRoute.virtualCardTransaction,
                          arguments: {
                            "card_id": cardId,
                            "endpoint": card?.actions?.transactionsEndpoint,
                          },
                        );
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(end: 18.w),
                        child: Image.asset(
                          PngAssets.commonHistoryIcon,
                          width: 30.w,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const CommonLoading()
                  : RefreshIndicator(
                      onRefresh: _fetchCardDetailsByProvider,
                      color: AppColors.lightPrimary,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          18.w,
                          0,
                          18.w,
                          canTopUp ? 90.h : 30.h,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: const GenericCardProvider(),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: controller.isLoading.value || !canTopUp
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: CommonButton(
                  width: 130,
                  height: 42,
                  borderRadius: 12,
                  fontSize: 13,
                  text: localization.virtualCardDetailsFloatingButton,
                  onPressed: () {
                    Get.bottomSheet(
                      GenericCardTopUpBottomSheet(cardId: id),
                      isScrollControlled: true,
                    );
                  },
                ),
              ),
      );
    });
  }
}
