import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referred_friends_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/view/referred_friends/sub_sections/referred_friend_list.dart';

class ReferredFriends extends StatefulWidget {
  const ReferredFriends({super.key});

  @override
  State<ReferredFriends> createState() => _ReferredFriendsState();
}

class _ReferredFriendsState extends State<ReferredFriends> {
  final ReferredFriendsController controller = Get.find<ReferredFriendsController>();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          CommonAppBar(title: localization.referredFriendsScreenTitle),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
              onRefresh: () => controller.fetchReferredFriends(),
              child: const ReferredFriendList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xxl),
        child: SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
            heroTag: null,
            elevation: 2,
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.toNamed(BaseRoute.referralTree);
            },
            backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
            foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            icon: const Icon(Icons.account_tree_outlined, size: 20),
            label: Text(
              localization.referredFriendsScreenReferralTreeButton,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.deepBlack : AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
