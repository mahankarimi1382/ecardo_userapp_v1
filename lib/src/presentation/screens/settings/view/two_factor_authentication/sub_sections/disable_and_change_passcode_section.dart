import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/two_factor_authentication/sub_sections/change_passcode_bottom_sheet.dart';

/// Passcode is mandatory and unique — user may only change it, never disable.
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
            const SizedBox(height: 12),
            Text(
              localization.generatePasscodeSectionDescription,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 24),
            CommonButton(
              onPressed: () async {
                Get.bottomSheet(const ChangePasscodeBottomSheet());
              },
              width: double.infinity,
              text: localization.disableChangePasscodeButtonChange,
              borderRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
