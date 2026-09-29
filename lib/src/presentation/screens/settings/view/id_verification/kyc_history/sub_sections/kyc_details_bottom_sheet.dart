import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/kyc_history_model.dart';

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
                      _typeLabel(historyData.type, context, localization),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.lightTextPrimary,
                        overflow: TextOverflow.visible,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                        const SizedBox(width: 5),
                        Text(
                          _statusText(historyData.status, localization, context),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0,
                            color: _statusColor(historyData.status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                        const SizedBox(width: 5),
                        Text(
                          historyData.createdAt != null && historyData.createdAt!.isNotEmpty
                              ? DateFormat("dd MMM yyyy hh:mm a").format(
                                  DateTime.tryParse(historyData.createdAt!) ?? DateTime.now(),
                                )
                              : "",
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
                                              "${_fieldLabel(key, context)}: ",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color:
                                                    AppColors.lightTextPrimary,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                            if (!isImage) const SizedBox(height: 10),
                                            Expanded(
                                              child: Text(
                                                value.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.lightTextPrimary,
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 20),
                                      if (isImage)
                                        Text(
                                          "${_fieldLabel(key, context)}: ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.lightTextPrimary,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      if (isImage) const SizedBox(height: 10),
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
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
