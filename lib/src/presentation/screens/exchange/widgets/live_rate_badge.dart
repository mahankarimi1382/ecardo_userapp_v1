import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/constants/app_colors.dart';

/// Direction of the most recent rate change. Drives the arrow colour.
enum RateDirection { up, down, stable, unknown }

/// A compact, always-visible badge that shows:
///   - a pulsing green dot (live indicator)
///   - the current rate as `1 FROM = X.XXXX TO`
///   - an arrow indicating the direction of the last change
///   - a small "auto-update every 60s" caption
///   - a "stale" state when the rate service is disconnected
///
/// The badge is purely presentational — it reads from the controller and
/// renders. All polling / caching happens upstream in [ExchangeRateService].
class LiveRateBadge extends StatefulWidget {
  const LiveRateBadge({
    super.key,
    required this.fromCode,
    required this.toCode,
    required this.rate,
    required this.direction,
    required this.isStale,
    required this.isDisconnected,
    required this.lastUpdatedAt,
    required this.onManualRefresh,
  });

  /// Currency code on the "from" side, e.g. `USDT`.
  final String fromCode;

  /// Currency code on the "to" side, e.g. `BTC`.
  final String toCode;

  /// Current rate expressed as `1 fromCode = rate toCode`.
  final double rate;

  final RateDirection direction;

  /// True when the displayed rate is older than the freshness threshold.
  final bool isStale;

  /// True when the rate service has been failing repeatedly.
  final bool isDisconnected;

  /// Wall-clock of the last successful refresh (nullable until first fetch).
  final DateTime? lastUpdatedAt;

  /// User-initiated refresh — wire to `ExchangeRateService.forceRefresh()`.
  final VoidCallback onManualRefresh;

  @override
  State<LiveRateBadge> createState() => _LiveRateBadgeState();
}

class _LiveRateBadgeState extends State<LiveRateBadge>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          // Pulsing dot — turns amber when stale, red-tinged grey when
          // disconnected.
          _PulsingDot(
            animation: _pulseAnimation,
            color: widget.isDisconnected
                ? AppColors.grey
                : widget.isStale
                    ? AppColors.warning
                    : AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '1 ${widget.fromCode} =',
                      style: TextStyle(
                        fontSize: 12 * textScale.clamp(0.85, 1.15),
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextTertiary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.rate.isFinite && widget.rate > 0
                            ? _formatRate(widget.rate)
                            : '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * textScale.clamp(0.85, 1.15),
                          fontWeight: FontWeight.w900,
                          color: AppColors.lightTextPrimary,
                          letterSpacing: 0,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.toCode,
                      style: TextStyle(
                        fontSize: 12 * textScale.clamp(0.85, 1.15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextTertiary,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DirectionArrow(direction: widget.direction),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (widget.isDisconnected)
                      Text(
                        'rate_service_unavailable'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (widget.isStale)
                      Text(
                        'rate_stale_last_known'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        'rate_auto_update_caption'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const Spacer(),
                    if (widget.lastUpdatedAt != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: Text(
                          _formatTimestamp(widget.lastUpdatedAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.lightTextTertiary
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: widget.onManualRefresh,
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 12,
                              color: AppColors.lightPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'refresh'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format rate with up to 8 significant digits but no trailing zeros
  /// beyond the meaningful ones (so `0.00002340` → `0.0000234`, but
  /// `1.00000000` stays `1.00` for clarity).
  String _formatRate(double rate) {
    if (rate >= 1) return rate.toStringAsFixed(2);
    if (rate >= 0.01) return rate.toStringAsFixed(4);
    return rate.toStringAsFixed(8);
  }

  String _formatTimestamp(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = animation.value;
        final opacity = (1.0 - (scale - 1.0) / 0.4).clamp(0.0, 1.0);
        return SizedBox(
          width: 14,
          height: 14,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: opacity * 0.5,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DirectionArrow extends StatelessWidget {
  const _DirectionArrow({required this.direction});

  final RateDirection direction;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (direction) {
      RateDirection.up => (Icons.arrow_drop_up_rounded, AppColors.success),
      RateDirection.down => (Icons.arrow_drop_down_rounded, AppColors.error),
      RateDirection.stable => (Icons.remove_rounded, AppColors.grey),
      RateDirection.unknown => (Icons.remove_rounded, AppColors.greyLight),
    };

    return Icon(icon, color: color, size: 18);
  }
}
