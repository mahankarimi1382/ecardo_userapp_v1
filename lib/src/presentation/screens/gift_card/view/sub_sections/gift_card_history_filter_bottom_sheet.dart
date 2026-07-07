import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_history_controller.dart';

class GiftCardHistoryFilterBottomSheet extends StatefulWidget {
  const GiftCardHistoryFilterBottomSheet({super.key});

  @override
  State<GiftCardHistoryFilterBottomSheet> createState() =>
      _GiftCardHistoryFilterBottomSheetState();
}

class _GiftCardHistoryFilterBottomSheetState
    extends State<GiftCardHistoryFilterBottomSheet> {
  final GiftCardHistoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: 280.h,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20.r),
          topEnd: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40.r,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              SizedBox(height: 30.h),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.giftCardHistoryFilterSearchLabel,
                isLabelRequired: false,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.searchController,
                    focusNode: controller.searchFocusNode,
                    isFocused: controller.isSearchFocused.value,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              CommonButton(
                onPressed: () {
                  controller.isFilter.value = true;
                  controller.fetchDynamicGiftCardHistory();
                  Get.back();
                },
                width: double.infinity,

                text: localization.giftCardHistoryFilterSearchButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
