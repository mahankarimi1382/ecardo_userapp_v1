import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/controller/qr_code_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/empty_view.dart';

/// Locale-aware strings for keys not yet in checked-in AppLocalizations.
String _qrL(BuildContext context, {required String en, required String fa, required String ar}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'fa':
      return fa;
    case 'ar':
      return ar;
    default:
      return en;
  }
}

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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CommonLoading();
              }
              if (controller.hasError.value || !controller.hasQrData) {
                return Center(
                  child: EmptyView(
                    icon: Icons.qr_code_2_outlined,
                    title: _qrL(
                      context,
                      en: 'QR code unavailable',
                      fa: 'کد QR در دسترس نیست',
                      ar: 'رمز QR غير متاح',
                    ),
                    subtitle: _qrL(
                      context,
                      en: 'We could not load your QR code. Check your connection and try again.',
                      fa: 'بارگذاری کد QR ممکن نشد. اتصال را بررسی کنید و دوباره تلاش کنید.',
                      ar: 'تعذر تحميل رمز QR. تحقق من الاتصال وحاول مرة أخرى.',
                    ),
                    ctaLabel: _qrL(
                      context,
                      en: 'Retry',
                      fa: 'تلاش مجدد',
                      ar: 'إعادة المحاولة',
                    ),
                    onCta: () => controller.loadData(),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 60),
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
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> downloadQr(GlobalKey key, String fileName) async {
    final localization = AppLocalizations.of(context)!;
    try {
      final ctx = key.currentContext;
      if (ctx == null) {
        ToastHelper().showErrorToast(localization.allControllerLoadError);
        return;
      }
      RenderRepaintBoundary boundary =
          ctx.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        ToastHelper().showErrorToast(localization.allControllerLoadError);
        return;
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Write to the app's own documents directory. The previous code asked
      // for MANAGE_EXTERNAL_STORAGE and then wrote to a hardcoded
      // /storage/emulated/0/Download path: that permission is absent from the
      // manifest, so the request was ALWAYS denied and the download button was
      // permanently dead on Android; the hardcoded path is also unwritable on
      // iOS. The app-scoped directory needs no permission and works on both.
      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File('${dir.path}/$fileName.png');

      await file.writeAsBytes(pngBytes);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        // Saved regardless — only the "open it for me" convenience failed.
        debugPrint('⚠️ downloadQr(): saved but could not open (${result.message})');
      }
      ToastHelper().showSuccessToast(localization.qrCodeScreenDownloadSuccess);
    } catch (e) {
      debugPrint('❌ downloadQr() error: $e');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    }
  }
}
