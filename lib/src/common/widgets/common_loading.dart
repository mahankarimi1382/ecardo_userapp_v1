import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class CommonLoading extends StatelessWidget {
  final bool? isColorShow;

  const CommonLoading({super.key, this.isColorShow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isColorShow == true
          ? AppColors.black.withValues(alpha: 0.1)
          : null,
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: AppColors.lightPrimary,
          size: 50,
        ),
      ),
    );
  }
}
