// WebViewScreen — hardened payment WebView (S-024).
//
// این فایل چیست و چه تغییری کرده:
// قبل از این نسخه، صفحه فقط URL بازگشتی را برای "/success" اسکرپ می‌کرد و
// body صفحه را jsonDecode می‌کرد — هر دو شکننده بودند: خروجی غیر JSON باعث
// کرش در onPageFinished می‌شد و وضعیت «موفق» فقط از روی متن صفحه تصمیم
// گرفته می‌شد نه از روی رکورد تراکنش سرور.
// تغییرات v1.0.24:
//  1) tnx از paymentUrl (قالب /pro-pay/{transaction_id}) استخراج می‌شود.
//  2) وضعیت نهایی از API رسمی GET /api/user/payment-status/{tnx} (منبع
//     حقیقت سرور — S-024) با حداکثر ۳ تلاش خوانده می‌شود.
//  3) اسکرپ فقط به‌عنوان fallbackِ سازگاری استفاده می‌شود و تمام
//     jsonDecode/JS در try/catch است — دیگر هیچ کرشی از این مسیر رد نمی‌شود.
//  4) نتیجه {'success': bool, 'data': ...} مثل قبل برگردانده می‌شود تا
//     قرارداد فراخوان‌ها (add_money / virtual_card) بدون تغییر بماند.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const WebViewScreen({super.key, required this.paymentUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final localization = AppLocalizations.of(Get.context!)!;
  final WebViewController _controller = WebViewController();
  bool _isLoading = true;
  bool _redirectProcessed = false;

  /// Transaction id extracted from the gateway URL (pro-pay/{tnx}).
  String? get _tnx {
    final match = RegExp(r'pro-pay/([^/?#]+)').firstMatch(widget.paymentUrl);
    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });

            if (url.contains('/success')) {
              await _handleReturnUrl(url, treatAsSuccessHint: true);
            } else if (url.contains('/cancel')) {
              await _handleReturnUrl(url, treatAsSuccessHint: false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Single decision point for the return URL. Authoritative source is the
  /// server (payment-status API); the page body is only a fallback.
  Future<void> _handleReturnUrl(
    String url, {
    required bool treatAsSuccessHint,
  }) async {
    if (_redirectProcessed) return;
    _redirectProcessed = true;

    // 1) Ask the server first when we can identify the transaction.
    final tnx = _tnx;
    if (tnx != null && tnx.isNotEmpty) {
      final serverState = await _queryServerStatus(tnx);
      if (serverState != null) {
        _finish(success: serverState, data: {'tnx': tnx});
        return;
      }
    }

    // 2) Legacy fallback: scrape the page body (kept for compatibility).
    final decoded = await _scrapePageJson();
    if (decoded != null) {
      final status = decoded['status']?.toString().toLowerCase();
      if (status == 'success') {
        _finish(success: true, data: decoded);
        return;
      }
      if (status == 'failed') {
        _finish(
          success: false,
          data: decoded,
          message: decoded['message']?.toString(),
        );
        return;
      }
    }

    // 3) Nothing conclusive — use the URL hint without claiming success.
    _finish(success: treatAsSuccessHint, data: null);
  }

  /// Returns true/false when the server gives a definitive verdict,
  /// null when unreachable/unknown (caller falls back to scraping).
  Future<bool?> _queryServerStatus(String tnx) async {
    try {
      final network = Get.find<NetworkService>();
      for (var attempt = 0; attempt < 3; attempt++) {
        final response = await network.get(
          endpoint: ApiPath.paymentStatusEndpoint(tnx),
        );
        if (response.status == Status.completed) {
          return response.data?['data']?['success'] == true;
        }
        if (response.status == Status.error) {
          // 404 = definitely not found; no point retrying.
          return null;
        }
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }
    } catch (e) {
      debugPrint('WebView payment-status verification failed: $e');
    }
    return null;
  }

  /// Best-effort scrape of the legacy JSON body — never throws.
  Future<Map<String, dynamic>?> _scrapePageJson() async {
    try {
      String jsonResponse = await _controller.runJavaScriptReturningResult(
            "document.body.innerText",
          ) as String;

      jsonResponse = jsonResponse.trim();
      if (jsonResponse.startsWith('"') && jsonResponse.endsWith('"')) {
        jsonResponse = jsonResponse.substring(
          1,
          jsonResponse.length - 1,
        );
      }
      jsonResponse = jsonResponse.replaceAll(r'\"', '"');
      final decoded = jsonDecode(jsonResponse);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (e) {
      debugPrint('WebView page-body scrape failed (non-fatal): $e');
    }
    return null;
  }

  void _finish({required bool success, Map<String, dynamic>? data, String? message}) {
    if (success) {
      Get.back(result: {'success': true, 'data': data});
      ToastHelper().showSuccessToast(
        localization.webViewScreenPaymentSuccessful,
      );
    } else {
      Get.back(result: {'success': false, 'data': data});
      ToastHelper().showErrorToast(
        message ?? localization.webViewScreenPaymentFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.back();
          ToastHelper().showErrorToast(
            localization.webViewScreenPaymentCancelled,
          );
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const CommonLoading(),
          ],
        ),
      ),
    );
  }
}
