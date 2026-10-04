import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';

class CashOutWalletsSection extends StatelessWidget {
  const CashOutWalletsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final CashOutController controller = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final currentWallet = controller.wallet.value;
      if (currentWallet == null) return const SizedBox.shrink();

      return InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () {
          HapticFeedback.lightImpact();
          Get.bottomSheet(
            CommonDropdownWalletBottomSheet(
              notFoundText: localizations.cashOutWalletsNotFound,
              dropdownItems: controller.cashOutWalletsList,
              bottomSheetHeight: 450,
              currentlySelectedValue: currentWallet.name,
              onItemSelected: (value) async {
                final selectedWallet = controller.cashOutWalletsList.firstWhere(
                  (w) => w.name == value,
                );
                controller.wallet.value = selectedWallet;
              },
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E2836),
                      const Color(0xFF151C26),
                    ]
                  : [
                      AppColors.deepBlack,
                      const Color(0xFF2A2A28),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.mainSoftBlue.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                blurRadius: AppSpacing.md,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: AppSpacing.iconLg,
                    height: AppSpacing.iconLg,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: currentWallet.isDefault == true ||
                            currentWallet.icon == null ||
                            currentWallet.icon!.isEmpty
                        ? Text(
                            currentWallet.symbol ?? currentWallet.code ?? r'$',
                            style: const TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.white,
                            ),
                          )
                        : ClipOval(
                            child: Image.network(
                              currentWallet.icon!,
                              width: AppSpacing.iconLg,
                              height: AppSpacing.iconLg,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  currentWallet.symbol ?? r'$',
                                  style: const TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      currentWallet.name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentWallet.code ?? "",
                          style: const TextStyle(
                            color: AppColors.warmWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.warmWhite,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                localizations.cashOutWalletsBalance,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.warmWhite.withValues(alpha: 0.70),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "${currentWallet.formattedBalance} ${currentWallet.code}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
