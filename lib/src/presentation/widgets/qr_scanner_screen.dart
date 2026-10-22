import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Camera-driven QR scanner screen with live barcode detection, clean
/// accessibility semantics, and camera permission denial guidance with a
/// direct CTA to device App Settings.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController cameraController;
  bool isScanned = false;
  bool _isPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraController = MobileScannerController();
    _checkInitialPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckPermissionOnResume();
    }
  }

  Future<void> _checkInitialPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isPermanentlyDenied || status.isRestricted) {
        if (mounted) {
          setState(() => _isPermissionDenied = true);
        }
      }
    } catch (e) {
      debugPrint('⚠️ _checkInitialPermission error: $e');
    }
  }

  Future<void> _recheckPermissionOnResume() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        if (mounted && _isPermissionDenied) {
          setState(() => _isPermissionDenied = false);
          cameraController.start();
        }
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        if (mounted && !_isPermissionDenied) {
          setState(() => _isPermissionDenied = true);
        }
      }
    } catch (e) {
      debugPrint('⚠️ _recheckPermissionOnResume error: $e');
    }
  }

  void _onDetect(BarcodeCapture result) {
    if (isScanned) return;

    final String? code = result.barcodes.firstOrNull?.rawValue;
    if (code != null && code.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        isScanned = true;
      });
      cameraController.stop();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Get.back(result: code);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    if (_isPermissionDenied) {
      return _buildPermissionDeniedView(context);
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Live Camera Stream
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return _buildPermissionDeniedView(context);
            },
          ),

          // Viewfinder Focus Frame
          Center(
            child: Semantics(
              label: localization.qrScannerScreenInstruction,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.transparent,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.9),
                    width: 2.2,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandViolet.withValues(alpha: 0.22),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Close Action (min 44x44 touch target)
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            start: AppSpacing.lg,
            child: Semantics(
              button: true,
              label: l10nPick(
                context,
                en: 'Close scanner',
                fa: 'بستن اسکنر',
                ar: 'إغلاق الماسح',
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      cameraController.stop();
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: Ink(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: AppSpacing.iconMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Instruction Banner
          PositionedDirectional(
            bottom: 90,
            start: AppSpacing.xl,
            end: AppSpacing.xl,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.darkBorder, width: 0.8),
                ),
                child: Text(
                  localization.qrScannerScreenInstruction,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Processing State Overlay
          if (isScanned)
            Positioned.fill(
              child: Container(
                color: AppColors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CommonLoading(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        localization.qrScannerScreenProcessing,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: l10nPick(
            context,
            en: 'Close scanner',
            fa: 'بستن اسکنر',
            ar: 'إغلاق الماسح',
          ),
          child: IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.white,
              size: AppSpacing.iconMd,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandViolet.withValues(alpha: 0.14),
                    border: Border.all(
                      color: AppColors.brandViolet.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.no_photography_rounded,
                      size: 40,
                      color: AppColors.mainSoftBlue,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  l10nPick(
                    context,
                    en: 'Camera Permission Required',
                    fa: 'دسترسی به دوربین لازم است',
                    ar: 'مطلوب إذن الكاميرا',
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Guidance Message
                Text(
                  l10nPick(
                    context,
                    en: 'To scan QR codes and make instant payments, eCardo needs access to your device camera. Please grant camera permission in your device settings.',
                    fa: 'برای اسکن کدهای QR و انجام پرداخت آنی، اکاردو به دسترسی دوربین نیاز دارد. لطفاً دسترسی به دوربین را در تنظیمات دستگاه فعال فرمایید.',
                    ar: 'لمسح رموز QR وإجراء الدفع الفوري، يحتاج إيكاردو إلى الوصول إلى الكاميرا. يرجى تفعيل إذن الكاميرا في إعدادات جهازك.',
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warmWhite.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Primary Action: Open Device App Settings (min 44x44 touch target)
                Semantics(
                  button: true,
                  label: l10nPick(
                    context,
                    en: 'Open App Settings',
                    fa: 'باز کردن تنظیمات دستگاه',
                    ar: 'فتح إعدادات الجهاز',
                  ),
                  hint: l10nPick(
                    context,
                    en: 'Navigates to system application settings to grant camera permission',
                    fa: 'انتقال به تنظیمات سیستم برای اعطای دسترسی دوربین',
                    ar: 'الانتقال إلى إعدادات النظام لمنح إذن الكاميرا',
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 48,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandViolet,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        icon: const Icon(
                          Icons.settings_rounded,
                          size: AppSpacing.iconSm,
                          color: AppColors.white,
                        ),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Open App Settings',
                            fa: 'باز کردن تنظیمات دستگاه',
                            ar: 'فتح إعدادات الجهاز',
                          ),
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await openAppSettings();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Secondary Action: Go Back
                Semantics(
                  button: true,
                  label: l10nPick(
                    context,
                    en: 'Go Back',
                    fa: 'بازگشت',
                    ar: 'رجوع',
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.warmWhite.withValues(
                          alpha: 0.7,
                        ),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                      },
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Cancel',
                          fa: 'انصراف',
                          ar: 'إلغاء',
                        ),
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
