import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;

import '../p2p_appeal_order_screen.dart';

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
    /// اکشن‌های فروشنده (Seller)
    /// در وضعیت pending_payment: منتظر پرداخت خریدار - امکان کنسل
    /// در وضعیت paid: خریدار پرداخت کرده - دکمه تایید دریافت
    /// در وضعیت disputed: دعوی مطرح شده - فقط نمایش وضعیت
    if (!controller.isBuy) {
      switch (status) {
        case 'pending_payment':
          /// فروشنده می‌تواند سفارش را در انتظار پرداخت کنسل کند
          return Column(
            children: [
              Obx(
                () => CommonButton(
                  text: localization.p2pCancelOrder,
                  width: double.infinity,
                  isLoading: controller.isCancellingOrder.value,
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
          /// فروشنده پس از تایید پرداخت، دارایی را آزاد می‌کند
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
          /// سایر وضعیت‌ها (completed, cancelled, expired, disputed): اکشنی لازم نیست
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
    Get.to(() => P2pAppealOrderScreen(data: data, controller: controller));
  }
}
