import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';

class RecentBillItem {
  final String id;
  final String title;
  final String identifier;
  final String serviceType;
  final String? operatorId;
  final String operatorName;
  final int lastAmountToman;
  final String lastDate;
  final String route;
  final Color tintColor;
  final IconData iconData;
  bool isFavorite;

  RecentBillItem({
    required this.id,
    required this.title,
    required this.identifier,
    required this.serviceType,
    this.operatorId,
    required this.operatorName,
    required this.lastAmountToman,
    required this.lastDate,
    required this.route,
    required this.tintColor,
    required this.iconData,
    this.isFavorite = true,
  });
}

class RecentFavoriteBillsStrip extends StatefulWidget {
  final Function(RecentBillItem item)? onQuickPay;

  const RecentFavoriteBillsStrip({
    super.key,
    this.onQuickPay,
  });

  @override
  State<RecentFavoriteBillsStrip> createState() => _RecentFavoriteBillsStripState();
}

class _RecentFavoriteBillsStripState extends State<RecentFavoriteBillsStrip> {
  final List<RecentBillItem> _bills = [
    RecentBillItem(
      id: '1',
      title: 'سیم‌کارت مادر (Mom)',
      identifier: '0912 345 6789',
      serviceType: 'airtime',
      operatorId: 'mci',
      operatorName: 'همراه اول',
      lastAmountToman: 100000,
      lastDate: '۲ روز پیش',
      route: BaseRoute.airtime,
      tintColor: const Color(0xFF00A499),
      iconData: Icons.phone_android_rounded,
      isFavorite: true,
    ),
    RecentBillItem(
      id: '2',
      title: 'ایرانسل من (My Phone)',
      identifier: '0935 987 6543',
      serviceType: 'airtime',
      operatorId: 'irancell',
      operatorName: 'ایرانسل',
      lastAmountToman: 200000,
      lastDate: 'هفته گذشته',
      route: BaseRoute.airtime,
      tintColor: const Color(0xFFFFCC00),
      iconData: Icons.sim_card_rounded,
      isFavorite: true,
    ),
    RecentBillItem(
      id: '3',
      title: 'برق آپارتمان (Home)',
      identifier: 'شناسه: ۸۸۲۱۹۴۰۱',
      serviceType: 'electricity',
      operatorName: 'توانیر',
      lastAmountToman: 145000,
      lastDate: 'ماه پیش',
      route: BaseRoute.electricity,
      tintColor: const Color(0xFFF59E0B),
      iconData: Icons.electric_bolt_rounded,
      isFavorite: true,
    ),
    RecentBillItem(
      id: '4',
      title: 'آب و فاضلاب دفتر',
      identifier: 'شناسه: ۴۹۲۰۱۹۳۴',
      serviceType: 'water',
      operatorName: 'سازمان آب',
      lastAmountToman: 85000,
      lastDate: '۲ هفته پیش',
      route: BaseRoute.electricity, // Navigates to utility flow
      tintColor: const Color(0xFF06B6D4),
      iconData: Icons.water_drop_rounded,
      isFavorite: false,
    ),
    RecentBillItem(
      id: '5',
      title: 'عوارض آزادراه شمال',
      identifier: 'پلاک: ۲۴ب۸۹۲',
      serviceType: 'toll',
      operatorName: 'آزادراه‌ها',
      lastAmountToman: 35000,
      lastDate: 'دیروز',
      route: BaseRoute.toll,
      tintColor: const Color(0xFF10B981),
      iconData: Icons.toll_rounded,
      isFavorite: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16.w,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'قبوض و شماره‌های پرتکرار',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'شارژ ۱-لمسی',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 146.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _bills.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = _bills[index];
              return _RecentBillCard(
                item: item,
                isDark: isDark,
                onFavoriteToggle: () {
                  setState(() {
                    item.isFavorite = !item.isFavorite;
                  });
                },
                onQuickPay: () {
                  if (widget.onQuickPay != null) {
                    widget.onQuickPay!(item);
                  } else {
                    Get.toNamed(item.route, arguments: {
                      'prefill_id': item.identifier,
                      'operator_id': item.operatorId,
                      'amount': item.lastAmountToman,
                    });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentBillCard extends StatelessWidget {
  final RecentBillItem item;
  final bool isDark;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onQuickPay;

  const _RecentBillCard({
    required this.item,
    required this.isDark,
    required this.onFavoriteToggle,
    required this.onQuickPay,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Container(
      width: 175.w,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onQuickPay,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: item.tintColor.withValues(alpha: isDark ? 0.25 : 0.14),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        item.iconData,
                        size: 17.w,
                        color: item.tintColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Icon(
                        item.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 19.w,
                        color: item.isFavorite
                            ? const Color(0xFFF59E0B)
                            : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.identifier,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // 1-Tap Recharge Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  decoration: BoxDecoration(
                    color: item.tintColor.withValues(alpha: isDark ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 13.w,
                        color: item.tintColor,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '${_formatAmount(item.lastAmountToman)} ت',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : item.tintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toInt()}k';
    }
    return amount.toString();
  }
}
