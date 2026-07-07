import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/apply_verification/controller/apply_verification_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/widgets/create_ad_eligibility_failed_section.dart';

class ApplyVerificationPlaceholderSection extends StatelessWidget {
  final ApplyVerificationController controller;

  const ApplyVerificationPlaceholderSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Obx(() {
      if (controller.isLoading.value) {
        return const CommonLoading();
      }

      if (controller.isVerified) {
        return _buildRefreshable(
          child: _buildStatusOnlyScrollable(
            child: _buildStatusCard(
              borderColor: AppColors.success,
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              title: localization.p2pYouAreVerifiedTrader,
              subtitle: localization.p2pVerifiedTraderStatusActive,
            ),
          ),
        );
      }

      if (controller.isPending) {
        return _buildRefreshable(
          child: _buildStatusOnlyScrollable(
            child: _buildStatusCard(
              borderColor: AppColors.warning,
              backgroundColor: AppColors.warning.withValues(alpha: 0.05),
              title: localization.p2pVerificationUnderReview,
              subtitle:
                  '${localization.p2pVerificationRequestUnderReview}\n${localization.p2pSubmittedOn}: ${_formatDate(controller.lastApplication?.createdAt)}',
            ),
          ),
        );
      }

      if (controller.isEligibleToApply) {
        return _buildRefreshable(child: _buildApplyFormCard(localization));
      }

      if (controller.isNotEligible) {
        return _buildRefreshable(
          child: _buildStatusOnlyScrollable(
            child: CreateAdEligibilityFailedSection(
              reasons: controller.verificationData?.reasons ?? <String>[],
            ),
          ),
        );
      }

      return _buildRefreshable(
        child: _buildStatusOnlyScrollable(
          child: _buildStatusCard(
            borderColor: AppColors.lightTextPrimary.withValues(alpha: 0.18),
            backgroundColor: AppColors.lightBackground,
            title: localization.p2pVerificationDataUnavailable,
            subtitle: localization.p2pPleaseRefreshAndTryAgain,
          ),
        ),
      );
    });
  }

  Widget _buildRefreshable({required Widget child}) {
    return RefreshIndicator(
      color: AppColors.lightPrimary,
      onRefresh: controller.fetchVerificationStatus,
      child: child,
    );
  }

  Widget _buildStatusOnlyScrollable({required Widget child}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [child],
    );
  }

  Widget _buildStatusCard({
    required Color borderColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
            color: backgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplyFormCard(AppLocalizations localization) {
    final lastStatus = (controller.lastApplication?.status ?? '').toLowerCase();
    final isRejected = lastStatus == 'rejected';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(18.w, 8.h, 18.w, 24.h),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRejected) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.p2pPreviousVerificationRejected,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: AppColors.error,
                        ),
                      ),
                      if ((controller.lastApplication?.message ?? '')
                          .trim()
                          .isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          '${localization.p2pReason}: ${controller.lastApplication?.message ?? ''}',
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: AppColors.lightTextPrimary.withValues(
                              alpha: 0.60,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 6.h),
                      Text(
                        localization.p2pCorrectInformationApplyAgain,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
              ],
              Text(
                localization.p2pApplyVerificationTitle,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                localization.p2pFillRequiredFieldsVerification,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.75),
                ),
              ),
              SizedBox(height: 16.h),
              if (controller.dynamicFieldControllers.isEmpty)
                Text(
                  localization.p2pNoVerificationFormFieldsFound,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.72),
                  ),
                )
              else
                ...controller.dynamicFieldControllers.entries.map((entry) {
                  final fieldName = entry.key;
                  final fieldData = entry.value;
                  final fieldController =
                      fieldData['controller'] as TextEditingController;
                  final validation =
                      fieldData['validation'] as String? ?? 'nullable';
                  final type = fieldData['type'] as String? ?? 'text';
                  final instructions =
                      fieldData['instructions'] as String? ?? '';
                  final isRequired = controller.isRequiredField(validation);
                  final isTextArea = type == 'textarea';
                  final isFile = controller.isFileFieldType(type);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonRequiredLabelAndDynamicField(
                          labelText: fieldName,
                          isLabelRequired: isRequired,
                          dynamicField: isFile
                              ? _buildUploadSection(
                                  title: fieldName,
                                  fieldName: fieldName,
                                  type: type,
                                )
                              : CommonTextInputField(
                                  backgroundColor: AppColors.transparent,
                                  hintText: AppLocalizations.of(
                                    Get.context!,
                                  )!.p2pEnterField(fieldName),
                                  controller: fieldController,
                                  maxLine: isTextArea ? 5 : 1,
                                  keyboardType: isTextArea
                                      ? TextInputType.multiline
                                      : TextInputType.text,
                                ),
                        ),
                        if (instructions.trim().isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            instructions,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp,
                              color: AppColors.lightTextPrimary.withValues(
                                alpha: 0.66,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              if (controller.dynamicFieldControllers.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Obx(
                  () => CommonButton(
                    text: localization.p2pSubmitVerification,
                    isLoading: controller.isSubmitting.value,
                    width: double.infinity,
                    onPressed: controller.onSubmitPressed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String fieldName,
    required String type,
  }) {
    return Obx(() {
      final selectedFile = controller.selectedFiles[fieldName];

      return GestureDetector(
        onTap: () => controller.pickFile(fieldName, type),
        child: SizedBox(
          width: double.infinity,
          height: selectedFile != null ? 120 : null,
          child: selectedFile != null
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: selectedFile.isImage
                            ? Image.file(selectedFile.file, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.lightBackground,
                                alignment: Alignment.center,
                                child: Text(
                                  selectedFile.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 4.h,
                      end: 4.w,
                      child: GestureDetector(
                        onTap: () => controller.removeSelectedFile(fieldName),
                        child: Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14.w,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      PngAssets.attachFileTwo,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          PngAssets.commonUploadIcon,
                          width: 20,
                          fit: BoxFit.contain,
                          color: AppColors.lightTextTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );
    });
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }
}
