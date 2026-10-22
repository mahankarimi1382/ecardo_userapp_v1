// ============================================================================
// app_update_screen.dart
// ----------------------------------------------------------------------------
// Full-screen, state-driven self-update flow.
//
// The screen is a pure function of [AppUpdateController.phase]:
//   idle / checking → spinner + "checking for updates..."
//   upToDate        → success checkmark animation
//   updateAvailable → version comparison + modernized changelog + "Download & Update" CTA
//   downloading     → modernized animated gradient progress bar with byte metrics
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
import 'package:ecardo_user/src/helper/l10n_pick.dart';

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
              style: TextStyle(
                color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                fontWeight: FontWeight.w700,
              ),
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
                    color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            localization?.updateCheckingTitle ?? 'Checking for updates...',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
              padding: const EdgeInsets.all(AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.xl),
            Text(
              localization?.updateUpToDateScreenTitle ?? "You're up to date!",
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isDark ? null : AppColors.brandGradient,
                  color: isDark ? AppColors.mainSoftBlue : null,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                          .withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                      color: isDark ? AppColors.deepBlack : AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.checkForUpdate();
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                ),
                label: Text(
                  localization?.updateCheckAgain ?? 'Check again',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
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
                    color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              localization?.updateAvailableScreenTitle ?? 'Update available',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Modern Version comparison card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet).withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                      size: 20,
                    ),
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
                          color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Modern Changelog list card
            Builder(builder: (context) {
              final notes = controller.resolveNotes(
                controller.serverVersion.value,
              );
              final version = controller.serverVersion.value;
              return Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _ChangelogCard(
                    version: version,
                    notes: notes,
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    cardBg: cardBg,
                  ),
                ],
              );
            }),

            if (controller.forceUpdate.value) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
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

            const SizedBox(height: AppSpacing.xl),

            // Modernized Update CTA Button with Brand Gradient & Tactile feedback
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isDark ? null : AppColors.brandGradient,
                  color: isDark ? AppColors.mainSoftBlue : null,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                          .withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    controller.startDownloadAndInstall();
                  },
                  icon: const Icon(Icons.download_rounded, size: 22),
                  label: Text(
                    localization?.updateDialogDownload ?? 'Download & Update',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.deepBlack : AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            if (!controller.forceUpdate.value) ...[
              const SizedBox(height: AppSpacing.sm),
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

/// Modern Changelog list with bullet breakdown, category tags, and dark mode support
class _ChangelogCard extends StatelessWidget {
  final String version;
  final String notes;
  final bool isDark;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color cardBg;

  const _ChangelogCard({
    required this.version,
    required this.notes,
    required this.isDark,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final accentColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    final lines = notes
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon badge, title, and version tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryContainer
                      : AppColors.brandVioletContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  loc?.updateWhatsNewTitle(version) ?? "What's new in v$version",
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'v$version',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Structured changelog items
          if (lines.isEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    loc?.updateWhatsNewFallback ??
                        'Bug fixes and performance improvements.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryTextColor,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            )
          else
            ...lines.map((line) {
              final cleanText = line.replaceFirst(RegExp(r'^[-*•]\s*'), '');
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        cleanText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryTextColor,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
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
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final accentColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 130.w,
              height: 130.w,
              child: Lottie.asset(
                'assets/others/json/update_downloading.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.download_rounded,
                    size: 70.w,
                    color: accentColor,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Modernized Progress Container Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Percentage and title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_download_outlined,
                            size: 18,
                            color: accentColor,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            localization?.updateStartingDownload ?? 'Downloading...',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Text(
                          '${controller.progressPercent.value}%',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Modern Animated Gradient Progress Bar
                  Obx(() {
                    final percent = (controller.progressPercent.value / 100.0).clamp(0.0, 1.0);
                    return Container(
                      height: 12.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightOutlineVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth * percent;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              width: barWidth,
                              height: 12.h,
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? const LinearGradient(
                                        colors: [AppColors.mainSoftBlue, AppColors.brandViolet],
                                      )
                                    : AppColors.brandGradient,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),

                  // Download byte metrics and status indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          controller.totalBytesLabel.value.isEmpty
                              ? ''
                              : '${controller.downloadedBytesLabel.value} / ${controller.totalBytesLabel.value}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: secondaryTextColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Active',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Cancel action
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                      color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              localization?.updateInstallingTitle ?? 'Installing update...',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              localization?.updateInstallingBody ??
                  'Android is installing the new version. Please follow the '
                      'system prompt to complete the installation.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isDark ? null : AppColors.brandGradient,
                  color: isDark ? AppColors.mainSoftBlue : null,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                          .withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                      color: isDark ? AppColors.deepBlack : AppColors.white,
                    ),
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
              padding: const EdgeInsets.all(AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.lg),
            Text(
              localization?.updateFailedTitle ?? 'Update failed',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.20),
                  ),
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
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isDark ? null : AppColors.brandGradient,
                  color: isDark ? AppColors.mainSoftBlue : null,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                          .withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.reset();
                    controller.checkForUpdate();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    localization?.updateTryAgain ?? 'Try again',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.deepBlack : AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                  side: BorderSide(
                    color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.openDirectDownload();
                },
                icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                label: Text(
                  l10nPick(
                    context,
                    en: 'Download from website',
                    fa: 'دانلود مستقیم از وب‌سایت',
                    ar: 'تنزيل مباشر من الموقع',
                    tr: 'Web sitesinden doğrudan indir',
                    ru: 'Прямая загрузка с сайта',
                    zh: '从网站直接下载',
                  ),
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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
