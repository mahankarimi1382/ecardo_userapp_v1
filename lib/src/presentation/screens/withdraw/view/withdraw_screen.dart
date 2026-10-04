import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/create_withdraw_account/create_withdraw_account.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/edit_withdraw_account/edit_withdraw_account.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_account_section.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_header_section.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_money_section.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final WithdrawController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: controller.currentStep.value == 1
                  ? null
                  : controller.selectedScreen.value == 1
                  ? BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    )
                  : BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkSurfaceVariant, AppColors.darkBackground]
                            : [AppColors.white, AppColors.lightBackground],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.24, 0.27],
                      ),
                    ),
              child: Column(
                children: [
                  controller.currentStep.value == 1
                      ? Column(
                          children: [
                            const SizedBox(height: 60),
                            CommonAppBar(
                              title: localization.withdrawScreenTitle,
                            ),
                          ],
                        )
                      : controller.currentStep.value == 2
                      ? const SizedBox.shrink()
                      : const WithdrawHeaderSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  Expanded(
                    child: controller.selectedScreen.value == 0
                        ? const WithdrawMoneySection()
                        : controller.selectedScreen.value == 1
                        ? const WithdrawAccountSection()
                        : controller.selectedScreen.value == 2
                        ? const CreateWithdrawAccount()
                        : controller.selectedScreen.value == 3
                        ? EditWithdrawAccount(
                            account: controller.selectedAccount.value!,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: controller.isWithdrawLoading.value,
              child: const CommonLoading(),
            ),
          ],
        ),
        floatingActionButton: controller.selectedScreen.value == 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                child: SizedBox(
                  height: 48,
                  width: 160,
                  child: FloatingActionButton(
                    heroTag: null,
                    elevation: 3,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      controller.selectedScreen.value = 2;
                    },
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusLg,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          PngAssets.addCommonIcon,
                          width: 22,
                          color: isDark ? AppColors.deepBlack : AppColors.white,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          localization.withdrawScreenAddAccountButton,
                          style: TextStyle(
                            color: isDark ? AppColors.deepBlack : AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
