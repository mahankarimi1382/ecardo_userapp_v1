// ============================================================================
// app_update_screen.dart
// ----------------------------------------------------------------------------
// Full-screen, state-driven self-update flow.
//
// The screen is a pure function of [AppUpdateController.phase]:
//   idle / checking → spinner + "checking for updates..."
//   upToDate        → success checkmark animation
//   updateAvailable → version comparison + "Download & Update" button
//   downloading     → animated progress bar with percent + byte counter
//   installing      → indeterminate spinner + "waiting for system installer"
//   error           → error icon + message + Retry button
//
// The user stays on this screen until they explicitly press Back / Done, so
// they always have full visibility into what the update flow is doing.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  Worker? _phaseWorker;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    final controller = Get.find<AppUpdateController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (controller.phase.value) {
        case AppUpdatePhase.idle:
          controller.checkForUpdate(showSnackbarWhenUpToDate: false);
        case AppUpdatePhase.updateAvailable:
          _maybeAutoStart(controller);
        default:
          break;
      }
    });

    _phaseWorker = ever<AppUpdatePhase>(controller.phase, (phase) {
      if (phase == AppUpdatePhase.updateAvailable) {
        _maybeAutoStart(controller);
      }
    });
  }

  void _maybeAutoStart(AppUpdateController controller) {
    if (!(controller.forceUpdate.value || controller.autoUpdateEnabled.value)) {
      return;
    }
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (controller.phase.value == AppUpdatePhase.updateAvailable) {
        controller.startDownloadAndInstall();
      }
    });
  }

  @override
  void dispose() {
    _phaseWorker?.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppUpdateController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (controller.phase.value == AppUpdatePhase.downloading) {
          final shouldPop = await _confirmCancelDownload(isDark);
          if (shouldPop && context.mounted) {
            await controller.cancelDownload();
            Get.back();
          }
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: const CommonDefaultAppBar(),
        body: SafeArea(
          child: Obx(() {
            final phase = controller.phase.value;
            return AnimatedSwitcher(
              duration: AppSpacing.normal,
              child: _buildPhaseContent(phase, controller, isDark),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(
    AppUpdatePhase phase,
    AppUpdateController controller,
    bool isDark,
  ) {
    switch (phase) {
      case AppUpdatePhase.idle:
      case AppUpdatePhase.checking:
        return _CheckingView(key: const ValueKey('checking'), isDark: isDark);

      case AppUpdatePhase.upToDate:
        return _UpToDateView(
          key: const ValueKey('up_to_date'),
          controller: controller,
          isDark: isDark,
        );

      case AppUpdatePhase.updateAvailable:
        return _UpdateAvailableView(
          key: const ValueKey('available'),
          controller: controller,
          isDark: isDark,
        );

      case AppUpdatePhase.downloading:
        return _DownloadingView(
          key: const ValueKey('downloading'),
          controller: controller,
          isDark: isDark,
        );

      case AppUpdatePhase.installing:
        return _InstallingView(key: const ValueKey('installing'), isDark: isDark);

      case AppUpdatePhase.error:
        return _ErrorView(
          key: const ValueKey('error'),
          controller: controller,
          isDark: isDark,
        );
    }
  }

  Future<bool> _confirmCancelDownload(bool isDark) async {
    final localization = AppLocalizations.of(Get.context!);
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Text(
          localization?.updateCancelDownloadTitle ?? 'Cancel download?',
          style: AppTextStyles.titleMedium.copyWith(
            color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
          ),
        ),
        content: Text(
          localization?.updateCancelDownloadBody ??
              'The update download is still in progress. '
                  'Are you sure you want to cancel?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              localization?.updateContinueDownload ?? 'Continue download',
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(
              localization?.updateCancel ?? 'Cancel',
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}

// ============================================================================
// Sub-views
// ============================================================================

class _CheckingView extends StatelessWidget {
  final bool isDark;
  const _CheckingView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180.w,
            height: 180.w,
            child: Lottie.asset(
              'assets/others/json/update_checking.json',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            localization?.updateCheckingTitle ?? 'Checking for updates...',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            localization?.updateCheckingBody ??
                'Contacting eCardo server for the latest version.',
            style: AppTextStyles.bodySmall.copyWith(
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpToDateView extends StatelessWidget {
  final AppUpdateController controller;
  final bool isDark;

  const _UpToDateView({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 80.w,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              localization?.updateUpToDateScreenTitle ?? "You're up to date!",
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              localization?.updateUpToDateScreenBody(
                    controller.currentVersion.value,
                  ) ??
                  'eCardo v${controller.currentVersion.value} is the latest version available.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                child: Text(
                  localization?.updateDoneButton ?? 'Done',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.checkForUpdate();
                },
                child: Text(
                  localization?.updateCheckAgain ?? 'Check again',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateAvailableView extends StatelessWidget {
  final AppUpdateController controller;
  final bool isDark;

  const _UpdateAvailableView({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150.w,
              height: 150.w,
              child: Lottie.asset(
                'assets/others/json/update_available.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.system_update_alt_rounded,
                    size: 90.w,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              localization?.updateAvailableScreenTitle ?? 'Update available',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Version comparison card
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary).withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization?.updateCurrentLabel ?? 'Current',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'v${controller.currentVersion.value}',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    size: 24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        localization?.updateNewLabel ?? 'New',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'v${controller.serverVersion.value}',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // What's new card
            Builder(builder: (context) {
              final loc = AppLocalizations.of(context);
              final notes = controller.resolveNotes(
                controller.serverVersion.value,
              );
              final version = controller.serverVersion.value;
              return Column(
                children: [
                  SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc?.updateWhatsNewTitle(version) ??
                              "What's new in v$version",
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          notes.isNotEmpty
                              ? notes
                              : (loc?.updateWhatsNewFallback ??
                                  'Bug fixes and performance improvements.'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: secondaryTextColor,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),

            if (controller.forceUpdate.value) ...[
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        localization?.updateForceNote ??
                            'This update is required. The app cannot be used until you update.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppSpacing.xl),

            // Download & Update button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  controller.startDownloadAndInstall();
                },
                icon: const Icon(Icons.download_rounded),
                label: Text(
                  localization?.updateDialogDownload ?? 'Download & Update',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!controller.forceUpdate.value) ...[
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    localization?.updateMaybeLater ?? 'Maybe later',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DownloadingView extends StatelessWidget {
  final AppUpdateController controller;
  final bool isDark;

  const _DownloadingView({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140.w,
              height: 140.w,
              child: Lottie.asset(
                'assets/others/json/update_downloading.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.download_rounded,
                    size: 80.w,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(
              () => Text(
                '${controller.progressPercent.value}%',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Obx(
              () => ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: LinearProgressIndicator(
                  value: controller.progressPercent.value / 100.0,
                  minHeight: 10,
                  backgroundColor: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                      .withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Obx(
              () => Text(
                controller.totalBytesLabel.value.isEmpty
                    ? (localization?.updateStartingDownload ??
                        'Starting download...')
                    : '${controller.downloadedBytesLabel.value} / '
                        '${controller.totalBytesLabel.value}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await controller.cancelDownload();
                  if (context.mounted) Get.back();
                },
                child: Text(
                  localization?.updateCancel ?? 'Cancel',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallingView extends StatelessWidget {
  final bool isDark;
  const _InstallingView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160.w,
              height: 160.w,
              child: Lottie.asset(
                'assets/others/json/update_installing.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              localization?.updateInstallingTitle ?? 'Installing update...',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              localization?.updateInstallingBody ??
                  'Android is installing the new version. Please follow the '
                      'system prompt to complete the installation.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                child: Text(
                  localization?.updateInstallFinished ?? "I've finished installing",
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final AppUpdateController controller;
  final bool isDark;

  const _ErrorView({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 80.w,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              localization?.updateFailedTitle ?? 'Update failed',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  controller.errorMessage.value.isEmpty
                      ? (localization?.updateUnknownError ??
                          'An unknown error occurred.')
                      : controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.reset();
                  controller.checkForUpdate();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  localization?.updateTryAgain ?? 'Try again',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  localization?.updateGoBack ?? 'Go back',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
