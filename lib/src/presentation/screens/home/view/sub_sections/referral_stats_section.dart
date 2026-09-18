import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

/// v1.0.38 (DASHBOARD): the dashboard API returns the user's referral
/// stats (invited count + accumulated bonus) but the home screen never
/// rendered them. This slim strip surfaces both stats following the
/// existing white-card design language and deep-links to the referral
/// screen. Hidden entirely when the server sent no referral data.
class ReferralStatsSection extends StatelessWidget {
  const ReferralStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final HomeController homeController = Get.find<HomeController>();
    final referral = homeController.dashboardModel.value.data?.referral;
    if (referral == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed(BaseRoute.referral),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.lightPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            _Stat(
              label: localization.dashboardReferralInvited,
              value: '${referral.count ?? 0}',
            ),
            Container(
              width: 1,
              height: 30,
              color: AppColors.black.withValues(alpha: 0.08),
              margin: const EdgeInsets.symmetric(horizontal: 14),
            ),
            _Stat(
              label: localization.dashboardReferralBonus,
              value: referral.bonus ?? '0',
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.lightTextTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            letterSpacing: 0,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            letterSpacing: 0,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}
