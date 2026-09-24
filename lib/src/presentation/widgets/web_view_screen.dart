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

    final paymentUri = Uri.tryParse(widget.paymentUrl);
    if (paymentUri == null || paymentUri.scheme != 'https') {
      // A payment redirect is security-sensitive. Never render an arbitrary
      // scheme (or cleartext URL) supplied by a malformed backend response.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finish(success: false, data: null);
      });
      return;
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            // Gateways can use several hosts, but payment content must remain
            // HTTPS. Block intent:, file:, javascript: and cleartext redirects.
            if (uri == null || uri.scheme != 'https') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
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

  /// Single decision point for the return URL. The authenticated server
  /// (payment-status API) is the only authoritative source.
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

    // A URL or page body is controlled by the gateway and is never proof of a
    // financial outcome. Only the authenticated payment-status endpoint may
    // produce a success result; an unknown status must fail closed.
    _finish(
      success: false,
      data: null,
      message: treatAsSuccessHint
          ? 'Payment could not be verified. Please check your transaction history.'
          : null,
    );
  }

  /// Returns true/false when the server gives a definitive verdict, or null
  /// when the payment cannot be verified.
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
