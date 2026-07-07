import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/id_verification_controller.dart';

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
                            _buildVerificationSection(),
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
    final kyc = controller.userModel.value.data?.kyc;
    final kycInfo = getKycStatusInfo(kyc: kyc);
    final localization = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: kycInfo.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
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
        ],
      ),
    );
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
