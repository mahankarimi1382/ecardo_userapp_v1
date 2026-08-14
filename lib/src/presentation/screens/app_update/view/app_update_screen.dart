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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppUpdateController>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (controller.phase.value == AppUpdatePhase.downloading) {
          final shouldPop = await _confirmCancelDownload();
          if (shouldPop && context.mounted) {
            await controller.cancelDownload();
            Get.back();
          }
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: CommonDefaultAppBar(),
        body: SafeArea(
          child: Obx(() {
            final phase = controller.phase.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _buildPhaseContent(phase, controller),
            );
          }),
        ),
      ),
    );
  }

  // ===========================================================================
  // Phase-specific views
  // ===========================================================================

  Widget _buildPhaseContent(
    AppUpdatePhase phase,
    AppUpdateController controller,
  ) {
    switch (phase) {
      case AppUpdatePhase.idle:
      case AppUpdatePhase.checking:
        return const _CheckingView(key: ValueKey('checking'));

      case AppUpdatePhase.upToDate:
        return _UpToDateView(
          key: const ValueKey('up_to_date'),
          controller: controller,
        );

      case AppUpdatePhase.updateAvailable:
        return _UpdateAvailableView(
          key: const ValueKey('available'),
          controller: controller,
        );

      case AppUpdatePhase.downloading:
        return _DownloadingView(
          key: const ValueKey('downloading'),
          controller: controller,
        );

      case AppUpdatePhase.installing:
        return const _InstallingView(key: ValueKey('installing'));

      case AppUpdatePhase.error:
        return _ErrorView(
          key: const ValueKey('error'),
          controller: controller,
        );
    }
  }

  Future<bool> _confirmCancelDownload() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel download?'),
        content: const Text(
          'The update download is still in progress. '
          'Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Continue download'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
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
  const _CheckingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200.w,
            height: 200.w,
            child: Lottie.asset(
              'assets/others/json/update_checking.json',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to a Material spinner if the Lottie file is
                // missing — the app should never crash just because an
                // animation asset wasn't bundled.
                return const CircularProgressIndicator(
                  color: AppColors.lightPrimary,
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Checking for updates...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Contacting eCardo server for the latest version.',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpToDateView extends StatelessWidget {
  const _UpToDateView({super.key, required this.controller});

  final AppUpdateController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 120.w,
              color: AppColors.success,
            ),
            SizedBox(height: 24.h),
            Text(
              'You\'re up to date!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'eCardo v${controller.currentVersion.value} is the latest version available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => controller.checkForUpdate(),
                child: Text(
                  'Check again',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.lightPrimary,
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
  const _UpdateAvailableView({super.key, required this.controller});

  final AppUpdateController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180.w,
              height: 180.w,
              child: Lottie.asset(
                'assets/others/json/update_available.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.system_update_alt_rounded,
                    size: 120.w,
                    color: AppColors.lightPrimary,
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Update available',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightPrimary, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'v${controller.currentVersion.value}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.lightPrimary,
                    size: 28,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'New',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'v${controller.serverVersion.value}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.forceUpdate.value) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 20),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'This update is required. The app cannot be used until you update.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.startDownloadAndInstall(),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: Text(
                  'Download & Update',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!controller.forceUpdate.value) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Maybe later',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.lightTextSecondary,
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
  const _DownloadingView({super.key, required this.controller});

  final AppUpdateController controller;

  @override
  Widget build(BuildContext context) {
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
                'assets/others/json/update_downloading.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.download_rounded,
                    size: 100.w,
                    color: AppColors.lightPrimary,
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            Obx(
              () => Text(
                '${controller.progressPercent.value}%',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: controller.progressPercent.value / 100.0,
                  minHeight: 12,
                  backgroundColor:
                      AppColors.lightPrimary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => Text(
                controller.totalBytesLabel.value.isEmpty
                    ? 'Starting download...'
                    : '${controller.downloadedBytesLabel.value} / '
                        '${controller.totalBytesLabel.value}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await controller.cancelDownload();
                  if (context.mounted) Get.back();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
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
  const _InstallingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180.w,
              height: 180.w,
              child: Lottie.asset(
                'assets/others/json/update_installing.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const CircularProgressIndicator(
                    color: AppColors.lightPrimary,
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Installing update...',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Android is installing the new version. Please follow the system '
              'prompt to complete the installation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  'I\'ve finished installing',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
  const _ErrorView({super.key, required this.controller});

  final AppUpdateController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 100.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Update failed',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  controller.errorMessage.value.isEmpty
                      ? 'An unknown error occurred.'
                      : controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  controller.reset();
                  controller.checkForUpdate();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'Try again',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Go back',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.lightTextSecondary,
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
