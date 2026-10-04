import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';

class TransferWalletSection extends StatelessWidget {
  const TransferWalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TransferController controller = Get.find();
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final currentWallet = controller.wallet.value;
      if (currentWallet == null) {
        return const SizedBox.shrink();
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          onTap: () {
            HapticFeedback.selectionClick();
            Get.bottomSheet(
              CommonDropdownWalletBottomSheet(
                notFoundText: localization.transferWalletSectionWalletsNotFound,
                dropdownItems: controller.transferWalletsList,
                bottomSheetHeight: 450,
                currentlySelectedValue: currentWallet.name,
                onItemSelected: (value) async {
                  final selectedWallet = controller.transferWalletsList
                      .firstWhere((w) => w.name == value);
                  controller.wallet.value = selectedWallet;
                  controller.calculateLiveCharge();
                },
              ),
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage(PngAssets.addMoneyFrame),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: isDark
                  ? Border.all(
                      color: AppColors.mainSoftBlue.withValues(alpha: 0.35),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.lightShadow)
                      .withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    currentWallet.isDefault == true
                        ? Container(
                            alignment: Alignment.center,
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              currentWallet.symbol ?? '\$',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: 0,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.deepBlack,
                              ),
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              currentWallet.icon ?? '',
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  PngAssets.commonErrorIcon,
                                  color: AppColors.error.withValues(alpha: 0.7),
                                );
                              },
                            ),
                          ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        currentWallet.name ?? '',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          letterSpacing: 0,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  localization.transferWalletSectionBalance,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "${currentWallet.formattedBalance ?? '0.00'} ${currentWallet.code ?? ''}",
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
