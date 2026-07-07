import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';
import 'package:qunzo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:qunzo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final localization = AppLocalizations.of(context)!;

    return Obx(
      () => Column(
        children: [
          SectionHeader(
            sectionName: localization.recentTransactionsTitle,
            onTap: () => Get.toNamed(BaseRoute.transactions),
          ),
          const SizedBox(height: 10),
          homeController.transactionsModel.value.data!.transactions!.isEmpty
              ? NoDataFound()
              : Container(
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.white,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final Transactions transaction = homeController
                          .transactionsModel
                          .value
                          .data!
                          .transactions![index];

                      return GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            RecentTransactionDetails(transaction: transaction),
                          );
                        },
                        child: Container(
                          color: AppColors.transparent,
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color:
                                            TransactionDynamicColor.getTransactionColor(
                                              transaction.type,
                                            ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Image.asset(
                                          TransactionDynamicIcon.getTransactionIcon(
                                            transaction.type,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.type ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15.5,
                                              color: AppColors.lightTextPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            transaction.createdAt!
                                                .split(",")
                                                .first,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontSize: 14,
                                              color:
                                                  AppColors.lightTextTertiary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Transform.translate(
                                        offset: const Offset(0, -2),
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          transaction.isPlus == true
                                              ? "+"
                                              : "-",
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: transaction.isPlus == true
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        textAlign: TextAlign.center,
                                        "${transaction.isCrypto == true ? "" : transaction.trxCurrencySymbol}",
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: transaction.isPlus == true
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    transaction.isCrypto == true
                                        ? "${transaction.amount} ${transaction.trxCurrencyCode}"
                                        : "${transaction.amount}",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: transaction.isPlus == true
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.10,
                          ),
                          height: 0,
                        ),
                      );
                    },
                    itemCount: homeController
                        .transactionsModel
                        .value
                        .data!
                        .transactions!
                        .length,
                  ),
                ),
        ],
      ),
    );
  }
}
