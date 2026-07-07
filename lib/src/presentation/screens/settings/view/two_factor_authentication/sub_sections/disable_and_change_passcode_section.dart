import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/change_passcode_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/disable_passcode_bottom_sheet.dart';

class DisableAndChangePasscodeSection extends StatelessWidget {
  const DisableAndChangePasscodeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightTextTertiary.withValues(alpha: 0.1),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.vpn_key,
                    color: AppColors.lightPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    localization!.disableChangePasscodeTitle,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    onPressed: () async {
                      Get.bottomSheet(ChangePasscodeBottomSheet());
                    },
                    width: double.infinity,
                    text: localization.disableChangePasscodeButtonChange,
                    fontSize: 13,
                    height: 35,
                    borderRadius: 10,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    onPressed: () async {
                      Get.bottomSheet(DisablePasscodeBottomSheet());
                    },
                    width: double.infinity,
                    text: localization.disableChangePasscodeButtonDisable,
                    backgroundColor: AppColors.error,
                    fontSize: 13,
                    height: 35,
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
