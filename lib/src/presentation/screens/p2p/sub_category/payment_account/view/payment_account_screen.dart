import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/widgets/add_payment_method.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/widgets/delete_payment_account_dropdown_section.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/widgets/edit_payment_account.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/widgets/payment_account_details_bottom_sheet.dart';

import '../../../../../widgets/no_data_found.dart';
import '../controller/payment_account_controller.dart';

class PaymentAccountScreen extends GetView<PaymentAccountController> {
  const PaymentAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Obx(
      () => Stack(
        children: [
          if (controller.isAddMode.value)
            const AddPaymentMethod()
          else if (controller.isEditMode.value &&
              controller.selectedAccount.value != null)
            EditPaymentAccount(account: controller.selectedAccount.value!)
          else
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(18.w, 0, 18.w, 0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.p2pAllAccount,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: controller.isLoading.value
                        ? const CommonLoading()
                        : RefreshIndicator(
                            color: AppColors.lightPrimary,
                            onRefresh: controller.fetchPaymentAccounts,
                            child: Obx(() {
                              final accounts =
                                  controller
                                      .paymentAccountResponse
                                      .value
                                      .data
                                      ?.paymentAccounts ??
                                  [];

                              if (accounts.isEmpty) {
                                return ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 120),
                                    NoDataFound(),
                                  ],
                                );
                              }

                              return ListView.separated(
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemCount: accounts.length,
                                separatorBuilder: (_, _) {
                                  return Divider(
                                    height: 20.h,
                                    color: AppColors.lightTextPrimary
                                        .withValues(alpha: 0.12),
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final item = accounts[index];
                                  return _buildAccountItem(item, localization);
                                },
                              );
                            }),
                          ),
                  ),
                ],
              ),
            ),
          if (!controller.isEditMode.value && !controller.isAddMode.value)
            PositionedDirectional(
              end: 18.w,
              bottom: 40.h,
              child: GestureDetector(
                onTap: controller.onAddPaymentMethod,
                child: Container(
                  height: 40.h,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 20.w,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        localization.p2pAddPaymentMethod,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(PaymentAccount item, AppLocalizations localization) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  PaymentAccountDetailsBottomSheet(account: item),
                  isScrollControlled: true,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.paymentMethod?.name ?? '',
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.createdAt != null
                        ? item.createdAt!.toLocal().toString().split(' ')[0]
                        : '',
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => controller.onEditAccount(item),
            child: Container(
              width: 44.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  localization.p2pEdit,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: item.id == null
                ? null
                : () => Get.bottomSheet(
                    DeletePaymentAccountDropdownSection(
                      onPressed: () async {
                        Get.back();
                        await controller.deletePaymentAccount(
                          item.id.toString(),
                        );
                      },
                    ),
                  ),
            child: Container(
              width: 26.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.delete, size: 18.w, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
