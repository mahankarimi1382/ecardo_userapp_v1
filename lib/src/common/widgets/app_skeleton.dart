import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// AppSkeleton — standard shimmer loading skeleton for lists, cards, and avatars.
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  factory AppSkeleton.circle({required double size, EdgeInsetsGeometry? margin}) => AppSkeleton(
        width: size,
        height: size,
        shape: BoxShape.circle,
        margin: margin,
      );

  factory AppSkeleton.card({
    double? width,
    double height = 90.0,
    double borderRadius = 16.0,
    EdgeInsetsGeometry? margin,
  }) =>
      AppSkeleton(
        width: width ?? double.infinity,
        height: height,
        borderRadius: borderRadius,
        margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      );

  factory AppSkeleton.line({
    double? width,
    double height = 16.0,
    EdgeInsetsGeometry? margin,
  }) =>
      AppSkeleton(
        width: width ?? double.infinity,
        height: height,
        borderRadius: 8.0,
        margin: margin ?? EdgeInsets.symmetric(vertical: 4.h),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkGray : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: width?.w,
          height: height?.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: shape,
            borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius.r),
          ),
        ),
      ),
    );
  }
}

/// A standard list skeleton showing N placeholder cards
class AppListSkeleton extends StatelessWidget {
  final int count;
  final double itemHeight;

  const AppListSkeleton({
    super.key,
    this.count = 4,
    this.itemHeight = 84.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => AppSkeleton.card(height: itemHeight),
    );
  }
}
