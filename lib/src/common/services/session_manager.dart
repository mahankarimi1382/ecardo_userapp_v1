import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

/// Centralized session expiry / unauthorized handler.
///
/// Guarantees:
/// - Only one logout + redirect runs even under parallel 401s.
/// - Dialog is shown only for foreground requests.
/// - Background requests fail silently (token cleared, no UI).
class SessionManager extends GetxService {
  bool _isHandling = false;
  Completer<void>? _inFlight;

  AppLocalizations? get _l10n {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  /// Entry point used by [NetworkService] (interceptor + error handler).
  ///
  /// [isForeground] controls whether a dialog is shown.
  /// Safe to call many times concurrently — only the first call performs work.
  Future<void> handleUnauthorized({
    required bool isForeground,
    String? message,
  }) async {
    // Fast path: already handling → wait for the in-flight operation
    if (_isHandling) {
      await _inFlight?.future;
      return;
    }

    _isHandling = true;
    _inFlight = Completer<void>();

    try {
      // 1. Clear credentials (always)
      if (Get.isRegistered<TokenService>()) {
        await Get.find<TokenService>().clearToken();
      }
      if (Get.isRegistered<SettingsService>()) {
        await Get.find<SettingsService>().wipeSession();
      }

      // 2. UI only for foreground
      if (isForeground) {
        final msg = message ??
            _l10n?.unauthorizedDialogTitle ??
            'Your session has expired. Please sign in again.';

        // Prefer a non-stacking dialog; fall back to toast if context is gone
        final shown = await _showUnauthorizedDialog(msg);
        if (!shown) {
          ToastHelper().showErrorToast(msg);
        }
      }

      // 3. Single redirect (even if many 401s arrived)
      if (Get.currentRoute != BaseRoute.signIn) {
        // Post-frame so we never navigate during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute != BaseRoute.signIn) {
            Get.offAllNamed(BaseRoute.signIn);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SessionManager.handleUnauthorized error: $e');
      }
    } finally {
      _isHandling = false;
      _inFlight?.complete();
      _inFlight = null;
    }
  }

  /// Returns true if the dialog was successfully shown.
  Future<bool> _showUnauthorizedDialog(String message) async {
    final ctx = Get.context;
    if (ctx == null || !ctx.mounted) return false;

    // Prevent stacking
    if (Get.isDialogOpen == true) return true;

    try {
      await Get.dialog(
        PopScope(
          canPop: false,
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: 324,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(52),
                        color: AppColors.error.withValues(alpha: 0.10),
                      ),
                      child: Image.asset(
                        PngAssets.commonAlertIcon,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _l10n?.unauthorizedDialogTitle ?? 'Unauthorized',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CommonButton(
                      borderRadius: 8,
                      width: 60,
                      height: 35,
                      text: _l10n?.unauthorizedDialogButton ?? 'OK',
                      onPressed: () {
                        Get.back(); // close dialog
                        if (Get.currentRoute != BaseRoute.signIn) {
                          Get.offAllNamed(BaseRoute.signIn);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
