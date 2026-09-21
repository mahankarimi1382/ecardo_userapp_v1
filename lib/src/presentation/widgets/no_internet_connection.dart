import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) _goOnline();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _goOnline() async {
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    ToastHelper().showSuccessToast(
      loc?.networkReconnected ?? 'You are back online',
    );
    Get.offAllNamed(BaseRoute.splash);
  }

  Future<void> _manualRetry() async {
    setState(() => _retrying = true);
    try {
      final results = await Connectivity().checkConnectivity();
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        await _goOnline();
        return;
      }
      final settingsService = Get.find<SettingsService>();
      await settingsService.fetchSettings();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                localization.noInternetConnectionMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  color: AppColors.lightTextTertiary,
                ),
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
                borderColor: const Color(0xFF2D2D2D).withValues(alpha: 0.10),
                textColor: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                width: double.infinity,
                height: 45,
                isLoading: _retrying,
                text: localization.noInternetConnectionRetryButton,
                onPressed: _retrying ? null : _manualRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
