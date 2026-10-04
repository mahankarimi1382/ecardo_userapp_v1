import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/kyc_history_model.dart';

class KycDetailsBottomSheet extends StatelessWidget {
  final KycHistoryData historyData;

  const KycDetailsBottomSheet({super.key, required this.historyData});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextTertiary;
    final innerBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(24),
            topEnd: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, localization, isDark, primaryTextColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(historyData.type, context, localization),
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          localization.kycDetailsStatus,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(historyData.status)
                                .withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            _statusText(historyData.status, localization, context),
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _statusColor(historyData.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          localization.kycDetailsCreatedAt,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          historyData.createdAt != null && historyData.createdAt!.isNotEmpty
                              ? DateFormat("dd MMM yyyy · hh:mm a").format(
                                  DateTime.tryParse(historyData.createdAt!) ?? DateTime.now(),
                                )
                              : "",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),

                    if (historyData.message != null &&
                        historyData.message!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          color: innerBg,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.kycDetailsMessageFromAdmin,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              historyData.message ?? "",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: secondaryTextColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (historyData.submittedData != null &&
                        historyData.submittedData!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          color: innerBg,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.kycDetailsSubmittedData,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            ...historyData.submittedData!.entries.map((entry) {
                              final key = entry.key;
                              final value = entry.value;

                              bool isImage = value is String &&
                                  value.startsWith('http') &&
                                  (value.endsWith('.jpg') ||
                                      value.endsWith('.png') ||
                                      value.endsWith('.jpeg'));

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isImage)
                                      Row(
                                        children: [
                                          Text(
                                            "${_fieldLabel(key, context)}: ",
                                            style: AppTextStyles.bodySmall.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              value.toString(),
                                              style: AppTextStyles.bodySmall.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: primaryTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (isImage) ...[
                                      Text(
                                        "${_fieldLabel(key, context)}: ",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                        child: Image.network(
                                          value,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.bottomSafe(context, 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Localization helpers ──

  String _statusText(String? status, AppLocalizations loc, BuildContext context) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'completed':
        return loc.kycDetailsStatusApproved;
      case 'pending':
      case 'in_review':
      case 'under_review':
      case 'processing':
        return loc.kycDetailsStatusPending;
      case 'rejected':
      case 'failed':
      case 'declined':
        return loc.kycDetailsStatusRejected;
      case 'draft':
        return l10nPick(context, en: 'Draft', fa: 'پیش‌نویس', ar: 'مسودة', zh: '草稿');
      default:
        return status ?? '';
    }
  }

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

  String _typeLabel(String? type, BuildContext context, AppLocalizations loc) {
    final raw = (type ?? '').trim();
    final match = RegExp(r'level[_\s-]*(\d+)').firstMatch(raw.toLowerCase());
    if (match != null) {
      final level = int.tryParse(match.group(1)!);
      if (level != null) return loc.kycUpgradeLevelChip(level);
    }
    final lower = raw.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '_');
    if (lower.contains('passport')) {
      return l10nPick(context, en: 'Passport Verification', fa: 'احراز هویت گذرنامه', ar: 'التحقق من جواز السفر', zh: '护照验证');
    }
    if (lower.contains('nid') || lower.contains('national')) {
      return l10nPick(context, en: 'National ID Verification', fa: 'احراز هویت کارت ملی', ar: 'التحقق من الهوية الوطنية', zh: '国民身份证验证');
    }
    if (raw.isEmpty) {
      return l10nPick(context, en: 'Identity Verification', fa: 'احراز هویت', ar: 'التحقق من الهوية', zh: '身份验证');
    }
    final spaced = raw.replaceAll('_', ' ').replaceAll('-', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  String _fieldLabel(String key, BuildContext context) {
    final lower = key.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '_');
    if (lower == 'nid_front' || lower == 'national_id_front' || lower == 'national_id_f') {
      return l10nPick(context, en: 'National ID (Front)', fa: 'کارت ملی (رو)', ar: 'الهوية الوطنية (الوجه)', zh: '身份证 (正面)');
    }
    if (lower == 'nid_back' || lower == 'national_id_back' || lower == 'national_id_b') {
      return l10nPick(context, en: 'National ID (Back)', fa: 'کارت ملی (پشت)', ar: 'الهوية الوطنية (الظهر)', zh: '身份证 (背面)');
    }
    if (lower == 'passport' || lower == 'pass') {
      return l10nPick(context, en: 'Passport', fa: 'گذرنامه', ar: 'جواز السفر', zh: '护照');
    }
    if (lower == 'selfie' || lower == 'selfie_image') {
      return l10nPick(context, en: 'Selfie Photo', fa: 'تصویر سلفی', ar: 'صورة شخصية', zh: '自拍照');
    }
    if (lower == 'address_proof' || lower == 'address' || lower == 'utility_bill') {
      return l10nPick(context, en: 'Address Document', fa: 'مدرک نشانی', ar: 'مستند العنوان', zh: '地址文件');
    }
    if (lower == 'trade_license') {
      return l10nPick(context, en: 'Trade License', fa: 'جواز کسب / پروانه تجاری', ar: 'الرخصة التجارية', zh: '营业执照');
    }
    if (lower == 'driving_license') {
      return l10nPick(context, en: 'Driving License', fa: 'گواهینامه رانندگی', ar: 'رخصة القيادة', zh: '驾驶执照');
    }
    if (lower == 'birth_certificate') {
      return l10nPick(context, en: 'Birth Certificate', fa: 'شناسنامه', ar: 'شهادة الميلاد', zh: '出生证明');
    }
    if (lower == 'first_name') {
      return l10nPick(context, en: 'First Name', fa: 'نام', ar: 'الاسم الأول', zh: '名');
    }
    if (lower == 'last_name') {
      return l10nPick(context, en: 'Last Name', fa: 'نام خانوادگی', ar: 'اسم العائلة', zh: '姓');
    }
    if (lower == 'national_code' || lower == 'national_id') {
      return l10nPick(context, en: 'National Code', fa: 'کد ملی', ar: 'الرقم الوطني', zh: '国民号码');
    }
    final spaced = key.replaceAll('_', ' ').replaceAll('-', ' ');
    return spaced.isNotEmpty ? (spaced[0].toUpperCase() + spaced.substring(1)) : key;
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations localization,
    bool isDark,
    Color primaryTextColor,
  ) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.warmWhite : AppColors.deepBlack).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          localization.kycDetailsTitle,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 14),
        Divider(
          height: 1,
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
