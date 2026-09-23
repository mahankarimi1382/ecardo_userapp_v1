import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/empty_view.dart';

class DynamicPasswordScreen extends StatefulWidget {
  const DynamicPasswordScreen({super.key});

  @override
  State<DynamicPasswordScreen> createState() => _DynamicPasswordScreenState();
}

class _DynamicPasswordScreenState extends State<DynamicPasswordScreen> {
  // M-2 (PAYMENT-FIX): this route has no binding of its own, so a direct /
  // deep navigation used to crash on `Get.find<HomeController>()`. Look the
  // controller up only when it is actually registered; otherwise the account
  // number stays empty and OTP generation fails with the localized
  // "user not found" error (fail-closed, no crash).
  final HomeController? _homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : null;

  String? _otpCode;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generateOtp() async {
    // M-3 (PAYMENT-FIX): in-flight guard — a double tap on generate /
    // regenerate must not mint two OTPs at once.
    if (_isLoading) return;
    setState(() => _isLoading = true);
    _timer?.cancel();

    try {
      final accountNumber =
          _homeController?.userModel.value.data?.accountNumber ?? '';

      if (accountNumber.isEmpty) {
        // v1.0.24: localized instead of hardcoded Persian strings.
        ToastHelper().showErrorToast(
          AppLocalizations.of(Get.context!)!.dynamicPasswordUserNotFound,
        );
        setState(() => _isLoading = false);
        return;
      }

      final response = await Get.find<NetworkService>().post(
        // M-3 (PAYMENT-FIX): path moved into ApiPath (value unchanged).
        endpoint: ApiPath.generateDynamicPasswordOtpEndpoint,
        data: {'account_number': accountNumber},
      );

      if (response.status == Status.completed && response.data != null) {
        final responseData = response.data!;
        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          setState(() {
            _otpCode = data['code']?.toString() ?? '';
            _secondsRemaining = data['expires_in'] ?? 60;
            _isLoading = false;
          });
          _startCountdown();
        } else {
          ToastHelper().showErrorToast(
            responseData['message'] ??
                AppLocalizations.of(Get.context!)!
                    .dynamicPasswordGenerateError,
          );
          setState(() => _isLoading = false);
        }
      } else {
        ToastHelper().showErrorToast(response.message ?? AppLocalizations.of(Get.context!)!.dynamicPasswordServerError);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ToastHelper().showErrorToast(AppLocalizations.of(Get.context!)!.dynamicPasswordConnectionError);
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        setState(() => _otpCode = null);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
        final accountNumber =
        _homeController?.userModel.value.data?.accountNumber ?? '';
    if (_homeController == null || accountNumber.isEmpty) {
      final code = Localizations.localeOf(context).languageCode;
      String title;
      String subtitle;
      String back;
      if (code == 'fa') {
        title = 'حساب آماده نیست';
        subtitle =
            'ابتدا صفحهٔ اصلی را باز کنید تا شماره حساب بارگذاری شود، سپس دوباره تلاش کنید.';
        back = 'بازگشت';
      } else if (code == 'ar') {
        title = 'الحساب غير جاهز';
        subtitle =
            'افتح الشاشة الرئيسية أولاً لتحميل رقم الحساب ثم حاول مرة أخرى.';
        back = 'رجوع';
      } else {
        title = 'Account not ready';
        subtitle =
            'Open the home screen first so your account number is loaded, then try again.';
        back = 'Go back';
      }
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.dynamicPasswordHeading),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        body: Center(
          child: EmptyView(
            icon: Icons.lock_outline_rounded,
            title: title,
            subtitle: subtitle,
            ctaLabel: back,
            onCta: () => Get.back(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // v1.0.24: localized instead of hardcoded Persian title.
        title: Text(AppLocalizations.of(context)!.dynamicPasswordTitle),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.lightTextPrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.pin_rounded, size: 40, color: AppColors.lightPrimary),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.dynamicPasswordHeading,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.dynamicPasswordSubtitle,
                style: TextStyle(fontSize: 14, color: Color(0xFF8898AA))),
            const SizedBox(height: 40),

            if (_isLoading)
              const CircularProgressIndicator(color: AppColors.lightPrimary)
            else if (_otpCode != null && _secondsRemaining > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  children: [
                    Text(_otpCode!,
                        style: const TextStyle(
                            fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.lightPrimary, letterSpacing: 8)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _secondsRemaining <= 10
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppColors.lightPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 16,
                              color: _secondsRemaining <= 10 ? Colors.red : AppColors.lightPrimary),
                          const SizedBox(width: 4),
                          Text(_formattedTime,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _secondsRemaining <= 10 ? Colors.red : AppColors.lightPrimary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.dynamicPasswordValidity,
                        style: TextStyle(fontSize: 11, color: Color(0xFF8898AA))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _otpCode!));
                  ToastHelper().showSuccessToast(AppLocalizations.of(Get.context!)!.dynamicPasswordCopied);
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(AppLocalizations.of(context)!.dynamicPasswordCopy),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _generateOtp,
                child: Text(AppLocalizations.of(context)!.dynamicPasswordRegenerate, style: TextStyle(color: AppColors.lightPrimary)),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateOtp,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(AppLocalizations.of(context)!.dynamicPasswordGenerate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],

            const Spacer(),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF92400E), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.dynamicPasswordUsageHint,
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
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
}
