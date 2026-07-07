import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_transaction_controller.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class VirtualCardTransaction extends StatefulWidget {
  const VirtualCardTransaction({super.key});

  @override
  State<VirtualCardTransaction> createState() => _VirtualCardTransactionState();
}

class _VirtualCardTransactionState extends State<VirtualCardTransaction> {
  final String cardId = Get.arguments?["card_id"] ?? "";
  final VirtualCardTransactionController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.fetchCardTransactions(cardId: cardId);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsetsDirectional.only(end: 18.w),
            child: CommonAppBar(
              title: localization!.virtualCardTransactionAppBarTitle,
              rightSideWidget: CommonButton(
                text: localization.virtualCardTransactionSyncButton,
                borderRadius: 100,
                width: 60,
                height: 28,
                fontSize: 12,
                backgroundColor: AppColors.success,
                onPressed: () {
                  controller.fetchCardTransactionsBySync(
                    cardId: cardId,
                    isSync: "true",
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchCardTransactions(cardId: cardId),
              color: AppColors.lightPrimary,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoading();
                }

                if (controller.cardTransactionList.isEmpty) {
                  return NoDataFound();
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: controller.cardTransactionList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final transaction = controller.cardTransactionList[index];
                    final isSuccess = transaction.status == "Success";
                    final isPending = transaction.status == "Pending";

                    final statusColor = isSuccess
                        ? AppColors.success
                        : isPending
                        ? AppColors.warning
                        : AppColors.error;

                    final icon = isSuccess
                        ? Icons.check_circle_rounded
                        : isPending
                        ? Icons.pending_rounded
                        : Icons.error_rounded;

                    return Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: statusColor.withValues(alpha: 0.1),
                            ),
                            child: Icon(icon, color: statusColor, size: 20.w),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        transaction.merchantData!.name!,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                          color: AppColors.lightTextPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "${transaction.amount} ${transaction.currency}",
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: isSuccess
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        color: statusColor.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      child: Text(
                                        transaction.status!,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10.sp,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        transaction.created!,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.sp,
                                          color: AppColors.lightTextTertiary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
