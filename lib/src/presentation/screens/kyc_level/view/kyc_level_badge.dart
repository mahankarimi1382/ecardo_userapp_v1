import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

/// KycLevelBadge — نمایش badge سطح KYC کاربر
///
/// این widget در صفحه id_verification نمایش داده می‌شود
/// و وضعیت KYC کاربر را به‌صورت بصری نشان می‌دهد.
class KycLevelBadge extends StatefulWidget {
  final VoidCallback? onLevelTap;

  const KycLevelBadge({super.key, this.onLevelTap});

  @override
  State<KycLevelBadge> createState() => _KycLevelBadgeState();
}

class _KycLevelBadgeState extends State<KycLevelBadge> {
  final NetworkService _networkService = Get.find<NetworkService>();
  Map<String, dynamic>? _badge;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBadge();
  }

  Future<void> _fetchBadge() async {
    try {
      final response = await _networkService.get(
        endpoint: ApiPath.kycLevelBadgeEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _badge = data;
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_badge == null) {
      return const SizedBox.shrink();
    }

    final level = _badge!['level'] ?? 1;
    final name = _badge!['name'] ?? '';
    final kycStatus = _badge!['kyc_status'] ?? 'not_submitted';
    final color = _getStatusColor(kycStatus);
    final icon = _getStatusIcon(kycStatus);
    final statusText = _getStatusText(kycStatus);
    final nextLevel = _badge!['next_level'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Level Badge Icon
          Container(
            padding: const EdgeInsets.all(13),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 7),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: color,
            ),
          ),
          // Next level upgrade button
          if (nextLevel != null && widget.onLevelTap != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onLevelTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ارتقا به ${nextLevel['name']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'تأیید شده';
      case 'pending':
        return 'در حال بررسی';
      case 'failed':
        return 'رد شده';
      default:
        return 'ارسال نشده';
    }
  }
}
