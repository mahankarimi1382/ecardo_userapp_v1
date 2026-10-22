import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referral_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referred_friends_controller.dart';

/// Multilingual string selector for referral terms not yet in AppLocalizations.
String _refL(
  BuildContext context, {
  required String en,
  required String fa,
  required String ar,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'fa':
      return fa;
    case 'ar':
      return ar;
    default:
      return en;
  }
}

Future<void> _copyReferralLink(BuildContext context) async {
  HapticFeedback.lightImpact();
  final msg = _refL(
    context,
    en: 'Referral link copied to clipboard!',
    fa: 'لینک دعوت در کلیپ‌بورد کپی شد!',
    ar: 'تم نسخ رابط الإحالة إلى الحافظة!',
  );
  String? code;
  if (Get.isRegistered<ReferralController>()) {
    code = Get.find<ReferralController>().referralModel.value.data?.code;
  }
  if ((code == null || code.isEmpty) && Get.isRegistered<HomeController>()) {
    code = Get.find<HomeController>().dashboardModel.value.data?.referral?.referralCode;
  }
  if (code == null || code.isEmpty) {
    try {
      final refController = Get.isRegistered<ReferralController>()
          ? Get.find<ReferralController>()
          : Get.put(ReferralController());
      if (refController.referralModel.value.data?.code == null) {
        await refController.fetchReferral();
      }
      code = refController.referralModel.value.data?.code;
    } catch (_) {}
  }
  final link = (code != null && code.isNotEmpty)
      ? 'https://ecardo.ir/register?ref=$code'
      : 'https://ecardo.ir/register';
  await Clipboard.setData(ClipboardData(text: link));
  ToastHelper().showSuccessToast(msg);
}

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
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkShadow
                : AppColors.brandViolet.withValues(alpha: 0.06),
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
              message: _refL(
                context,
                en: 'Unable to load referred friends. Please pull to refresh or try again.',
                fa: 'بارگذاری فهرست دوستان دعوت‌شده ممکن نشد. لطفاً صفحه را بکشید یا دوباره تلاش کنید.',
                ar: 'تعذر تحميل الأصدقاء المحالين. يرجى السحب للتحديث أو المحاولة مرة أخرى.',
              ),
              retryLabel: localization.noInternetConnectionRetryButton,
              onRetry: controller.fetchReferredFriends,
            ),
          );
        }

        // 3. Empty State with helpful illustration, localized microcopy, and copy-link CTA
        if (controller.referredFriendsList.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: EcardoEmptyState(
                iconData: Icons.group_add_rounded,
                iconColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                glowColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                title: _refL(
                  context,
                  en: 'No Friends Invited Yet',
                  fa: 'هنوز دوستی دعوت نشده است',
                  ar: 'لم تتم دعوة أي أصدقاء بعد',
                ),
                description: _refL(
                  context,
                  en: 'Share your referral link with friends and start earning bonuses on every transaction they complete.',
                  fa: 'لینک اختصاصی دعوت خود را با دوستان به اشتراک بگذارید و به ازای هر تراکنش آن‌ها پاداش دریافت کنید.',
                  ar: 'شارك رابط الإحالة الخاص بك مع الأصدقاء وابدأ في كسب مكافآت مقابل كل معاملة يجرونها.',
                ),
                primaryActionLabel: _refL(
                  context,
                  en: 'Copy Referral Link',
                  fa: 'کپی لینک دعوت',
                  ar: 'نسخ رابط الإحالة',
                ),
                onPrimaryAction: () => _copyReferralLink(context),
                secondaryActionLabel: localization.noInternetConnectionRetryButton,
                onSecondaryAction: controller.fetchReferredFriends,
              ),
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
                        : AppColors.brandVioletContainer,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
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
                  : AppColors.lightOutlineVariant,
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
