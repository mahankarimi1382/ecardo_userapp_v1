import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_spacing.dart';
import 'exchange_design_tokens.dart';

/// Direction of the most recent rate change. Drives the arrow colour.
enum RateDirection { up, down, stable, unknown }

/// Compact, always-visible live-rate badge.
///
/// Features:
///   - Real-time animated pulse dot (green = live, amber = stale, grey = disconnected)
///   - Tabular figures rate display
///   - 24h change pill with directional color indicator
///   - Accessible refresh button with >= 44x44 touch target & haptics
///   - Complete dark mode, RTL, and multilingual support
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
    this.changePercent,
    this.fromNameEn = '',
    this.toNameEn = '',
  });

  final String fromCode;
  final String toCode;
  final double rate;
  final RateDirection direction;
  final bool isStale;
  final bool isDisconnected;
  final DateTime? lastUpdatedAt;
  final VoidCallback onManualRefresh;

  /// 24h change percentage straight from the API (e.g. +0.17, -0.21).
  final double? changePercent;

  /// English name of the FROM currency (e.g. "US Dollar").
  final String fromNameEn;

  /// English name of the TO currency (e.g. "Euro").
  final String toNameEn;

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
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleManualRefresh() {
    HapticFeedback.lightImpact();
    widget.onManualRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final textScale =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.85, 1.15);

    final dotColor = widget.isDisconnected
        ? AppColors.grey
        : widget.isStale
            ? AppColors.warning
            : AppColors.success;

    final showChangePill = !widget.isDisconnected &&
        !widget.isStale &&
        widget.changePercent != null;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: ExchangeDesignTokens.cardSurface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: ExchangeDesignTokens.cardBorder(context),
        ),
        boxShadow: ExchangeDesignTokens.cardShadow(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pulsing live indicator dot
          _PulsingDot(
            animation: _pulseAnimation,
            color: dotColor,
            active: !widget.isStale && !widget.isDisconnected,
          ),
          const SizedBox(width: AppSpacing.md),
          // Rate block
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
                        fontSize: 12 * textScale,
                        fontWeight: FontWeight.w600,
                        color: ExchangeDesignTokens.textTertiary(context),
                        letterSpacing: 0,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Flexible(
                      child: Text(
                        widget.rate.isFinite && widget.rate > 0
                            ? _formatRate(widget.rate)
                            : '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.w900,
                          color: ExchangeDesignTokens.textPrimary(context),
                          letterSpacing: 0,
                          fontFamily: 'Plus Jakarta Sans',
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      widget.toCode,
                      style: TextStyle(
                        fontSize: 12 * textScale,
                        fontWeight: FontWeight.w700,
                        color: ExchangeDesignTokens.textTertiary(context),
                        letterSpacing: 0,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                // Subtitle: currency names OR status line
                _buildSubtitle(context),
              ],
            ),
          ),
          // Right side: 24h change pill OR direction arrow fallback
          if (showChangePill)
            _ChangePill(percent: widget.changePercent!)
          else
            _DirectionArrow(direction: widget.direction),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    if (widget.isDisconnected) {
      return Text(
        _t(
          context,
          en: 'Rate service unavailable',
          fa: 'سرویس نرخ در دسترس نیست',
          ar: 'خدمة الأسعار غير متاحة',
          tr: 'Kur servisi kullanılamıyor',
          ru: 'Сервис курсов недоступен',
          zh: '汇率服务不可用',
        ),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.error,
          fontWeight: FontWeight.w600,
          fontFamily: 'Plus Jakarta Sans',
        ),
      );
    }
    if (widget.isStale) {
      return Row(
        children: [
          Text(
            _t(
              context,
              en: 'Showing last known rate',
              fa: 'نمایش آخرین نرخ معتبر',
              ar: 'عرض آخر سعر معروف',
              tr: 'Son bilinen kur gösteriliyor',
              ru: 'Показан последний известный курс',
              zh: '显示最近的有效汇率',
            ),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          if (widget.lastUpdatedAt != null) ...[
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              '· ${_formatTimestamp(widget.lastUpdatedAt!)}',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.warning.withValues(alpha: 0.8),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ],
      );
    }

    // Normal: from -> to names + auto-update caption + refresh button
    return Row(
      children: [
        Expanded(
          child: Text(
            _namesLine(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: ExchangeDesignTokens.textTertiary(context).withValues(
                alpha: 0.85,
              ),
              fontWeight: FontWeight.w500,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
        if (widget.lastUpdatedAt != null) ...[
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            '${_t(
              context,
              en: 'Updated',
              fa: 'به‌روزرسانی',
              ar: 'تحديث',
              tr: 'Güncellendi',
              ru: 'Обновлено',
              zh: '已更新',
            )} · ${_formatTimestamp(widget.lastUpdatedAt!)}',
            style: TextStyle(
              fontSize: 10,
              color: ExchangeDesignTokens.textTertiary(context).withValues(
                alpha: 0.7,
              ),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
        const SizedBox(width: AppSpacing.sm),
        Semantics(
          button: true,
          label: 'Refresh live rate',
          child: Tooltip(
            message: _t(
              context,
              en: 'Refresh',
              fa: 'به‌روزرسانی',
              ar: 'تحديث',
              tr: 'Yenile',
              ru: 'Обновить',
              zh: '刷新',
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              onTap: _handleManualRefresh,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 28,
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: ExchangeDesignTokens.chipBackground(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 13,
                      color: ExchangeDesignTokens.chipText(context),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _t(
                        context,
                        en: 'Refresh',
                        fa: 'به‌روزرسانی',
                        ar: 'تحديث',
                        tr: 'Yenile',
                        ru: 'Обновить',
                        zh: '刷新',
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ExchangeDesignTokens.chipText(context),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _t(
    BuildContext context, {
    required String en,
    required String fa,
    required String ar,
    required String tr,
    required String ru,
    required String zh,
  }) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'fa':
        return fa;
      case 'ar':
        return ar;
      case 'tr':
        return tr;
      case 'ru':
        return ru;
      case 'zh':
        return zh;
      default:
        return en;
    }
  }

  String _namesLine() {
    final from =
        widget.fromNameEn.isNotEmpty ? widget.fromNameEn : widget.fromCode;
    final to = widget.toNameEn.isNotEmpty ? widget.toNameEn : widget.toCode;
    return '$from → $to';
  }

  String _formatRate(double rate) {
    if (rate >= 1) return rate.toStringAsFixed(rate >= 100 ? 0 : 2);
    if (rate >= 0.01) return rate.toStringAsFixed(4);
    return rate.toStringAsFixed(8);
  }

  String _formatTimestamp(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }
}

class _ChangePill extends StatelessWidget {
  const _ChangePill({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final isUp = percent >= 0;
    final color = isUp ? AppColors.success : AppColors.error;
    final arrowIcon = isUp
        ? Icons.arrow_drop_up_rounded
        : Icons.arrow_drop_down_rounded;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(arrowIcon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${isUp ? '+' : ''}${percent.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0,
              fontFamily: 'Plus Jakarta Sans',
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({
    required this.animation,
    required this.color,
    required this.active,
  });

  final Animation<double> animation;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return SizedBox(
        width: 14,
        height: 14,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
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
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = animation.value;
        final opacity = (1.0 - (scale - 1.0) / 0.45).clamp(0.0, 1.0);
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
