import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Modern FinTech "Swipe to Confirm" slider for high-confidence financial actions.
/// Provides tactile haptic feedback, spring physics, glowing slider thumb, and loading state.
class SwipeToConfirmSlider extends StatefulWidget {
  final String text;
  final VoidCallback onConfirmed;
  final bool isLoading;
  final double height;

  const SwipeToConfirmSlider({
    super.key,
    this.text = 'Swipe to Confirm Transfer',
    required this.onConfirmed,
    this.isLoading = false,
    this.height = 56.0,
  });

  @override
  State<SwipeToConfirmSlider> createState() => _SwipeToConfirmSliderState();
}

class _SwipeToConfirmSliderState extends State<SwipeToConfirmSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animController.addListener(() {
      setState(() {
        _dragPosition = _slideAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeToConfirmSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading) {
      _resetSlider();
    }
  }

  void _resetSlider() {
    _hasTriggered = false;
    _slideAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final thumbSize = widget.height - 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = math.max(0.0, constraints.maxWidth - widget.height);
        final progress = maxDrag > 0 ? (_dragPosition / maxDrag).clamp(0.0, 1.0) : 0.0;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.5),
              width: 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Filled track progress
              Container(
                width: _dragPosition + widget.height,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                      colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),

              // Centered prompt text (fades as user drags)
              Center(
                child: Opacity(
                  opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable Slider Thumb
              Positioned(
                left: _dragPosition + 4.0,
                child: GestureDetector(
                  onHorizontalDragStart: (_) {
                    if (widget.isLoading || _hasTriggered) return;
                    _animController.stop();
                    setState(() {
                      _isDragging = true;
                    });
                    HapticFeedback.selectionClick();
                  },
                  onHorizontalDragUpdate: (details) {
                    if (widget.isLoading || _hasTriggered) return;
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx)
                          .clamp(0.0, maxDrag);
                    });

                    // Light haptic feedback as threshold is approached
                    if (progress > 0.8 && !_hasTriggered) {
                      HapticFeedback.lightImpact();
                    }
                  },
                  onHorizontalDragEnd: (_) {
                    if (widget.isLoading || _hasTriggered) return;
                    setState(() {
                      _isDragging = false;
                    });

                    if (progress >= 0.85) {
                      _hasTriggered = true;
                      HapticFeedback.heavyImpact();
                      // Snap to end
                      _slideAnimation = Tween<double>(
                        begin: _dragPosition,
                        end: maxDrag,
                      ).animate(CurvedAnimation(
                        parent: _animController,
                        curve: Curves.easeOutCubic,
                      ));
                      _animController.forward(from: 0.0).then((_) {
                        widget.onConfirmed();
                      });
                    } else {
                      // Snap back to start
                      _resetSlider();
                    }
                  },
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          isDark ? AppColors.mutedBlue : AppColors.darkGray,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(
                            alpha: _isDragging ? 0.5 : 0.35,
                          ),
                          blurRadius: _isDragging ? 12 : 8,
                          spreadRadius: _isDragging ? 2 : 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: colorScheme.onPrimary,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
