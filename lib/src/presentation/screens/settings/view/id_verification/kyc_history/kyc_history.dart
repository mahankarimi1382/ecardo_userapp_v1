import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
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
    HapticFeedback.lightImpact();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: const CommonDefaultAppBar(),
        body: Column(
          children: [
            SizedBox(height: AppSpacing.cardGap),
            CommonAppBar(
              title: localization.kycHistoryScreenTitle,
              isBackLogicApply: true,
              backLogicFunction: _handleBack,
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: RefreshIndicator(
                color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                onRefresh: () => controller.fetchKycHistory(),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingSkeleton(isDark);
                  }

                  if (controller.hasError.value) {
                    return _buildErrorState(context);
                  }

                  if (controller.kycHistoryList.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.separated(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.page,
                      AppSpacing.xs,
                      AppSpacing.page,
                      AppSpacing.bottomSafe(context, AppSpacing.xxl),
                    ),
                    itemBuilder: (context, index) {
                      final KycHistoryData history =
                          controller.kycHistoryList[index];

                      return Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.8,
                          ),
                          boxShadow: !isDark
                              ? [
                                  BoxShadow(
                                    color: AppColors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Status icon bubble
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _statusColor(history.status)
                                    .withValues(alpha: isDark ? 0.22 : 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _statusIcon(history.status),
                                color: _statusColor(history.status),
                                size: 22,
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _typeLabel(history, localization, context),
                                    style: AppTextStyles.titleSmall.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: primaryTextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    history.createdAt != null && history.createdAt!.isNotEmpty
                                        ? DateFormat("dd MMM yyyy · hh:mm a").format(
                                            DateTime.tryParse(history.createdAt!) ?? DateTime.now(),
                                          )
                                        : "",
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Status pill — colored dot + label
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(history.status)
                                          .withValues(alpha: isDark ? 0.20 : 0.10),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
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
                                          style: AppTextStyles.labelSmall.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: _statusColor(history.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            CommonButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Get.bottomSheet(
                                  KycDetailsBottomSheet(historyData: history),
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                );
                              },
                              borderRadius: AppSpacing.radiusSm,
                              width: 60,
                              height: 34,
                              text: localization.kycHistoryViewButton,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: AppSpacing.sm);
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

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.page),
      itemCount: 4,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => Container(
        height: 90,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return EcardoErrorView(
      title: l10nPick(
        context,
        en: 'Failed to load KYC history',
        fa: 'خطا در دریافت تاریخچه احراز هویت',
        ar: 'فشل في تحميل سجل التحقق',
        zh: '加载身份验证历史失败',
      ),
      message: l10nPick(
        context,
        en: 'Please check your connection and tap retry.',
        fa: 'لطفاً اتصال اینترنت را بررسی کرده و دوباره تلاش کنید.',
        ar: 'يرجى التحقق من اتصالك والمحاولة مجدداً.',
        zh: '请检查网络连接后重试。',
      ),
      onRetry: () => controller.fetchKycHistory(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EcardoEmptyState(
      animateGlow: false,
      iconData: Icons.history_rounded,
      title: l10nPick(
        context,
        en: 'No KYC History',
        fa: 'سابقه احراز هویت یافت نشد',
        ar: 'لا يوجد سجل للتحقق',
        zh: '暂无身份验证记录',
      ),
      description: l10nPick(
        context,
        en: 'You have not submitted any verification documents yet.',
        fa: 'شما هنوز هیچ مدرکی برای احراز هویت ارسال نکرده‌اید.',
        ar: 'لم تقم بتقديم أي مستندات تحقق بعد.',
        zh: '您尚未提交任何验证文件。',
      ),
      primaryActionLabel: l10nPick(
        context,
        en: 'Start Verification',
        fa: 'شروع احراز هویت',
        ar: 'بدء التحقق',
        zh: '开始验证',
      ),
      onPrimaryAction: () => Get.toNamed(BaseRoute.idVerification),
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
