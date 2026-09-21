import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';

/// Minimal 404 — unknown routes must not dump the user on Splash.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off_rounded, size: 56, color: AppColors.lightTextTertiary),
              const SizedBox(height: 16),
              Text(
                loc?.maintenanceTitle ?? 'Page not found',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                loc?.allControllerLoadError ??
                    'This screen is not available. Return home to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.lightTextTertiary),
              ),
              const SizedBox(height: 24),
              CommonButton(
                width: double.infinity,
                text: loc?.commonClose ?? 'Close',
                onPressed: () {
                  if (Get.key.currentState?.canPop() == true) {
                    Get.back();
                  } else {
                    Get.offAllNamed(BaseRoute.navigation);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
