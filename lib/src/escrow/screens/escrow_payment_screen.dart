import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';

class EscrowPaymentScreen extends StatefulWidget {
  final EscrowOrderModel order;

  const EscrowPaymentScreen({super.key, required this.order});

  @override
  State<EscrowPaymentScreen> createState() => _EscrowPaymentScreenState();
}

class _EscrowPaymentScreenState extends State<EscrowPaymentScreen> {
  late final EscrowController controller;
  String _selectedMethod = 'wallet';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
  }

  void _handlePay() async {
    HapticFeedback.lightImpact();
    final ok = await controller.payIntoEscrow(widget.order.id);
    if (!mounted) return;
    if (ok) {
      Get.back();
      Get.snackbar(
        l10nPick(context, fa: 'پرداخت موفق', en: 'Payment Success'),
        l10nPick(context, fa: 'وجه با موفقیت به حساب امانی واریز گردید.', en: 'Funds deposited into escrow successfully.'),
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.order;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(context, fa: 'پرداخت به حساب امانی', en: 'Pay into Escrow'),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.page.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.xxl.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.warning.withValues(alpha: 0.16)
                    : AppColors.warningContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: isDark ? 0.3 : 0.35),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${deal.totalEscrowAmount.toStringAsFixed(0)} ${deal.currency}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.warning : AppColors.warmBrown,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'مبلغ قابل پرداخت جهت قفل در حساب امانی',
                      en: 'Total Amount to Deposit in Escrow',
                    ),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.warning.withValues(alpha: 0.85)
                          : AppColors.warmBrown.withValues(alpha: 0.85),
                    ),
                  ),
                  Divider(
                    height: 28,
                    color: (isDark ? AppColors.warning : AppColors.warmBrown)
                        .withValues(alpha: 0.25),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l10nPick(context, fa: 'مبلغ کالا: ', en: 'Item: '),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            TextSpan(
                              text: '${deal.amount.toStringAsFixed(0)} ${deal.currency}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l10nPick(context, fa: 'کارمزد امانی: ', en: 'Fee: '),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            TextSpan(
                              text: '${deal.feeAmount.toStringAsFixed(0)} ${deal.currency}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),

            Text(
              l10nPick(context, fa: 'انتخاب منبع پرداخت:', en: 'Choose Payment Source:'),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),

            // Wallet / Gateway Radios
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: RadioGroup<String>(
                groupValue: _selectedMethod,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedMethod = v ?? 'wallet');
                },
                child: Column(
                  children: [
                    Semantics(
                      button: true,
                      selected: _selectedMethod == 'wallet',
                      inMutuallyExclusiveGroup: true,
                      label:
                          '${l10nPick(context, fa: 'کیف پول eCardo (کسر مستقیم)', en: 'eCardo Wallet (Instant)')}, ${l10nPick(context, fa: 'پرداخت امن و بدون کارمزد بانکی', en: 'No gateway fees')}',
                      hint: l10nPick(
                        context,
                        fa: 'برای انتخاب کیف پول دو بار ضربه بزنید',
                        en: 'Double tap to select wallet',
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 48.h,
                          minWidth: 48.w,
                        ),
                        child: RadioListTile<String>(
                          value: 'wallet',
                          activeColor: primaryAccent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.padded,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md.w,
                            vertical: AppSpacing.xs.h,
                          ),
                          title: Text(
                            l10nPick(
                              context,
                              fa: 'کیف پول eCardo (کسر مستقیم)',
                              en: 'eCardo Wallet (Instant)',
                            ),
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            l10nPick(
                              context,
                              fa: 'پرداخت امن و بدون کارمزد بانکی',
                              en: 'No gateway fees',
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    ),
                    Semantics(
                      button: true,
                      selected: _selectedMethod == 'gateway',
                      inMutuallyExclusiveGroup: true,
                      label:
                          '${l10nPick(context, fa: 'درگاه پرداخت اینترنتی بانکی', en: 'Online Bank Gateway')}, ${l10nPick(context, fa: 'پرداخت با کلیه کارت‌های عضو شتاب', en: 'All debit/credit cards')}',
                      hint: l10nPick(
                        context,
                        fa: 'برای انتخاب درگاه اینترنتی دو بار ضربه بزنید',
                        en: 'Double tap to select online gateway',
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 48.h,
                          minWidth: 48.w,
                        ),
                        child: RadioListTile<String>(
                          value: 'gateway',
                          activeColor: primaryAccent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.padded,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md.w,
                            vertical: AppSpacing.xs.h,
                          ),
                          title: Text(
                            l10nPick(
                              context,
                              fa: 'درگاه پرداخت اینترنتی بانکی',
                              en: 'Online Bank Gateway',
                            ),
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            l10nPick(
                              context,
                              fa: 'پرداخت با کلیه کارت‌های عضو شتاب',
                              en: 'All debit/credit cards',
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Guarantee Notice
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.info.withValues(alpha: 0.15)
                    : AppColors.infoContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: isDark ? 0.25 : 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.info,
                    size: AppSpacing.iconMd.sp,
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        fa:
                            'تضمین صد درصدی پلتفرم: وجه واریزی تا زمان تایید رضایت شما از کالا، هرگز به فروشنده تحویل داده نخواهد شد.',
                        en:
                            '100% Platform Guarantee: Funds will never be released until your full satisfaction.',
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.deepBlack,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                    ),
                    onPressed: controller.isActionLoading.value ? null : _handlePay,
                    child: controller.isActionLoading.value
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : Text(
                            l10nPick(context, fa: 'تایید و واریز به حساب امانی', en: 'Confirm & Deposit'),
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.deepBlack : AppColors.white,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
