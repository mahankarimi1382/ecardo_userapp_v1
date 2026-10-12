import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_transaction_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/no_data_found.dart';

class VirtualCardTransaction extends StatefulWidget {
  const VirtualCardTransaction({super.key});

  @override
  State<VirtualCardTransaction> createState() => _VirtualCardTransactionState();
}

class _VirtualCardTransactionState extends State<VirtualCardTransaction> {
  final String cardId = Get.arguments?["card_id"] ?? "";
  final String? endpoint = Get.arguments?["endpoint"]?.toString();
  final VirtualCardTransactionController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.fetchCardTransactions(cardId: cardId, endpoint: endpoint);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
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
                  HapticFeedback.lightImpact();
                  controller.fetchCardTransactionsBySync(
                    cardId: cardId,
                    isSync: "true",
                    endpoint: endpoint,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchCardTransactions(
                cardId: cardId,
                endpoint: endpoint,
              ),
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoading();
                }

                if (controller.cardTransactionList.isEmpty) {
                  return const NoDataFound();
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: controller.cardTransactionList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
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

                    return Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42.w,
                            height: 42.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: statusColor.withValues(alpha: isDark ? 0.20 : 0.12),
                            ),
                            child: Icon(icon, color: statusColor, size: 22.w),
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
                                        transaction.merchantData?.name ?? '--',
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5.sp,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "${transaction.amount ?? '0'} ${transaction.currency ?? ''}",
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5.sp,
                                        color: isSuccess
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                        color: statusColor.withValues(
                                          alpha: isDark ? 0.20 : 0.10,
                                        ),
                                      ),
                                      child: Text(
                                        transaction.status ?? '--',
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10.5.sp,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        transaction.created ?? '',
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11.5.sp,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
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
