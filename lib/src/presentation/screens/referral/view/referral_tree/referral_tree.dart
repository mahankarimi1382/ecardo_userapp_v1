import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referral_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referral_tree_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/view/referral_tree/sub_sections/referral_tree_widget.dart';

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
          CommonAppBar(
            title: localization.referralTreeScreenTitle,
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
                    message: _refL(
                      context,
                      en: 'Unable to load your network tree. Please check connection.',
                      fa: 'بارگذاری نمودار شبکه ممکن نشد. لطفاً اتصال اینترنت را بررسی کنید.',
                      ar: 'تعذر تحميل شجرة الشبكة. يرجى التحقق من الاتصال.',
                    ),
                    retryLabel: localization.noInternetConnectionRetryButton,
                    onRetry: controller.fetchReferralTree,
                  ),
                );
              }

              final rootData = controller.referralTreeModel.value.data;

              // 3. Empty State with helpful illustration, localized microcopy, and copy-link CTA
              if (rootData == null || rootData.children == null || rootData.children!.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: EcardoEmptyState(
                      iconData: Icons.account_tree_outlined,
                      iconColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                      glowColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                      title: _refL(
                        context,
                        en: 'Referral Tree Is Empty',
                        fa: 'نمودار شبکه معرف‌ها خالی است',
                        ar: 'شجرة الإحالة فارغة',
                      ),
                      description: _refL(
                        context,
                        en: 'You do not have any referred members yet. Share your referral link to build your multi-level network.',
                        fa: 'هنوز عضوی به عنوان زیرمجموعه شما ثبت نشده است. با اشتراک‌گذاری لینک دعوت، درخت شبکه خود را بسازید.',
                        ar: 'ليس لديك أعضاء مُحالون بعد. شارك رابط الإحالة لبناء شجرة أرباحك متعددة المستويات.',
                      ),
                      primaryActionLabel: _refL(
                        context,
                        en: 'Copy Referral Link',
                        fa: 'کپی لینک دعوت',
                        ar: 'نسخ رابط الإحالة',
                      ),
                      onPrimaryAction: () => _copyReferralLink(context),
                      secondaryActionLabel: localization.noInternetConnectionRetryButton,
                      onSecondaryAction: controller.fetchReferralTree,
                    ),
                  ),
                );
              }

              // 4. Content
              return RefreshIndicator(
                onRefresh: controller.fetchReferralTree,
                color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
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
