import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController cameraController;
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture result) {
    if (isScanned) return;

    final String? code = result.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
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

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          Stack(
            children: [
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    border: Border.all(color: AppColors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 10,
            start: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white, size: 24),
                onPressed: () {
                  cameraController.stop();
                  Get.back();
                },
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 100,
            start: 0,
            end: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                localization.qrScannerScreenInstruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          if (isScanned)
            Positioned.fill(
              child: Container(
                color: AppColors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 50, height: 50, child: CommonLoading()),
                      const SizedBox(height: 16),
                      Text(
                        localization.qrScannerScreenProcessing,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          letterSpacing: 0,
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
}
