import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Shown at the top of a screen when displaying cached (offline) data.
class StaleDataBanner extends StatelessWidget {
  final DateTime cachedAt;
  final VoidCallback? onRetry;

  const StaleDataBanner({
    super.key,
    required this.cachedAt,
    this.onRetry,
  });

  String _ageLabel() {
    final diff = DateTime.now().difference(cachedAt);
    if (diff.inMinutes < 1) return l10nPickAuto(en: 'just now', fa: 'همین الان');
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${l10nPickAuto(en: 'minutes ago', fa: 'دقیقه پیش')}';
    if (diff.inHours < 24) return '${diff.inHours} ${l10nPickAuto(en: 'hours ago', fa: 'ساعت پیش')}';
    return '${diff.inDays} ${l10nPickAuto(en: 'days ago', fa: 'روز پیش')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning.withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${l10nPickAuto(en: 'Offline — showing data from', fa: 'آفلاین — نمایش داده از')} ${_ageLabel()}',
              style: const TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Text(
                l10nPickAuto(en: 'Retry', fa: 'تلاش مجدد'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
