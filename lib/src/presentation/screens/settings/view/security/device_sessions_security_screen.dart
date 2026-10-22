import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

// Forwarding export to modular device_sessions_security package.
export 'package:ecardo_user/src/presentation/screens/device_sessions_security/device_sessions_security.dart';

/// Design system color tokens for PIN dots and session cards in Device Sessions & Security.
class DeviceSessionsSecurityTokens {
  const DeviceSessionsSecurityTokens._();

  // PIN dot tokens
  static const Color pinDotFilledLight = AppColors.lightPrimary;
  static const Color pinDotFilledDark = AppColors.mainSoftBlue;
  static const Color pinDotSuccess = AppColors.success;
  static const Color pinDotError = AppColors.error;
  static const Color pinDotInactiveLight = AppColors.greyLight;
  static const Color pinDotInactiveDark = AppColors.darkBorder;

  // Session card tokens
  static const Color cardSurfaceLight = AppColors.lightSurface;
  static const Color cardSurfaceDark = AppColors.darkSurface;
  static const Color cardBorderLight = AppColors.lightBorder;
  static const Color cardBorderDark = AppColors.darkBorder;
  static const Color cardTextPrimaryLight = AppColors.deepBlack;
  static const Color cardTextPrimaryDark = AppColors.warmWhite;
  static const Color cardTextSecondaryLight = AppColors.lightTextSecondary;
  static const Color cardTextSecondaryDark = AppColors.softGray;
  static const Color cardRevokeAction = AppColors.error;
}
