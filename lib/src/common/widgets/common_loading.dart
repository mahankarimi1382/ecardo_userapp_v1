import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

class CommonLoading extends StatelessWidget {
  final bool? isColorShow;
  final Color? color;
  final double size;

  const CommonLoading({
    super.key,
    this.isColorShow = false,
    this.color,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isColorShow == true
          ? AppColors.black.withValues(alpha: 0.1)
          : null,
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: effectiveColor,
          size: size,
        ),
      ),
    );
  }
}
