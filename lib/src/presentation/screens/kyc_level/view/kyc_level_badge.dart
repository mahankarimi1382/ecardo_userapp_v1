import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

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
  void initState() { super.initState(); _fetchBadge(); }
  Future<void> _fetchBadge() async {
    try {
      final response = await _networkService.get(endpoint: ApiPath.kycLevelBadgeEndpoint);
      if (response.status == Status.completed && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) { setState(() {_badge = data; _isLoading = false;}); return; }
      }
      setState(() => _isLoading = false);
    } catch (e) { setState(() => _isLoading = false); }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_badge == null) return const SizedBox.shrink();
    final kycStatus = _badge!['kyc_status'] ?? 'not_submitted';
    final name = _badge!['name'] ?? '';
    final color = _getStatusColor(kycStatus);
    final nextLevel = _badge!['next_level'] as Map<String, dynamic>?;
    return Container(width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(13), width: 50, height: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: color),
          child: Icon(_getStatusIcon(kycStatus), color: Colors.white)),
        const SizedBox(height: 7),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        const SizedBox(height: 4),
        Text(_getStatusText(kycStatus), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
        if (nextLevel != null && widget.onLevelTap != null) ...[const SizedBox(height: 12),
          ElevatedButton(onPressed: widget.onLevelTap,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary, foregroundColor: Colors.white),
            child: Text('ارتقا به ${nextLevel['name']}'))],
      ]));
  }
  Color _getStatusColor(String s) => s == 'verified' ? Colors.green : s == 'pending' ? Colors.orange : s == 'failed' ? Colors.red : Colors.grey;
  IconData _getStatusIcon(String s) => s == 'verified' ? Icons.check_circle_outline : s == 'pending' ? Icons.pending : s == 'failed' ? Icons.error_outline : Icons.info_outline;
  String _getStatusText(String s) => s == 'verified' ? 'تأیید شده' : s == 'pending' ? 'در حال بررسی' : s == 'failed' ? 'رد شده' : 'ارسال نشده';
}
