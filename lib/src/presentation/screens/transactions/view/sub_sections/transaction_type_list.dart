import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/controller/transactions_controller.dart';

/// Modernized Horizontal Transaction Type Chips Bar.
class TransactionTypeList extends StatelessWidget {
  const TransactionTypeList({super.key});

  static String localizeType(BuildContext context, String type) {
    switch (type) {
      case 'All':
        return l10nPick(context, en: 'All', fa: 'همه', ar: 'الكل', tr: 'Tümü', ru: 'Все', zh: '全部');
      case 'Deposit':
        return l10nPick(context, en: 'Deposit', fa: 'واریز', ar: 'إيداع');
      case 'Manual Deposit':
        return l10nPick(context, en: 'Manual Deposit', fa: 'واریز دستی', ar: 'إيداع يدوي');
      case 'Withdraw':
        return l10nPick(context, en: 'Withdraw', fa: 'برداشت', ar: 'سحب');
      case 'Withdraw Auto':
        return l10nPick(context, en: 'Auto Withdraw', fa: 'برداشت خودکار', ar: 'سحب تلقائي');
      case 'Send Money':
        return l10nPick(context, en: 'Send Money', fa: 'ارسال پول', ar: 'إرسال أموال');
      case 'Receive Money':
        return l10nPick(context, en: 'Receive Money', fa: 'دریافت پول', ar: 'استلام أموال');
      case 'Cash Received':
        return l10nPick(context, en: 'Cash Received', fa: 'نقد دریافتی', ar: 'نقد مستلم');
      case 'Refund':
        return l10nPick(context, en: 'Refund', fa: 'بازگشت وجه', ar: 'استرداد');
      case 'Referral':
        return l10nPick(context, en: 'Referral', fa: 'دعوت دوستان', ar: 'إحالة');
      case 'Exchange':
        return l10nPick(context, en: 'Exchange', fa: 'تبدیل ارز', ar: 'تبادل');
      case 'Gift Redeemed':
        return l10nPick(context, en: 'Gift Redeemed', fa: 'کارت هدیه مصرفی', ar: 'استرداد هدية');
      case 'Signup Bonus':
        return l10nPick(context, en: 'Signup Bonus', fa: 'پاداش ثبت‌نام', ar: 'مكافأة التسجيل');
      case 'Cash In':
        return l10nPick(context, en: 'Cash In', fa: 'شارژ کیف پول', ar: 'إيداع نقدي');
      case 'Cash Out':
        return l10nPick(context, en: 'Cash Out', fa: 'نقد کردن', ar: 'سحب نقدي');
      case 'Credit':
        return l10nPick(context, en: 'Credit', fa: 'بستانکار (ورودی)', ar: 'دائن');
      case 'Debit':
        return l10nPick(context, en: 'Debit', fa: 'بدهکار (خروجی)', ar: 'مدين');
      case 'Request Money':
        return l10nPick(context, en: 'Request Money', fa: 'درخواست پول', ar: 'طلب أموال');
      case 'Invoice':
        return l10nPick(context, en: 'Invoice', fa: 'فاکتور', ar: 'فاتورة');
      case 'Pay Bill':
        return l10nPick(context, en: 'Pay Bill', fa: 'پرداخت قبض', ar: 'دفع فاتورة');
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TransactionsController controller = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemCount: controller.typesList.length,
      itemBuilder: (context, index) {
        final type = controller.typesList[index];

        return Obx(() {
          final isSelected = controller.selectedTypeIndex.value == index;
          final localizedLabel = localizeType(context, type);

          final bg = isSelected
              ? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.white);
          final fg = isSelected
              ? (isDark ? AppColors.deepBlack : AppColors.white)
              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
          final borderColor = isSelected
              ? Colors.transparent
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

          return Semantics(
            button: true,
            selected: isSelected,
            label: localizedLabel,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                onTap: () async {
                  HapticFeedback.selectionClick();
                  controller.selectedTypeIndex.value = index;
                  controller.clearOtherFiltersOnTypeChange();
                  if (index == 0) {
                    controller.selectedType.value = "";
                  } else {
                    controller.selectedType.value = type;
                  }
                  controller.isFilter.value = true;
                  await controller.fetchDynamicTransactions();
                },
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    color: bg,
                    border: Border.all(color: borderColor, width: 1.0),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark
                                      ? AppColors.mainSoftBlue
                                      : AppColors.deepBlack)
                                  .withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    localizedLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: fg,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
