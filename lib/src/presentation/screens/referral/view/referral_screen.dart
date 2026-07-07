import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/referral/controller/referral_controller.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 18),
            child: CommonAppBar(
              title: localization.referralScreenTitle,
              rightSideWidget: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: () {
                  _buildHistoryNavigation();
                },
                icon: Icon(Icons.more_vert),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return CommonLoading();
              }
              final referral = controller.referralModel.value.data;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${localization.referralScreenEarnAmount} ${referral?.amount ?? 0} ",
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 30,
                                  color: AppColors.lightPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                localization.referralScreenAfterInviting,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            localization.referralScreenOneMember,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(PngAssets.referralImage),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                width: 2,
                                color: AppColors.lightPrimary.withValues(
                                  alpha: 0.20,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(start: 16),
                                    child: Text(
                                      referral?.code ??
                                          localization.referralScreenNoCode,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: referral?.code ?? ""),
                                    );
                                    ToastHelper().showSuccessToast(
                                      localization.referralScreenCodeCopied,
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    margin:
                                        EdgeInsetsDirectional.only(end: 6),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightPrimary.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(
                                      PngAssets.commonGiftCopyIcon,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 6),
                            child: Text(
                              referral?.joinedText ?? "",
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 18,
                      ),
                      child: CommonButton(
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(text: referral?.code ?? ""),
                          );
                        },
                        width: double.infinity,

                        text: localization.referralScreenShareButton,
                      ),
                    ),
                    if (referral?.isShownReferralRules == true)
                      SizedBox(height: 30),
                    if (referral?.isShownReferralRules == true)
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
                        child: Column(
                          children: referral!.rules!.map((item) {
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      item.icon == "tick"
                                          ? PngAssets.commonReferralCheckIcon
                                          : PngAssets.commonReferralCloseIcon,
                                      fit: BoxFit.contain,
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        overflow: TextOverflow.visible,
                                        item.rule ?? "",
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          color: AppColors.lightTextTertiary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(height: 30),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _buildHistoryNavigation() {
    final localization = AppLocalizations.of(context)!;

    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        height: 160,
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  final items = [localization.referralScreenReferredFriends];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();

                        if (index == 0) {
                          Get.toNamed(BaseRoute.referredFriends);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Text(
                          items[index],
                          style: TextStyle(
                            letterSpacing: 0,
                            color: AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
