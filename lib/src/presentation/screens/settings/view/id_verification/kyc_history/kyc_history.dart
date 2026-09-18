import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/kyc_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/kyc_history_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/id_verification/kyc_history/sub_sections/kyc_details_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/widgets/no_data_found.dart';

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
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Status icon bubble — scannable at a glance.
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _statusColor(history.status)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _statusIcon(history.status),
                              color: _statusColor(history.status),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _typeLabel(history, localization),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.lightTextPrimary,
                                    letterSpacing: 0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  DateFormat("dd MMM yyyy · hh:mm a").format(
                                    DateTime.parse(history.createdAt!),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: AppColors.lightTextTertiary,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                // Status pill — colored dot + label.
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(history.status)
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _statusColor(history.status),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _statusLabel(history.status, localization),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0,
                                          color: _statusColor(history.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          CommonButton(
                            onPressed: () {
                              Get.bottomSheet(
                                KycDetailsBottomSheet(historyData: history),
                              );
                            },
                            borderRadius: 10,
                            width: 54,
                            height: 32,
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

  // ── Presentational helpers ──
  //
  // Status casing is not guaranteed across backend responses — compare on a
  // normalized (trimmed, lower-cased) form (same pattern as the transaction
  // popup) and fall back to a neutral color for unknown values.

  Color _statusColor(String? status) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.lightTextTertiary;
    }
  }

  IconData _statusIcon(String? status) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String _statusLabel(String? status, AppLocalizations localization) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
        return localization.kycHistoryStatusApproved;
      case 'pending':
        return localization.kycHistoryStatusPending;
      case 'rejected':
        return localization.kycHistoryStatusRejected;
      default:
        return status ?? '';
    }
  }

  /// Server `type` values look like `level_2` — render them as the
  /// localized "Level n" chip; unknown shapes degrade to a readable key
  /// instead of raw snake_case.
  String _typeLabel(KycHistoryData history, AppLocalizations localization) {
    final raw = (history.type ?? '').trim();
    final match =
        RegExp(r'level[_\s-]*(\d+)').firstMatch(raw.toLowerCase());
    if (match != null) {
      final level = int.tryParse(match.group(1)!);
      if (level != null) return localization.kycUpgradeLevelChip(level);
    }
    if (raw.isEmpty) return '';
    final spaced = raw.replaceAll('_', ' ').replaceAll('-', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
