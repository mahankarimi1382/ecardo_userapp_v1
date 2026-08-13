import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class DynamicPasswordScreen extends StatefulWidget {
  const DynamicPasswordScreen({super.key});

  @override
  State<DynamicPasswordScreen> createState() => _DynamicPasswordScreenState();
}

class _DynamicPasswordScreenState extends State<DynamicPasswordScreen> {
  final HomeController _homeController = Get.find<HomeController>();

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
    setState(() => _isLoading = true);
    _timer?.cancel();

    try {
      final accountNumber = _homeController.userModel.value.data?.accountNumber ?? '';

      if (accountNumber.isEmpty) {
        ToastHelper().showErrorToast('خطا: اطلاعات کاربر یافت نشد');
        setState(() => _isLoading = false);
        return;
      }

      final response = await Get.find<NetworkService>().post(
        endpoint: '/pay/generate-otp',
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
            responseData['message'] ?? 'خطا در تولید رمز',
          );
          setState(() => _isLoading = false);
        }
      } else {
        ToastHelper().showErrorToast(response.message ?? 'خطا در ارتباط با سرور');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ToastHelper().showErrorToast('خطای اتصال');
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('رمز پویا'),
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
            const Text('رمز پویا',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
            const SizedBox(height: 8),
            const Text('رمز ۶ رقمی برای پرداخت از کیف پول',
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
                    const Text('اعتبار: ۶۰ ثانیه — فقط یک بار قابل استفاده',
                        style: TextStyle(fontSize: 11, color: Color(0xFF8898AA))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _otpCode!));
                  ToastHelper().showSuccessToast('رمز کپی شد');
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('کپی رمز'),
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
                child: const Text('تولید رمز جدید', style: TextStyle(color: AppColors.lightPrimary)),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateOtp,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('تولید رمز پویا', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF92400E), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'این رمز را در صفحه پرداخت وارد کنید. رمز فقط ۶۰ ثانیه اعتبار دارد و فقط یک بار قابل استفاده است.',
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
