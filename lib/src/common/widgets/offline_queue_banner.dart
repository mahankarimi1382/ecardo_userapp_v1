import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/offline_request_queue.dart';

/// Session-dismissible warning when offline queue flush failed.
class OfflineQueueBanner extends StatefulWidget {
  const OfflineQueueBanner({super.key});

  @override
  State<OfflineQueueBanner> createState() => _OfflineQueueBannerState();
}

class _OfflineQueueBannerState extends State<OfflineQueueBanner> {
  bool _dismissedThisSession = false;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OfflineRequestQueue>()) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      final q = Get.find<OfflineRequestQueue>();
      final count = q.pending.length;
      final failed = q.flushFailed.value;
      if (_dismissedThisSession || count == 0 || !failed) {
        return const SizedBox.shrink();
      }
      return Material(
        color: const Color(0xFFFFF3CD), // warning amber (not fatal red)
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page,
              vertical: 8,
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFB45309)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$count درخواست در انتظار ارسال',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await q.flush(manual: true);
                    if (q.pending.isEmpty) {
                      q.flushFailed.value = false;
                    }
                  },
                  child: const Text(
                    'تلاش مجدد',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _dismissedThisSession = true),
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
