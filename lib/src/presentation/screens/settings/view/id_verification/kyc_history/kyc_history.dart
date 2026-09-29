import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/kyc_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/kyc_history_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/id_verification/kyc_history/sub_sections/kyc_details_bottom_sheet.dart';

class KycHistory extends StatefulWidget {
  const KycHistory({super.key});

  @override
  State<KycHistory> createState() => _KycHistoryState();
}

class _KycHistoryState extends State<KycHistory> {
  final KycHistoryController controller = Get.find();

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAllNamed(BaseRoute.navigation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final canPop = Navigator.canPop(context);

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        body: Column(
          children: [
            SizedBox(height: 16),
            CommonAppBar(
              title: localization.kycHistoryScreenTitle,
              isBackLogicApply: true,
              backLogicFunction: _handleBack,
            ),
          SizedBox(height: 30),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchKycHistory(),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoading();
                }

                if (controller.hasError.value) {
                  return _buildErrorState(context);
                }

                if (controller.kycHistoryList.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                  itemBuilder: (context, index) {
                    final KycHistoryData history =
                        controller.kycHistoryList[index];

                    return Container(
                      padding: const EdgeInsetsDirectional.symmetric(
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
                                  _typeLabel(history, localization, context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.lightTextPrimary,
                                    letterSpacing: 0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  history.createdAt != null && history.createdAt!.isNotEmpty
                                      ? DateFormat("dd MMM yyyy · hh:mm a").format(
                                          DateTime.tryParse(history.createdAt!) ?? DateTime.now(),
                                        )
                                      : "",
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
                                        _statusLabel(history.status, localization, context),
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
                    return const SizedBox(height: 10);
                  },
                  itemCount: controller.kycHistoryList.length,
                );
              }),
            ),
          ),
          ],
        ),
      ),
    );
  }

  // ── Error & Empty State widgets ──

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10nPick(
                context,
                en: 'Failed to load KYC history',
                fa: 'خطا در دریافت تاریخچه احراز هویت',
                ar: 'فشل في تحميل سجل التحقق',
                zh: '加载身份验证历史失败',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            CommonButton(
              onPressed: () => controller.fetchKycHistory(),
              width: 140,
              height: 40,
              borderRadius: 10,
              text: l10nPick(
                context,
                en: 'Retry',
                fa: 'تلاش مجدد',
                ar: 'إعادة المحاولة',
                zh: '重试',
              ),
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.lightPrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10nPick(
                context,
                en: 'No KYC History',
                fa: 'سابقه احراز هویت یافت نشد',
                ar: 'لا يوجد سجل للتحقق',
                zh: '暂无身份验证记录',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10nPick(
                context,
                en: 'You have not submitted any verification documents yet.',
                fa: 'شما هنوز هیچ مدرکی برای احراز هویت ارسال نکرده‌اید.',
                ar: 'لم تقم بتقديم أي مستندات تحقق بعد.',
                zh: '您尚未提交任何验证文件。',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 24),
            CommonButton(
              onPressed: () => Get.toNamed(BaseRoute.idVerification),
              width: 180,
              height: 42,
              borderRadius: 10,
              text: l10nPick(
                context,
                en: 'Start Verification',
                fa: 'شروع احراز هویت',
                ar: 'بدء التحقق',
                zh: '开始验证',
              ),
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ── Presentational helpers ──

  Color _statusColor(String? status) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'in_review':
      case 'under_review':
      case 'processing':
        return AppColors.warning;
      case 'rejected':
      case 'failed':
      case 'declined':
        return AppColors.error;
      default:
        return AppColors.lightTextTertiary;
    }
  }

  IconData _statusIcon(String? status) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'completed':
        return Icons.check_circle_rounded;
      case 'pending':
      case 'in_review':
      case 'under_review':
      case 'processing':
        return Icons.hourglass_top_rounded;
      case 'rejected':
      case 'failed':
      case 'declined':
        return Icons.cancel_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String _statusLabel(String? status, AppLocalizations localization, BuildContext context) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'completed':
        return localization.kycHistoryStatusApproved;
      case 'pending':
      case 'in_review':
      case 'under_review':
      case 'processing':
        return localization.kycHistoryStatusPending;
      case 'rejected':
      case 'failed':
      case 'declined':
        return localization.kycHistoryStatusRejected;
      case 'draft':
        return l10nPick(context, en: 'Draft', fa: 'پیش‌نویس', ar: 'مسودة', zh: '草稿');
      default:
        return status ?? '';
    }
  }

  /// Server `type` values look like `level_2` — render them as the
  /// localized "Level n" chip; unknown shapes degrade to a readable localized key.
  String _typeLabel(KycHistoryData history, AppLocalizations localization, BuildContext context) {
    final raw = (history.type ?? '').trim();
    final match =
        RegExp(r'level[_\s-]*(\d+)').firstMatch(raw.toLowerCase());
    if (match != null) {
      final level = int.tryParse(match.group(1)!);
      if (level != null) return localization.kycUpgradeLevelChip(level);
    }
    final lower = raw.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '_');
    if (lower.contains('passport') || lower.contains('pass')) {
      return l10nPick(context, en: 'Passport', fa: 'گذرنامه', ar: 'جواز السفر', zh: '护照');
    }
    if (lower.contains('nid') || lower.contains('national') || lower.contains('melli')) {
      return l10nPick(context, en: 'National ID', fa: 'کارت ملی', ar: 'الهوية الوطنية', zh: '国民身份证');
    }
    if (lower.contains('license') || lower.contains('driving')) {
      return l10nPick(context, en: 'Driving License', fa: 'گواهینامه رانندگی', ar: 'رخصة القيادة', zh: '驾驶执照');
    }
    if (lower.contains('identity') || lower.contains('id_card')) {
      return l10nPick(context, en: 'Identity Card', fa: 'کارت شناسایی', ar: 'بطاقة الهوية', zh: '身份证');
    }
    if (lower.contains('address') || lower.contains('utility') || lower.contains('bill')) {
      return l10nPick(context, en: 'Proof of Address', fa: 'تأییدیه نشانی', ar: 'إثبات العنوان', zh: '地址证明');
    }
    if (lower.contains('selfie')) {
      return l10nPick(context, en: 'Selfie Photo', fa: 'تصویر سلفی', ar: 'صورة شخصية', zh: '自拍照');
    }
    if (raw.isEmpty) {
      return l10nPick(context, en: 'Identity Verification', fa: 'احراز هویت', ar: 'التحقق من الهوية', zh: '身份验证');
    }
    final spaced = raw.replaceAll('_', ' ').replaceAll('-', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
