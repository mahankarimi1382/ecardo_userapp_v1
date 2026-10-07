import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// SERVICES HUB ENTRY — compact replacement for the three service grids and
/// the recent-transactions card that used to sit on the dashboard. One clean
/// card routes to the dedicated All-Services page, keeping the home screen
/// to balance / wallets / referral only.
class ServicesEntrySection extends StatelessWidget {
  const ServicesEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed(BaseRoute.services),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkPrimaryContainer
                        : AppColors.brandVioletContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.apps_rounded,
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.brandViolet,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'All Services',
                          fa: 'همه خدمات',
                          ar: 'جميع الخدمات',
                          zh: '全部服务',
                          ru: 'Все сервисы',
                          tr: 'Tüm Hizmetler',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10nPick(
                          context,
                          en: 'Financial, travel & business tools in one place',
                          fa: 'خدمات مالی، سفر و کسب‌وکار در یکجا',
                          ar: 'الخدمات المالية والسفر والأعمال في مكان واحد',
                          zh: '金融、旅行与商务服务一览',
                          ru: 'Финансовые, туристические и бизнес-сервисы',
                          tr: 'Finansal, seyahat ve işletme hizmetleri',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isRtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: 26,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
