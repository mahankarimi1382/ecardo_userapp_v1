import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class CommonAppBar extends StatelessWidget {
  final String title;
  final String? rightSideIcon;
  final GestureTapCallback? onPressed;
  final GestureTapCallback? backLogicFunction;
  final Widget? rightSideWidget;
  final int? selectedIndex;
  final FontWeight? fontWeight;
  final bool? isBackLogicApply;

  /// Accessible name for the right-side icon action. Falls back to a
  /// generic label when a caller does not supply one.
  final String? rightSideTooltip;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onPressed,
    this.rightSideIcon,
    this.rightSideWidget,
    this.selectedIndex,
    this.fontWeight = FontWeight.w700,
    this.isBackLogicApply = false,
    this.backLogicFunction,
    this.rightSideTooltip,
  });

  void _handleBack(BuildContext context) {
    if (isBackLogicApply == true && backLogicFunction != null) {
      backLogicFunction!.call();
      return;
    }
    if (selectedIndex != null) {
      try {
        Get.find<HomeController>().selectedIndex.value = 0;
      } catch (_) {}
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAllNamed(BaseRoute.navigation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.warmWhite : AppColors.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(start: 10.w),
                child: Tooltip(
                  message: l10nPick(context, en: 'Back', fa: 'بازگشت'),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _handleBack(context),
                    icon: Transform.scale(
                      scaleX: Directionality.of(context) == TextDirection.rtl
                          ? -1
                          : 1,
                      child: Image.asset(
                        PngAssets.arrowLeftCommonIcon,
                        width: 25.w,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: fontWeight,
                    fontSize: 16.sp,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ?rightSideWidget,
        if (rightSideWidget == null &&
            rightSideIcon != null &&
            onPressed != null)
          Container(
            margin: EdgeInsetsDirectional.only(end: 18.w),
            // 44x44 hit area around the 18px asset — icon size unchanged.
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Tooltip(
              message:
                  rightSideTooltip ??
                  l10nPick(context, en: 'Action', fa: 'عملیات'),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPressed,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Image.asset(rightSideIcon!, width: 18.w),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
