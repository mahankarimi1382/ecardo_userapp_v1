import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

class BackCameraCapture extends StatefulWidget {
  final String fieldName;

  const BackCameraCapture({super.key, required this.fieldName});

  @override
  State<BackCameraCapture> createState() => _BackCameraCaptureState();
}

class _BackCameraCaptureState extends State<BackCameraCapture> {
  bool isCapturing = false;
  bool _isCheckingPermission = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
          _isCheckingPermission = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
        });
      }
    }
  }

  void onCapture(String filePath) {
    File file = File(filePath);
    Navigator.pop(Get.context!, file);
  }

  Future<void> _pickWithSystemCamera() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked != null) {
        onCapture(picked.path);
      }
    } catch (e) {
      debugPrint('System camera pick error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        onCapture(picked.path);
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16.h),
              Text(
                l10nPick(
                  context,
                  fa: 'در حال آماده‌سازی دوربین...',
                  en: 'Preparing camera...',
                  ar: 'جاري تشغيل الكاميرا...',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_photography_rounded, size: 56.sp, color: Colors.white70),
                SizedBox(height: 16.h),
                Text(
                  l10nPick(
                    context,
                    fa: 'دسترسی به دوربین داده نشده است',
                    en: 'Camera Permission Required',
                    ar: 'مطلوب إذن الكاميرا',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10nPick(
                    context,
                    fa: 'برای تصویربرداری از مدرک شناسایی، لطفاً دسترسی به دوربین را فعال کنید یا از دوربین پیش‌فرض سیستم استفاده نمایید.',
                    en: 'Camera access is needed to capture identification documents. You can grant access or use the system camera.',
                    ar: 'يلزم إذن الكاميرا لتصوير مستند الهوية.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: const Icon(Icons.settings_rounded, color: Colors.white),
                  label: Text(
                    l10nPick(context, fa: 'باز کردن تنظیمات', en: 'Open Settings', ar: 'فتح الإعدادات'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await openAppSettings();
                    _requestCameraPermission();
                  },
                ),
                SizedBox(height: 12.h),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    l10nPick(context, fa: 'استفاده از دوربین سیستم', en: 'Use System Camera'),
                  ),
                  onPressed: _pickWithSystemCamera,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photo(),
            sensorConfig: SensorConfig.single(
              sensor: Sensor.position(SensorPosition.back),
              zoom: 0.0,
            ),
            availableFilters: const [],
            enablePhysicalButton: true,
            topActionsBuilder: (state) => AwesomeTopActions(
              state: state,
              padding: const EdgeInsets.all(8.0),
              children: [
                AwesomeFlashButton(state: state),
              ],
            ),
            bottomActionsBuilder: (state) => AwesomeBottomActions(
              state: state,
              left: IconButton(
                icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 28),
                onPressed: _pickFromGallery,
                tooltip: 'انتخاب از گالری',
              ),
              right: IconButton(
                icon: const Icon(Icons.camera_rounded, color: Colors.white, size: 28),
                onPressed: _pickWithSystemCamera,
                tooltip: 'دوربین سیستم',
              ),
            ),
            onMediaCaptureEvent: (event) {
              switch (event.status) {
                case MediaCaptureStatus.capturing:
                  setState(() => isCapturing = true);
                  break;
                case MediaCaptureStatus.success:
                  setState(() => isCapturing = false);
                  event.captureRequest.when(
                    single: (single) {
                      if (single.file != null) {
                        onCapture(single.file!.path);
                      }
                    },
                    multiple: (multiple) => null,
                  );
                  break;
                case MediaCaptureStatus.failure:
                  setState(() => isCapturing = false);
                  break;
              }
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
