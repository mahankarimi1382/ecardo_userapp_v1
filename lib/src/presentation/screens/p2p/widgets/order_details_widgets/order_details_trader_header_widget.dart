import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

import '../../../../../app/constants/assets_path/svg/svg_assets.dart';

class OrderDetailsTraderHeaderWidget extends StatelessWidget {
  final String avatarText;
  final String name;
  final bool isVerified;
  final VoidCallback? onTap;

  const OrderDetailsTraderHeaderWidget({
    super.key,
    required this.avatarText,
    required this.name,
    required this.isVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.7),
            ),
            child: Center(
              child: Text(
                avatarText,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                if (isVerified) ...[
                  SizedBox(width: 4.w),
                  SvgPicture.asset(
                    SvgAssets.commonIdVerifiedBadgeIcon,
                    width: 15.w,
                    height: 15.h,
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(
              Icons.message,
              size: 22.w,
              color: AppColors.lightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
