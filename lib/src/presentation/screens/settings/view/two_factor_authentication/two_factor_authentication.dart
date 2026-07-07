import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/disable_2_fa_section.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/disable_and_change_passcode_section.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/enable_2_fa_section.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/generate_2_fa_section.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/generate_passcode_section.dart';

class TwoFactorAuthentication extends StatefulWidget {
  const TwoFactorAuthentication({super.key});

  @override
  State<TwoFactorAuthentication> createState() =>
      _TwoFactorAuthenticationState();
}

class _TwoFactorAuthenticationState extends State<TwoFactorAuthentication> {
  final TwoFactorAuthenticationController controller = Get.find();
  final SettingsService settingsService = Get.find();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchUser();
    if (controller.userModel.value.data?.google2faSecret != null) {
      await controller.getQRCode();
    }
    controller.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              CommonAppBar(
                title: localization.twoFactorAuthenticationScreenTitle,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.lightPrimary,
                  onRefresh: () => loadData(),
                  child: Obx(() {
                    if (controller.isLoading.value ||
                        controller.isGenerateQRCodeLoading.value ||
                        controller.isGeneratePasscodeLoading.value ||
                        controller.isChangePasscodeLoading.value ||
                        controller.isDisablePasscodeLoading.value) {
                      return const CommonLoading();
                    }

                    return SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          controller.userModel.value.data?.twoFa == true
                              ? Disable2FaSection()
                              : controller
                                        .userModel
                                        .value
                                        .data
                                        ?.google2faSecret ==
                                    null
                              ? Generate2FaSection()
                              : Enable2FaSection(),
                          SizedBox(height: 30),
                          settingsService.getSetting("passcode_verification") ==
                                  "1"
                              ? controller.userModel.value.data!.passcode == "0"
                                    ? GeneratePasscodeSection()
                                    : DisableAndChangePasscodeSection()
                              : SizedBox.shrink(),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible:
                  controller.isEnableTwoFaLoading.value ||
                  controller.isDisableTwoFaLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
