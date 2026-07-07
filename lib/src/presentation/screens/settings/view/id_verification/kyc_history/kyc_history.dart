import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/kyc_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/kyc_history_model.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/id_verification/kyc_history/sub_sections/kyc_details_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class KycHistory extends StatefulWidget {
  const KycHistory({super.key});

  @override
  State<KycHistory> createState() => _KycHistoryState();
}

class _KycHistoryState extends State<KycHistory> {
  final KycHistoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16),
          CommonAppBar(title: localization.kycHistoryScreenTitle),
          SizedBox(height: 30),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchKycHistory(),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return CommonLoading();
                }

                if (controller.kycHistoryList.isEmpty) {
                  return NoDataFound();
                }

                return ListView.separated(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
                  itemBuilder: (context, index) {
                    final KycHistoryData history =
                        controller.kycHistoryList[index];

                    return Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.1),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  history.type ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: AppColors.lightTextPrimary,
                                    letterSpacing: 0,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${localization.kycHistoryDate} ${DateFormat("dd MMM yyyy hh:mm a").format(DateTime.parse(history.createdAt!))}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.lightTextTertiary,
                                    letterSpacing: 0,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      localization.kycHistoryStatus,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.lightTextTertiary,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    Text(
                                      history.status == "pending"
                                          ? localization.kycHistoryStatusPending
                                          : history.status == "approved"
                                          ? localization
                                                .kycHistoryStatusApproved
                                          : localization
                                                .kycHistoryStatusRejected,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        letterSpacing: 0,
                                        color: history.status == "pending"
                                            ? AppColors.warning
                                            : history.status == "approved"
                                            ? AppColors.success
                                            : history.status == "rejected"
                                            ? AppColors.error
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CommonButton(
                            onPressed: () {
                              Get.bottomSheet(
                                KycDetailsBottomSheet(historyData: history),
                              );
                            },
                            borderRadius: 8,
                            width: 50,
                            height: 30,
                            text: localization.kycHistoryViewButton,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  itemCount: controller.kycHistoryList.length,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
