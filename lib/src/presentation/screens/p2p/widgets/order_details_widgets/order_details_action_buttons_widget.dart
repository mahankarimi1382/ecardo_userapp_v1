import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;

class OrderDetailsActionButtonsWidget extends StatelessWidget {
  final order_details.Data data;
  final P2pOrderDetailsController controller;

  const OrderDetailsActionButtonsWidget({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final status = (data.status ?? '').toLowerCase();
    if (!controller.isBuy) {
      switch (status) {
        case 'paid':
          return Column(
            children: [
              Obx(
                () => CommonButton(
                  text: localization.p2pPaymentReceived,
                  width: double.infinity,
                  isLoading: controller.isReleasingOrder.value,
                  backgroundColor: AppColors.success,
                  onPressed: () => controller.releaseOrder(),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          );
        default:
          return const SizedBox.shrink();
      }
    }

    switch (status) {
      case 'pending_payment':
        return Column(
          children: [
            Obx(
              () => CommonButton(
                text: localization.p2pTransferredNotifySeller,
                width: double.infinity,
                isLoading: controller.isMarkingPaid.value,
                onPressed: () => controller.markOrderPaid(),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => CommonButton(
                text: localization.p2pCancelOrder,
                width: double.infinity,
                isLoading: controller.isCancellingOrder.value,
                loadingColor: AppColors.lightPrimary,
                backgroundColor: AppColors.transparent,
                textColor: AppColors.lightTextPrimary.withValues(alpha: 0.8),
                borderColor: AppColors.lightPrimary.withValues(alpha: 0.45),
                borderWidth: 1.2,
                onPressed: () => _showCancelConfirmation(),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        );
      case 'paid':
        return Column(
          children: [
            Obx(
              () => CommonButton(
                text: localization.p2pDisputeOrder,
                width: double.infinity,
                isLoading: controller.isDisputingOrder.value,
                backgroundColor: AppColors.error,
                onPressed: () => _showDisputeReasonBottomSheet(),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showCancelConfirmation() {
    Get.bottomSheet(
      CommonAlertBottomSheet(
        title: AppLocalizations.of(Get.context!)!.p2pCancelOrder,
        message: AppLocalizations.of(Get.context!)!.p2pCancelOrderConfirmation,
        onCancel: Get.back,
        onConfirm: () async {
          Get.back();
          await controller.cancelOrder();
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showDisputeReasonBottomSheet() {
    final reasonController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 20.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(20.r),
              topEnd: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                AppLocalizations.of(context)!.p2pEnterDisputeReason,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
                  ),
                ),
                child: TextField(
                  controller: reasonController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: AppLocalizations.of(context)!.p2pWriteYourReason,
                  ),
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => CommonButton(
                  text: AppLocalizations.of(context)!.p2pEnterReason,
                  width: double.infinity,
                  isLoading: controller.isDisputingOrder.value,
                  onPressed: () async {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ToastHelper().showErrorToast(
                        AppLocalizations.of(Get.context!)!.p2pReasonIsRequired,
                      );
                      return;
                    }
                    final isSuccess = await controller.disputeOrder(
                      reason: reason,
                    );
                    if (isSuccess) {
                      Get.back();
                    }
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
