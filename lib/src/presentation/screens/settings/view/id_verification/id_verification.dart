import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/id_verification_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_level_roadmap.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/kyc_level_binding.dart';

class IdVerification extends StatefulWidget {
  const IdVerification({super.key});

  @override
  State<IdVerification> createState() => _IdVerificationState();
}

class _IdVerificationState extends State<IdVerification> {
  final IdVerificationController controller = Get.find();

  Future<void> refreshData() async {
    await controller.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 18),
            child: CommonAppBar(
              title: localization.idVerificationScreenTitle,
              rightSideWidget: CommonButton(
                onPressed: () => Get.toNamed(BaseRoute.kycHistory),
                width: 120,
                height: 40,
                text: localization.idVerificationHistoryButton,
                borderRadius: 10,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CommonLoading();
              }

              return RefreshIndicator(
                color: AppColors.lightPrimary,
                onRefresh: () => refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            // v1.0.5: KYC Level Roadmap (نسخه جدید — نمایش سطوح بصری)
              KycLevelRoadmap(
                onLevelTap: () {
                  // هدایت به صفحه‌ی ارسال مدارک KYC
                },
              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
                        padding: const EdgeInsetsDirectional.only(
                          start: 18,
                          end: 18,
                          top: 16,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              localization.idVerificationCenterTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 0,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(
                              color: AppColors.black.withValues(alpha: 0.15),
                              height: 0,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  localization.idVerificationNothingToSubmit,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    final kyc = controller.userModel.value.data?.kyc ?? 0;
    final kycInfo = getKycStatusInfo(kyc: kyc);
    final localization = AppLocalizations.of(context)!;
    final isRejected = controller.userModel.value.data?.isRejected ?? false;
    final rejectionReason = controller.userModel.value.data?.rejectionReason;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: kycInfo.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(13),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: kycInfo.color,
            ),
            child: Icon(kycInfo.icon, color: AppColors.white),
          ),
          const SizedBox(height: 7),
          // Title
          Text(
            localization.idVerificationCenterTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: AppColors.lightTextPrimary,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          // Status message
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            child: Text(
              kycInfo.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.lightTextTertiary,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── KYC Progress Steps ──
          _buildKycSteps(kyc, localization),
          // ── Rejection reason (if rejected) ──
          if (isRejected && rejectionReason != null && rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejection Reason',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          rejectionReason,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── Next steps guidance ──
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            child: _buildNextStepsGuidance(kyc, localization),
          ),
        ],
      ),
    );
  }

  /// Build KYC progress steps (3 steps: Submit → Review → Verified)
  Widget _buildKycSteps(int kyc, AppLocalizations localization) {
    final steps = [
      {'label': 'Submit', 'icon': Icons.upload_file, 'done': kyc >= 2},
      {'label': 'Review', 'icon': Icons.rate_review, 'done': kyc == 1},
      {'label': 'Verified', 'icon': Icons.verified_user, 'done': kyc == 1},
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIdx = index ~/ 2;
            final isCompleted = steps[stepIdx]['done'] as bool;
            return Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 4),
                color: isCompleted ? kycColor(kyc) : AppColors.lightBorder,
              ),
            );
          }
          final stepIdx = index ~/ 2;
          final step = steps[stepIdx];
          final isDone = step['done'] as bool;
          final isCurrent = (kyc == 2 && stepIdx == 1) || (kyc == 0 && stepIdx == 0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? kycColor(kyc) : (isCurrent ? kycColor(kyc).withValues(alpha: 0.3) : AppColors.lightBorder),
                  border: isCurrent && !isDone ? Border.all(color: kycColor(kyc), width: 2) : null,
                ),
                child: Icon(
                  isDone ? Icons.check : step['icon'] as IconData,
                  color: isDone ? AppColors.white : (isCurrent ? kycColor(kyc) : AppColors.lightTextSecondary),
                  size: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                step['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent || isDone ? FontWeight.w700 : FontWeight.w400,
                  color: isDone || isCurrent ? kycColor(kyc) : AppColors.lightTextSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Show next steps guidance based on current KYC status
  Widget _buildNextStepsGuidance(int kyc, AppLocalizations localization) {
    String guidance;
    IconData icon;
    Color color;

    switch (kyc) {
      case 0:
        guidance = 'Your identity is not verified yet. Please submit your documents to unlock all features.';
        icon = Icons.info_outline;
        color = AppColors.warning;
        break;
      case 1:
        guidance = 'Your identity has been verified. You have full access to all features.';
        icon = Icons.check_circle_outline;
        color = AppColors.success;
        break;
      case 2:
        guidance = 'Your documents are under review. This usually takes 1-2 business days.';
        icon = Icons.hourglass_top;
        color = AppColors.warning;
        break;
      case 3:
        guidance = 'Your submission was rejected. Please review the reason above and resubmit.';
        icon = Icons.error_outline;
        color = AppColors.error;
        break;
      default:
        guidance = 'Please complete identity verification to unlock all features.';
        icon = Icons.info_outline;
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              guidance,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightTextPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color kycColor(int kyc) {
    switch (kyc) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }
}

class KycStatusInfo {
  final Color color;
  final IconData icon;
  final String message;

  KycStatusInfo({
    required this.color,
    required this.icon,
    required this.message,
  });
}

KycStatusInfo getKycStatusInfo({required int? kyc, context}) {
  final localization = AppLocalizations.of(context)!;

  switch (kyc) {
    case 1:
      return KycStatusInfo(
        color: AppColors.success,
        icon: Icons.check_circle_outline_outlined,
        message: localization.kycStatusVerified,
      );
    case 2:
      return KycStatusInfo(
        color: AppColors.warning,
        icon: Icons.warning_amber_outlined,
        message: localization.kycStatusPending,
      );
    case 3:
      return KycStatusInfo(
        color: AppColors.error,
        icon: Icons.error_outline_outlined,
        message: localization.kycStatusRejected,
      );
    case 4:
    default:
      return KycStatusInfo(
        color: AppColors.warning,
        icon: Icons.error_outline_outlined,
        message: localization.kycStatusNotSubmitted,
      );
  }
}
