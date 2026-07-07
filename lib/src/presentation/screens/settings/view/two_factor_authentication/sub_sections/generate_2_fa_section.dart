import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';

class Generate2FaSection extends StatelessWidget {
  const Generate2FaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final TwoFactorAuthenticationController controller = Get.find();

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
                    Icons.security,
                    color: AppColors.lightPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    localization.generate2FaSectionTitle,
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
            const SizedBox(height: 16),
            Text(
              localization.generate2FaSectionDescription,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 24),
            CommonButton(
              onPressed: controller.loadGenerate2Fa,
              width: double.infinity,
              borderRadius: 10,
              text: localization.generate2FaSectionGenerateButton,
            ),
          ],
        ),
      ),
    );
  }
}
