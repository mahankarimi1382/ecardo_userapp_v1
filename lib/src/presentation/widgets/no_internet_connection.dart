import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/others/json/wifi_connect.json', width: 100.w),
            Text(
              localization.noInternetConnectionTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              localization.noInternetConnectionMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                color: AppColors.lightTextTertiary,
              ),
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: CommonButton(
                backgroundColor: AppColors.lightTextPrimary.withValues(
                  alpha: 0.03,
                ),
                borderWidth: 2,
                borderColor: Color(0xFF2D2D2D).withValues(alpha: 0.10),
                textColor: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                width: double.infinity,
                height: 45,
                text: localization.noInternetConnectionRetryButton,
                onPressed: () async {
                  Get.offAllNamed(BaseRoute.splash);
                  final SettingsService settingsService = Get.find();
                  await settingsService.fetchSettings();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
