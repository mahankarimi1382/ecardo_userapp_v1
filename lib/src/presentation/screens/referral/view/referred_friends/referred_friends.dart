import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referral_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referred_friends_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/view/referred_friends/sub_sections/referred_friend_list.dart';

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
          CommonAppBar(
            title: localization.referredFriendsScreenTitle,
            rightSideWidget: Semantics(
              button: true,
              label: _refL(
                context,
                en: 'Copy referral link',
                fa: 'کپی لینک دعوت',
                ar: 'نسخ رابط الإحالة',
              ),
              child: IconButton(
                icon: Icon(
                  Icons.link_rounded,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                ),
                tooltip: _refL(
                  context,
                  en: 'Copy Referral Link',
                  fa: 'کپی لینک دعوت',
                  ar: 'نسخ رابط الإحالة',
                ),
                onPressed: () => _copyReferralLink(context),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
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
          child: Semantics(
            button: true,
            label: localization.referredFriendsScreenReferralTreeButton,
            child: FloatingActionButton.extended(
              heroTag: null,
              elevation: 2,
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.toNamed(BaseRoute.referralTree);
              },
              backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
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
      ),
    );
  }
}
