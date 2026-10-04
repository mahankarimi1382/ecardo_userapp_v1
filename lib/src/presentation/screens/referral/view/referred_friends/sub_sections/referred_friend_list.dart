import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referred_friends_controller.dart';

class ReferredFriendList extends StatelessWidget {
  const ReferredFriendList({super.key});

  @override
  Widget build(BuildContext context) {
    final ReferredFriendsController controller = Get.find<ReferredFriendsController>();
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.mutedBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        // 1. Loading
        if (controller.isLoading.value) {
          return const Center(child: CommonLoading(isColorShow: false));
        }

        // 2. Error
        if (controller.isError.value) {
          return Center(
            child: EcardoErrorView(
              title: localization.allControllerLoadError,
              message: 'Unable to load referred friends. Please pull to refresh or try again.',
              retryLabel: localization.noInternetConnectionRetryButton,
              onRetry: controller.fetchReferredFriends,
            ),
          );
        }

        // 3. Empty
        if (controller.referredFriendsList.isEmpty) {
          return Center(
            child: EcardoEmptyState(
              iconData: Icons.group_off_rounded,
              title: localization.referredFriendsScreenTitle,
              description: 'You have not referred any friends yet. Share your code to start earning bonuses!',
              primaryActionLabel: localization.noInternetConnectionRetryButton,
              onPrimaryAction: controller.fetchReferredFriends,
            ),
          );
        }

        // 4. Content
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          itemBuilder: (context, index) {
            final referred = controller.referredFriendsList[index];
            final username = referred.username ?? '';
            final avatarUrl = referred.avatar ?? '';
            final parsedDate = DateTime.tryParse(referred.createdAt ?? '');
            final joinedDate = parsedDate != null
                ? DateFormat('dd MMM yyyy').format(parsedDate)
                : '';

            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.md,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSecondaryContainer,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (joinedDate.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            '${localization.referredFriendListJoinedOn} $joinedDate',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      color: (referred.status == true
                              ? AppColors.success
                              : AppColors.error)
                          .withValues(alpha: 0.12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: referred.status == true
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          referred.status == true
                              ? localization.referredFriendListActive
                              : localization.referredFriendListInactive,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: referred.status == true
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder.withValues(alpha: 0.5),
              height: AppSpacing.md,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
            );
          },
          itemCount: controller.referredFriendsList.length,
        );
      }),
    );
  }
}
