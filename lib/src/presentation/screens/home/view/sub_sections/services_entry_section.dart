import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// PREMIER SERVICES HUB ENTRY
///
/// An interactive card on the dashboard leading to the All-Services Hub.
/// Features category preview pills, micro-scale tap interaction, and
/// smooth light/dark adaptation.
class ServicesEntrySection extends StatefulWidget {
  const ServicesEntrySection({super.key});

  @override
  State<ServicesEntrySection> createState() => _ServicesEntrySectionState();
}

class _ServicesEntrySectionState extends State<ServicesEntrySection> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.brandViolet.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.brandViolet)
                      .withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.toNamed(BaseRoute.services);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Top Row: Icon, Title & View All Arrow
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7445FF),
                                  Color(0xFF5E2BFF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7445FF).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        l10nPick(
                                          context,
                                          en: 'All Services',
                                          fa: 'کل خدمات',
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
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        l10nPick(
                                          context,
                                          en: 'Super App',
                                          fa: 'سوپراپ',
                                          ar: 'سوبر آب',
                                          zh: '超级应用',
                                          ru: 'Супер-апп',
                                          tr: 'Süper Uygulama',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10nPick(
                                    context,
                                    en: 'Financial, travel & business tools',
                                    fa: 'ابزارهای مالی، سفر، گردشگری و کسب‌وکار',
                                    ar: 'أدوات مالية وسياحية وتجارية متكاملة',
                                    zh: '一站式集成金融、出行与商务工具',
                                    ru: 'Финансовые, туристические и бизнес-инструменты',
                                    tr: 'Finansal, seyahat ve işletme araçları',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : AppColors.brandViolet.withValues(alpha: 0.08),
                            ),
                            child: Icon(
                              isRtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              size: 22,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.brandViolet,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Bottom Row: Category Quick Pills Preview
                      Row(
                        children: [
                          _buildCategoryPill(
                            icon: Icons.payments_rounded,
                            label: l10nPick(context, en: 'Financial', fa: 'مالی', ar: 'مالية'),
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryPill(
                            icon: Icons.flight_rounded,
                            label: l10nPick(context, en: 'Travel', fa: 'سفر', ar: 'سفر'),
                            color: const Color(0xFF0284C7),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryPill(
                            icon: Icons.business_center_rounded,
                            label: l10nPick(context, en: 'Business', fa: 'کسب‌وکار', ar: 'أعمال'),
                            color: const Color(0xFF8B5CF6),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryPill(
                            icon: Icons.flash_on_rounded,
                            label: l10nPick(context, en: 'Instant', fa: 'آنی', ar: 'فوري'),
                            color: const Color(0xFFF59E0B),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
