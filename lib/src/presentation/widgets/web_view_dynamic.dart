import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewDynamic extends StatefulWidget {
  final String dynamicUrl;

  const WebViewDynamic({super.key, required this.dynamicUrl});

  @override
  State<WebViewDynamic> createState() => _WebViewDynamicState();
}

class _WebViewDynamicState extends State<WebViewDynamic> {
  final WebViewController _controller = WebViewController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    String finalUrl = widget.dynamicUrl.replaceFirst('/api', '');

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(finalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: const CommonDefaultAppBar(),
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
