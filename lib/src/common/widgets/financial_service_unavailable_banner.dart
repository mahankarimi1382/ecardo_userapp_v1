import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Reusable banner for specialized financial modules when backend endpoints
/// are under maintenance or pending deployment.
class FinancialServiceUnavailableBanner extends StatelessWidget {
  final String serviceNameFa;
  final String serviceNameEn;
  final String? serviceNameAr;
  final String? serviceNameZh;
  final VoidCallback? onRetry;
  final bool isCompact;

  const FinancialServiceUnavailableBanner({
    super.key,
    required this.serviceNameFa,
    required this.serviceNameEn,
    this.serviceNameAr,
    this.serviceNameZh,
    this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = l10nPick(
      context,
      fa: 'زیرساخت $serviceNameFa در حال راه‌اندازی',
      en: '$serviceNameEn Infrastructure Under Maintenance',
      ar: 'بنية $serviceNameFa قيد التجهيز',
      zh: '$serviceNameEn 基础设施正在维护',
    );

    final description = l10nPick(
      context,
      fa: 'ارتباط مستقیم با درگاه ارائه‌دهنده بانکی/مالی در حال به‌روزرسانی است. در حال حاضر امکان ثبت تراکنش زنده میسر نیست و فرم‌ها به صورت آزمایشی در دسترس هستند.',
      en: 'Direct gateway integration is currently undergoing system upgrades. Live transactions are temporarily paused; preview mode is enabled.',
      ar: 'جاري تحديث الربط المباشر مع البوابة المالية. العمليات المباشرة متوقفة مؤقتاً.',
      zh: '与银行/金融提供商网关的直连正在升级中。实时交易暂时暂停。',
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.all(isCompact ? 12.r : 16.r),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_sync_rounded,
              color: AppColors.warning,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'بک‌اند ناموجود',
                          en: 'Backend Pending',
                          ar: 'الخادم قيد الانتظار',
                          zh: '后端待就绪',
                        ),
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.5,
                    color: const Color(0xFFB45309),
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: onRetry,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 14.sp,
                            color: const Color(0xFF92400E),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            l10nPick(
                              context,
                              fa: 'تلاش مجدد اتصال',
                              en: 'Retry Connection',
                              ar: 'إعادة المحاولة',
                              zh: '重试连接',
                            ),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
