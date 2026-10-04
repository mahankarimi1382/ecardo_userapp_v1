import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referral_tree_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/view/referral_tree/sub_sections/referral_tree_widget.dart';

class NodeInfo {
  final GlobalKey key;
  final List<GlobalKey> childrenKeys;

  NodeInfo({required this.key, required this.childrenKeys});
}

class ReferralTree extends StatefulWidget {
  const ReferralTree({super.key});

  @override
  State<ReferralTree> createState() => _ReferralTreeState();
}

class _ReferralTreeState extends State<ReferralTree> {
  final ReferralTreeController controller = Get.find<ReferralTreeController>();

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
          CommonAppBar(title: localization.referralTreeScreenTitle),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Obx(() {
              // 1. Loading
              if (controller.isLoading.value) {
                return const CommonLoading();
              }

              // 2. Error
              if (controller.isError.value) {
                return Center(
                  child: EcardoErrorView(
                    title: localization.allControllerLoadError,
                    message: 'Unable to load your network tree. Please check connection.',
                    retryLabel: localization.noInternetConnectionRetryButton,
                    onRetry: controller.fetchReferralTree,
                  ),
                );
              }

              final rootData = controller.referralTreeModel.value.data;

              // 3. Empty
              if (rootData == null || rootData.children == null || rootData.children!.isEmpty) {
                return Center(
                  child: EcardoEmptyState(
                    iconData: Icons.account_tree_outlined,
                    title: localization.referredFriendsScreenReferralTreeButton,
                    description: 'No referred members in your tree yet. Invite friends to grow your network.',
                    primaryActionLabel: localization.noInternetConnectionRetryButton,
                    onPrimaryAction: controller.fetchReferralTree,
                  ),
                );
              }

              // 4. Content
              return RefreshIndicator(
                onRefresh: controller.fetchReferralTree,
                color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ReferralTreeWidget(root: rootData),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
