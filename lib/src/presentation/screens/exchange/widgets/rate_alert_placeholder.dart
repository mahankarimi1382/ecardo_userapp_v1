import 'package:flutter/material.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

import '../../../../app/constants/app_colors.dart';

/// Placeholder UI for the (future) Rate Alert feature.
///
/// The brief said: build the UI surface, leave the API call as TODO. The
/// FCM infrastructure is already in the app — when the backend exposes
/// a "subscribe to rate alert" endpoint, wire it up here.
///
/// This widget is intentionally inert. It shows a bell icon and a
/// disabled-looking button labelled "Coming soon". The parent screen
/// can choose to render or omit it.
class RateAlertPlaceholder extends StatelessWidget {
  const RateAlertPlaceholder({super.key, required this.fromCode, required this.toCode, required this.currentRate});

  final String fromCode;
  final String toCode;
  final double currentRate;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightPrimaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightPrimary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            size: 18,
            color: AppColors.lightPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.exchangeRateAlertTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '1 $fromCode = ${currentRate.toStringAsFixed(6)} $toCode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          // TODO(rate-alert): wire to backend endpoint when available.
          //   POST /user/rate-alerts { from, to, threshold }
          //   Backend pushes via FCM topic `rate-alert-<userId>-<from>-<to>`
          //   when threshold is crossed.
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              loc.exchangeRateAlertPlaceholder,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
