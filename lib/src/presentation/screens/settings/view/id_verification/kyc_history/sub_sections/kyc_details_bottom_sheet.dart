import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/kyc_history_model.dart';

class KycDetailsBottomSheet extends StatelessWidget {
  final KycHistoryData historyData;

  const KycDetailsBottomSheet({super.key, required this.historyData});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      historyData.type ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.lightTextPrimary,
                        overflow: TextOverflow.visible,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          localization.kycDetailsStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.lightTextTertiary,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          historyData.status == "pending"
                              ? localization.kycDetailsStatusPending
                              : historyData.status == "approved"
                              ? localization.kycDetailsStatusApproved
                              : historyData.status == "rejected"
                              ? localization.kycDetailsStatusRejected
                              : "",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0,
                            color: historyData.status == "pending"
                                ? AppColors.warning
                                : historyData.status == "approved"
                                ? AppColors.success
                                : historyData.status == "rejected"
                                ? AppColors.error
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          localization.kycDetailsCreatedAt,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.lightTextTertiary,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          DateFormat(
                            "dd MMM yyyy hh:mm a",
                          ).format(DateTime.parse(historyData.createdAt!)),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.lightTextTertiary,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),

                    if (historyData.message != null &&
                        historyData.message!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.lightBackground,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.kycDetailsMessageFromAdmin,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: 0,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  historyData.message ?? "",
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontSize: 14,
                                    color: AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    if (historyData.submittedData != null &&
                        historyData.submittedData!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.lightBackground,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  localization.kycDetailsSubmittedData,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 0,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                ...historyData.submittedData!.entries.map((
                                  entry,
                                ) {
                                  final key = entry.key;
                                  final value = entry.value;

                                  bool isImage =
                                      value is String &&
                                      value.startsWith('http') &&
                                      (value.endsWith('.jpg') ||
                                          value.endsWith('.png') ||
                                          value.endsWith('.jpeg'));

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!isImage)
                                        Row(
                                          children: [
                                            Text(
                                              "$key: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color:
                                                    AppColors.lightTextPrimary,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                            if (!isImage) SizedBox(height: 10),
                                            Text(
                                              value.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color:
                                                    AppColors.lightTextPrimary,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      SizedBox(height: 20),
                                      if (isImage)
                                        Text(
                                          "$key: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.lightTextPrimary,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      if (isImage) SizedBox(height: 10),
                                      if (isImage)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            value,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          localization.kycDetailsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.lightTextPrimary.withValues(alpha: 0.1),
            AppColors.white,
          ],
        ),
      ),
    );
  }
}
