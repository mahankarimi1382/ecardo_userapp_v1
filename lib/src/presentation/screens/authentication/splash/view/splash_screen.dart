import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/splash/controller/splash_controller.dart';

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
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundFadeAnimation;

  @override
  void initState() {
    super.initState();
    settingsService.isSettingsDataLoad.value = false;
    settingsService.fetchSettings();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.ease));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.ease));

    _slideAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: const Offset(0, -1.2),
        ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, -1.2),
          end: const Offset(0, 0.1),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 15,
      ),
    ]).animate(_logoController);

    _logoController.forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_textController);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _backgroundFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_backgroundController);

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController.forward();
      }
    });

    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _backgroundController.forward();
      }
    });

    ever(settingsService.isSettingsDataLoad, (isLoaded) {
      if (isLoaded == true) {
        Future.delayed(const Duration(seconds: 2), () {
          splashController.navigateBasedOnAuth();
        });
      }
    });
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
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentGeometry.bottomCenter,
        children: [
          Stack(
            children: [
              FadeTransition(
                opacity: _backgroundFadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(PngAssets.splashFrame),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(PngAssets.appScreenIcon, height: 55.h),
                          const SizedBox(width: 5),
                          FadeTransition(
                            opacity: _textFadeAnimation,
                            child: SlideTransition(
                              position: _textSlideAnimation,
                              child: Text(
                                "unzo",
                                style: TextStyle(
                                  fontSize: 65.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            return Visibility(
              visible: settingsService.isSettingsLoading.value,
              replacement: SizedBox(),
              child: Transform.translate(
                offset: Offset(0, -80),
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.lightPrimary,
                  size: 50,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
