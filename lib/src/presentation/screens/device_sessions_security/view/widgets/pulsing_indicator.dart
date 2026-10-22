import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// Pulsing indicator widget for "Active Now" live state.
class PulsingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingIndicator({
    super.key,
    this.color = AppColors.success,
    this.size = 9.0,
  });

  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(PulsingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (!mounted) return;
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.reset();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SizedBox(
      width: widget.size * 2.4,
      height: widget.size * 2.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!disableAnimations)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final scale = _animation.value;
                final opacity = (1.0 - (scale - 1.0) / 1.2).clamp(0.0, 1.0);
                return Container(
                  width: widget.size * scale,
                  height: widget.size * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: opacity * 0.45),
                  ),
                );
              },
            ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
