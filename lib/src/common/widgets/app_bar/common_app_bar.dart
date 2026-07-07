import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class CommonAppBar extends StatelessWidget {
  final String title;
  final String? rightSideIcon;
  final GestureTapCallback? onPressed;
  final GestureTapCallback? backLogicFunction;
  final Widget? rightSideWidget;
  final int? selectedIndex;
  final FontWeight? fontWeight;
  final bool? isBackLogicApply;

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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 10.w),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  if (selectedIndex != null) {
                    Get.find<HomeController>().selectedIndex.value = 0;
                    if (Navigator.canPop(context)) Get.back();
                  } else if (isBackLogicApply == true) {
                    backLogicFunction?.call();
                  } else {
                    if (Navigator.canPop(context)) Get.back();
                  }
                },
                icon: Image.asset(
                  PngAssets.arrowLeftCommonIcon,
                  width: 25.w,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              title,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: fontWeight,
                fontSize: 16.sp,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        if (rightSideWidget != null) rightSideWidget!,
        if (rightSideWidget == null &&
            rightSideIcon != null &&
            onPressed != null)
          Container(
            margin: EdgeInsetsDirectional.only(end: 18.w),
            padding: EdgeInsets.all(6.r),
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: GestureDetector(
              onTap: onPressed,
              child: Image.asset(rightSideIcon!, width: 18.w),
            ),
          ),
      ],
    );
  }
}
