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
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';

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
                  // v56 BUG-K017: هدایت به صفحه‌ی ارسال مدارک KYC
                  final kycController = Get.find<KycLevelController>();
                  final nextLevel = kycController.nextLevel?.level ?? 2;
                  Get.toNamed(BaseRoute.kycSubmitWizard,
                      arguments: {'target_level': nextLevel});
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

}
