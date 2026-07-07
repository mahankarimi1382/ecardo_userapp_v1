import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/qr_code/controller/qr_code_controller.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final QrCodeController controller = Get.find<QrCodeController>();
  final GlobalKey qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          CommonAppBar(title: localization.qrCodeScreenTitle),
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const CommonLoading()
                  : Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 60,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: RepaintBoundary(
                              key: qrKey,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: SvgPicture.string(
                                  controller.qrCodeModel.value.data ?? '',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          CommonButton(
                            onPressed: () => downloadQr(
                              qrKey,
                              "qr_code_${DateTime.now().millisecondsSinceEpoch}",
                            ),
                            width: double.infinity,

                            text: localization.qrCodeScreenDownloadButton,
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

  Future<void> downloadQr(GlobalKey key, String fileName) async {
    final localization = AppLocalizations.of(context)!;
    try {
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ToastHelper().showErrorToast(
            localization.qrCodeScreenPermissionRequired,
          );
          return;
        }
      }

      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final String path = "/storage/emulated/0/Download/$fileName.png";
      final File file = File(path);

      await file.writeAsBytes(pngBytes);
      ToastHelper().showSuccessToast(localization.qrCodeScreenDownloadSuccess);
    } finally {}
  }
}
