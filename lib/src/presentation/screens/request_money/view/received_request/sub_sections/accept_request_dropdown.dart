import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/received_request_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/model/received_request_model.dart';

class AcceptRequestDropdown extends StatelessWidget {
  final Requests request;

  const AcceptRequestDropdown({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final ReceivedRequestController controller = Get.find();
    final SettingsService settingsService = Get.find();
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double finalAmountValue =
        double.tryParse(request.finalAmount ?? '') ?? 0.0;
    final currencyCode = request.currency ?? 'USD';

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currencyCode,
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: request.isCrypto ?? false,
    );

    return AnimatedContainer(
      width: double.infinity,
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow).withValues(
              alpha: isDark ? 0.4 : 0.08,
            ),
            blurRadius: 40,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.page,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    Image.asset(PngAssets.acceptRequestCommonIcon, width: 68),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      localization.acceptRequestDropdownTitle,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      localization.acceptRequestDropdownMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.25 : 0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDynamicContent(
                      context,
                      title: localization.acceptRequestDropdownPayableAmount,
                      content:
                          "${finalAmountValue.toStringAsFixed(calculateDecimals)} $currencyCode",
                      contentColor: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildDynamicContent(
                      context,
                      title: localization.acceptRequestDropdownPayWallet,
                      content: request.requesterWalletCurrencyName ?? currencyCode,
                      contentColor: colorScheme.onSurface,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        color: AppColors.warning.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            localization.acceptRequestDropdownRequesterNote,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              letterSpacing: 0,
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.85,
                              ),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            request.note ??
                                localization.acceptRequestDropdownNoteNotFound,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              letterSpacing: 0,
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    CommonButton(
                      width: 140,
                      height: 48,
                      borderRadius: AppSpacing.radiusLg,
                      text: localization.acceptRequestDropdownAcceptButton,
                      onPressed: () async {
                        final bool isPasscodeEnabled =
                            settingsService.getSetting(
                              "request_money_accept_passcode_status",
                            ) ==
                            "1";
                        Get.back();
                        if (isPasscodeEnabled) {
                          final dynamic verified =
                              await Get.bottomSheet<dynamic>(
                                const VerifyPasscodeBottomSheet(),
                              );
                          final isVerified =
                              verified != null &&
                              verified != false &&
                              (verified is! String || verified.isNotEmpty);
                          if (!isVerified) return;
                        }
                        controller.submitRequestAction(
                          requestId: request.id.toString(),
                          action: "accept",
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CommonButton(
                      width: 140,
                      height: 44,
                      borderRadius: AppSpacing.radiusLg,
                      text: localization.acceptRequestDropdownCancelButton,
                      backgroundColor: Colors.transparent,
                      textColor: colorScheme.onSurface.withValues(alpha: 0.7),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        Text(
          content,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            letterSpacing: 0,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: contentColor,
          ),
        ),
      ],
    );
  }
}
