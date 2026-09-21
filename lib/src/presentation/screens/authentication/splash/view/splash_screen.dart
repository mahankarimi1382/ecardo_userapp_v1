import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/splash/controller/splash_controller.dart';

/// v1.0.55 — redesigned splash: layered gradient, glass logo mark,
/// animated progress ring, refined wordmark + tagline.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final SplashController splashController = Get.find<SplashController>();
  final settingsService = Get.find<SettingsService>();

  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  Worker? _settingsWorker;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _wordFade;
  late Animation<Offset> _wordSlide;
  late Animation<double> _tagFade;

  String _version = '';

  @override
  void initState() {
    super.initState();
    settingsService.isSettingsDataLoad.value = false;
    settingsService.fetchSettings();
    _loadVersion();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _wordFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _wordSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _tagFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _introController.forward();

    _settingsWorker = ever(settingsService.isSettingsDataLoad, (isLoaded) {
      if (isLoaded == true) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) splashController.navigateBasedOnAuth();
        });
      }
    });
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = 'v${info.version}');
    } catch (_) {}
  }

  @override
  void dispose() {
    _settingsWorker?.dispose();
    _introController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B6BFF),
              AppColors.lightPrimary,
              AppColors.lightPrimaryDark,
              Color(0xFF3D248F),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft mesh orbs
            Positioned(
              top: -90,
              right: -50,
              child: _orb(220, AppColors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              top: 160,
              left: -80,
              child: _orb(180, const Color(0xFF00BFA6).withValues(alpha: 0.10)),
            ),
            Positioned(
              bottom: 80,
              right: -40,
              child: _orb(160, AppColors.white.withValues(alpha: 0.06)),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Logo glass card with pulse ring
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final pulse = 1.0 + (_pulseController.value * 0.04);
                          return Transform.scale(scale: pulse, child: child);
                        },
                        child: Container(
                          width: 112.w,
                          height: 112.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.white.withValues(alpha: 0.28),
                                AppColors.white.withValues(alpha: 0.10),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.22),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(18.w),
                          child: Image.asset(
                            PngAssets.appLogo,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 48.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  // Wordmark
                  FadeTransition(
                    opacity: _wordFade,
                    child: SlideTransition(
                      position: _wordSlide,
                      child: Text(
                        'eCardo',
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.white,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      'Financial Super App',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: AppColors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Progress ring
                  FadeTransition(
                    opacity: _tagFade,
                    child: SizedBox(
                      width: 42.w,
                      height: 42.w,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _SplashProgressPainter(
                              progress: _progressController.value,
                              color: AppColors.white.withValues(alpha: 0.9),
                              track: AppColors.white.withValues(alpha: 0.18),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  FadeTransition(
                    opacity: _tagFade,
                    child: Obx(() {
                      final loading = settingsService.isSettingsLoading.value;
                      return Text(
                        loading ? 'Preparing your workspace…' : 'Almost ready',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white.withValues(alpha: 0.55),
                        ),
                      );
                    }),
                  ),
                  const Spacer(flex: 1),
                  if (_version.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Text(
                        _version,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: AppColors.white.withValues(alpha: 0.40),
                        ),
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

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SplashProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;

  _SplashProgressPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    final start = -math.pi / 2 + (progress * math.pi * 2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      math.pi * 0.7,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashProgressPainter old) =>
      old.progress != progress;
}
