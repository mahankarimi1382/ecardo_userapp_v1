import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// A circular or linear countdown timer showing remaining rate-lock duration.
///
/// Features:
/// - Smooth progress ring / bar animation.
/// - Dynamic status colors:
///   - Green ([AppColors.success]) when remaining duration > 20s
///   - Amber / Warning ([AppColors.warning]) when 10s - 20s
///   - Pulsating Red ([AppColors.error]) when < 10s
/// - Fires [onExpired] callback once when countdown reaches 0.
class RateLockCountdownTimer extends StatefulWidget {
  const RateLockCountdownTimer({
    super.key,
    this.duration = const Duration(seconds: 45),
    this.onExpired,
    this.onRefresh,
    this.isLinear = false,
    this.size = 36.0,
    this.strokeWidth = 3.0,
    this.showText = true,
    this.textStyle,
    this.startTime,
    this.isExpired = false,
    this.isPaused = false,
  });

  /// Total lock duration. Default is 45s (customizable from 15s to 60s).
  final Duration duration;

  /// Callback fired when the timer reaches 0.
  final VoidCallback? onExpired;

  /// Optional callback to request a new rate lock manually.
  final VoidCallback? onRefresh;

  /// If true, renders a horizontal progress bar instead of a circular ring.
  final bool isLinear;

  /// Diameter of the circular progress ring. Defaults to 36.0.
  final double size;

  /// Stroke width for circular ring or height of linear bar. Defaults to 3.0.
  final double strokeWidth;

  /// Whether to display remaining seconds text inside/alongside the timer.
  final bool showText;

  /// Custom text style for remaining seconds.
  final TextStyle? textStyle;

  /// Optional wall-clock timestamp of when the rate lock began.
  /// If provided, remaining time is derived from [DateTime.now()] - [startTime],
  /// avoiding animation drift.
  final DateTime? startTime;

  /// Explicit flag to force the timer into expired state (0s).
  final bool isExpired;

  /// Whether countdown animation is temporarily paused.
  final bool isPaused;

  @override
  State<RateLockCountdownTimer> createState() => _RateLockCountdownTimerState();
}

class _RateLockCountdownTimerState extends State<RateLockCountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _hasFiredExpired = false;

  @override
  void initState() {
    super.initState();

    _countdownController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _countdownController.addListener(_onCountdownTick);
    _pulseController.addListener(() {
      if (mounted) setState(() {});
    });

    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant RateLockCountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _countdownController.duration = widget.duration;
    }

    if (oldWidget.isExpired != widget.isExpired ||
        oldWidget.startTime != widget.startTime) {
      if (!widget.isExpired) {
        _hasFiredExpired = false;
        _startCountdown();
      } else {
        _countdownController.value = 1.0;
        _stopPulse();
      }
    }

    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _countdownController.stop();
        _stopPulse();
      } else {
        _countdownController.forward();
      }
    }
  }

  @override
  void dispose() {
    _countdownController.removeListener(_onCountdownTick);
    _countdownController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (widget.isExpired) {
      _countdownController.value = 1.0;
      return;
    }

    if (widget.startTime != null) {
      final elapsed = DateTime.now().difference(widget.startTime!);
      final elapsedMs = elapsed.inMilliseconds.clamp(
        0,
        widget.duration.inMilliseconds,
      );
      final initialProgress = elapsedMs / widget.duration.inMilliseconds;
      _countdownController.value = initialProgress;
    } else {
      _countdownController.reset();
    }

    if (!widget.isPaused) {
      _countdownController.forward();
    }
  }

  void _onCountdownTick() {
    final remaining = _getRemainingSeconds();

    if (remaining < 10 && remaining > 0 && !widget.isExpired) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _stopPulse();
    }

    if (remaining <= 0 && !_hasFiredExpired) {
      _hasFiredExpired = true;
      _stopPulse();
      widget.onExpired?.call();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _stopPulse() {
    if (_pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }
  }

  int _getRemainingSeconds() {
    if (widget.isExpired) return 0;

    if (widget.startTime != null) {
      final elapsed = DateTime.now().difference(widget.startTime!);
      final remainingMs =
          widget.duration.inMilliseconds - elapsed.inMilliseconds;
      if (remainingMs <= 0) return 0;
      return (remainingMs / 1000).ceil();
    }

    final double remainingFraction = (1.0 - _countdownController.value).clamp(
      0.0,
      1.0,
    );
    return (widget.duration.inSeconds * remainingFraction).ceil();
  }

  double _getProgress() {
    if (widget.isExpired) return 0.0;
    return (1.0 - _countdownController.value).clamp(0.0, 1.0);
  }

  Color _getCurrentColor(int remainingSeconds) {
    if (widget.isExpired || remainingSeconds <= 0) {
      return AppColors.error;
    }
    if (remainingSeconds > 20) {
      return AppColors.success;
    } else if (remainingSeconds >= 10) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  /// Non-colour carrier of the countdown state. Colour alone is not a
  /// sufficient signal for deuteranopia, so each state also gets its own
  /// icon and word.
  IconData _getStateIcon(int remainingSeconds) {
    if (widget.isExpired || remainingSeconds <= 0) {
      return Icons.error_outline_rounded;
    }
    if (remainingSeconds <= 10) {
      return Icons.priority_high_rounded;
    }
    if (remainingSeconds <= 20) {
      return Icons.watch_later_rounded;
    }
    return Icons.lock_clock_rounded;
  }

  /// Short state word shown next to the seconds so the countdown stays
  /// readable with no colour perception at all.
  String _getStateLabel(BuildContext context, int remainingSeconds) {
    if (widget.isExpired || remainingSeconds <= 0) {
      return l10nPick(context, en: 'expired', fa: 'منقضی');
    }
    if (remainingSeconds <= 10) {
      return l10nPick(context, en: 'expiring', fa: 'در حال انقضا');
    }
    if (remainingSeconds <= 20) {
      return l10nPick(context, en: 'ending', fa: 'رو به پایان');
    }
    return l10nPick(context, en: 'locked', fa: 'قفل‌شده');
  }

  /// Spoken label for screen readers — states the seconds and the phase in
  /// one string so the meaning survives without colour or sight.
  String _getSemanticLabel(BuildContext context, int remainingSeconds) {
    final state = _getStateLabel(context, remainingSeconds);
    final seconds = l10nPick(
      context,
      en: '$remainingSeconds seconds remaining',
      fa: '$remainingSeconds ثانیه باقی مانده',
    );
    return '$seconds — $state';
  }

  @override
  Widget build(BuildContext context) {
    final int remainingSeconds = _getRemainingSeconds();
    final double progress = _getProgress();
    final Color activeColor = _getCurrentColor(remainingSeconds);
    final bool isPulsing =
        remainingSeconds < 10 && remainingSeconds > 0 && !widget.isExpired;

    final Widget timerWidget = widget.isLinear
        ? _buildLinearTimer(progress, activeColor, remainingSeconds)
        : _buildCircularTimer(progress, activeColor, remainingSeconds);

    if (isPulsing) {
      return Transform.scale(scale: _pulseAnimation.value, child: timerWidget);
    }

    return timerWidget;
  }

  Widget _buildCircularTimer(
    double progress,
    Color color,
    int remainingSeconds,
  ) {
    final fontSize = (widget.size * 0.32).clamp(9.0, 14.0);
    final defaultStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.2,
    );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CircularProgressRingPainter(
              progress: progress,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
          if (widget.showText)
            Semantics(
              label: _getSemanticLabel(context, remainingSeconds),
              excludeSemantics: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                // Icon + seconds + state word: the countdown carries its
                // meaning in shape and text, not only in hue.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStateIcon(remainingSeconds),
                      size: fontSize * 0.9,
                      color: color,
                    ),
                    Text(
                      '${remainingSeconds}s',
                      style: widget.textStyle ?? defaultStyle,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _getStateLabel(context, remainingSeconds),
                      style: TextStyle(
                        fontSize: (fontSize * 0.6).clamp(7.0, 9.0),
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLinearTimer(double progress, Color color, int remainingSeconds) {
    return Semantics(
      label: _getSemanticLabel(context, remainingSeconds),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showText)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // State icon — a second, non-colour channel for the
                      // locked / ending / expiring / expired phase.
                      Icon(
                        _getStateIcon(remainingSeconds),
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${remainingSeconds}s',
                        style:
                            widget.textStyle ??
                            TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStateLabel(context, remainingSeconds),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  if (widget.onRefresh != null &&
                      (remainingSeconds < 10 || widget.isExpired))
                    // 44x44 transparent hit area around the 14px icon —
                    // the icon stays small, the target meets the minimum.
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Tooltip(
                        message: l10nPick(
                          context,
                          en: 'Lock rate again',
                          fa: 'قفل مجدد نرخ',
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onRefresh,
                          child: Center(
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Container(
            height: widget.strokeWidth,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(widget.strokeWidth / 2),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.strokeWidth / 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressRingPainter extends CustomPainter {
  const _CircularProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (radius <= 0) return;

    // Recessive track
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc (starts at 12 o'clock = -pi / 2, sweeps clockwise)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
