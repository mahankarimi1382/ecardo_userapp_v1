import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/splash/controller/splash_controller.dart';

/// v1.0.38 (SPLASH): premium brand splash.
///   - full brand gradient (primary → primary-dark) with soft circles that
///     match the home hero card language
///   - logo mark scales/fades in, then the "eCardo" wordmark slides in
///     (the old splash still rendered the pre-rebrand "unzo" text!)
///   - brand-colored loading dots while settings load
///   - small app version pinned to the bottom (PackageInfo)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final SplashController splashController = Get.find<SplashController>();
  final settingsService = Get.find<SettingsService>();

  late AnimationController _logoController;
  late AnimationController _textController;
  Worker? _settingsWorker; // v1.0.24: disposed with the state

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  String _version = '';

  @override
  void initState() {
    super.initState();
    settingsService.isSettingsDataLoad.value = false;
    settingsService.fetchSettings();
    _loadVersion();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.ease));

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );


    _logoController.forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_textController);

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController.forward();
      }
    });

    // v1.0.24: store the worker and dispose it in dispose() — an orphaned
    // ever() here survived screen disposal and could re-trigger navigation.
    _settingsWorker = ever(settingsService.isSettingsDataLoad, (isLoaded) {
      if (isLoaded == true) {
        Future.delayed(const Duration(seconds: 2), () {
          splashController.navigateBasedOnAuth();
        });
      }
    });
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = 'v${info.version}');
    } catch (_) {
      // Non-fatal — the version label simply stays hidden.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    _textSlideAnimation = Tween<Offset>(
      begin: Offset(isRtl ? 1.5 : -1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _settingsWorker?.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Brand gradient — replaces the flat bitmap frame and blends into
        // the purple native launch background (no cold-start flash).
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              AppColors.lightPrimary,
              AppColors.lightPrimaryDark,
            ],
          ),
        ),
        child: Stack(
          alignment: AlignmentGeometry.bottomCenter,
          children: [
            // Soft decorative circles — same language as the home hero card.
            PositionedDirectional(
              top: -80,
              end: -60,
              child: _decorCircle(240, AppColors.white.withValues(alpha: 0.06)),
            ),
            PositionedDirectional(
              top: 120,
              start: -70,
              child: _decorCircle(200, AppColors.white.withValues(alpha: 0.05)),
            ),
            PositionedDirectional(
              bottom: -60,
              end: 40,
              child: _decorCircle(160, AppColors.white.withValues(alpha: 0.04)),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(PngAssets.appScreenIcon, height: 64.h),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Text(
                        "eCardo",
                        style: TextStyle(
                          fontSize: 58.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Loading dots (visible while settings are being fetched).
            PositionedDirectional(
              bottom: 170,
              start: 0,
              end: 0,
              child: Obx(() {
                return Visibility(
                  visible: settingsService.isSettingsLoading.value,
                  replacement: const SizedBox.shrink(),
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: AppColors.white,
                    size: 44,
                  ),
                );
              }),
            ),
            // Small version label pinned to the bottom.
            PositionedDirectional(
              bottom: 26,
              start: 0,
              end: 0,
              child: Column(
                children: [
                  Text(
                    'eCardo',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_version.isNotEmpty)
                    Text(
                      _version,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white.withValues(alpha: 0.45),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
