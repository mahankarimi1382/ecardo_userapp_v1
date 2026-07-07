import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/create_withdraw_account/create_withdraw_account.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/edit_withdraw_account/edit_withdraw_account.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_account_section.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_header_section.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_money_section.dart';

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

    return Obx(
      () => Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: controller.currentStep.value == 1
                  ? null
                  : controller.selectedScreen.value == 1
                  ? BoxDecoration(color: AppColors.white)
                  : BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.white, AppColors.lightBackground],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.24, 0.27],
                      ),
                    ),
              child: Column(
                children: [
                  controller.currentStep.value == 1
                      ? Column(
                          children: [
                            SizedBox(height: 60),
                            CommonAppBar(
                              title: localization.withdrawScreenTitle,
                            ),
                          ],
                        )
                      : controller.currentStep.value == 2
                      ? SizedBox.shrink()
                      : WithdrawHeaderSection(),
                  SizedBox(height: 30),
                  Expanded(
                    child: controller.selectedScreen.value == 0
                        ? WithdrawMoneySection()
                        : controller.selectedScreen.value == 1
                        ? WithdrawAccountSection()
                        : controller.selectedScreen.value == 2
                        ? CreateWithdrawAccount()
                        : controller.selectedScreen.value == 3
                        ? EditWithdrawAccount(
                            account: controller.selectedAccount.value!,
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: controller.isWithdrawLoading.value,
              child: CommonLoading(),
            ),
          ],
        ),
        floatingActionButton: controller.selectedScreen.value == 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  height: 48,
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: null,
                    elevation: 0,
                    onPressed: () {
                      controller.selectedScreen.value = 2;
                    },
                    backgroundColor: AppColors.lightPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(PngAssets.addCommonIcon, width: 22),
                        SizedBox(width: 5),
                        Text(
                          localization.withdrawScreenAddAccountButton,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
