import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        Get.bottomSheet(
          CommonAlertBottomSheet(
            title: localizations.exitApplicationTitle,
            message: localizations.exitApplicationMessage,
            onConfirm: () => exit(0),
            onCancel: () => Get.back(),
          ),
        );
      },
      child: Scaffold(
        appBar: const CommonDefaultAppBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(PngAssets.welcomeMobile, width: 300.w),
                  SizedBox(height: 30.h),
                  Text(
                    localizations.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28.sp,
                      color: AppColors.lightTextPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    localizations.welcomeDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: AppColors.lightTextTertiary,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          width: double.infinity,
                          text: localizations.welcomeSignIn,
                          onPressed: () => Get.toNamed(BaseRoute.signIn),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: CommonButton(
                          backgroundColor: AppColors.lightPrimary.withValues(
                            alpha: 0.04,
                          ),
                          borderWidth: 2,
                          borderColor: AppColors.lightPrimary.withValues(
                            alpha: 0.50,
                          ),
                          textColor: AppColors.lightTextPrimary.withValues(
                            alpha: 0.80,
                          ),
                          width: double.infinity,
                          text: localizations.welcomeCreateAccount,
                          onPressed: () => Get.toNamed(BaseRoute.email),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
