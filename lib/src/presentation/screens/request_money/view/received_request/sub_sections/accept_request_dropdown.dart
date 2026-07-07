import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/controller/received_request_controller.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/model/received_request_model.dart';

class AcceptRequestDropdown extends StatelessWidget {
  final Requests request;

  const AcceptRequestDropdown({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final ReceivedRequestController controller = Get.find();
    final SettingsService settingsService = Get.find();
    final localization = AppLocalizations.of(context)!;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: request.currency!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: request.isCrypto!,
    );

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
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
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Column(
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(PngAssets.acceptRequestCommonIcon, width: 70),
                    const SizedBox(height: 20),
                    Text(
                      localization.acceptRequestDropdownTitle,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.acceptRequestDropdownMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.white,
                            AppColors.lightTextPrimary.withValues(alpha: 0.1),
                            AppColors.white,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildDynamicContent(
                      context,
                      title: localization.acceptRequestDropdownPayableAmount,
                      content:
                          "${double.tryParse(request.finalAmount!)!.toStringAsFixed(calculateDecimals)} ${request.currency}",
                      contentColor: AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    _buildDynamicContent(
                      context,
                      title: localization.acceptRequestDropdownPayWallet,
                      content: request.requesterWalletCurrencyName!,
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.warning.withValues(alpha: 0.16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            localization.acceptRequestDropdownRequesterNote,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 15,
                              color: AppColors.lightTextPrimary.withValues(
                                alpha: 0.80,
                              ),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            request.note ??
                                localization.acceptRequestDropdownNoteNotFound,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 15,
                              color: AppColors.lightTextPrimary.withValues(
                                alpha: 0.80,
                              ),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    CommonButton(
                      width: 120,

                      text: localization.acceptRequestDropdownAcceptButton,
                      onPressed: () async {
                        Get.back();
                        controller.submitRequestAction(
                          requestId: request.id.toString(),
                          action: "accept",
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    CommonButton(
                      width: 120,

                      text: localization.acceptRequestDropdownCancelButton,
                      backgroundColor: AppColors.transparent,
                      textColor: AppColors.lightTextTertiary,
                      onPressed: () => Get.back(),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDynamicContent(
    BuildContext context, {
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: contentColor,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
