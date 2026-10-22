import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_buy_ad_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;

/// World-Class P2P Order Escrow Stepper & Bank Account Details
/// Features:
/// 1. 3-Step Escrow Timeline (Created -> Payment Sent -> Crypto Released)
/// 2. Order Financial Summary (Fiat Amount, Price, Crypto to receive)
/// 3. Prominent Bank Account Details Card with One-Tap Copy Buttons
/// 4. Safety Advisory Notice (no crypto keywords in transfer note)
/// 5. Full Dark Mode & RTL Support
class OrderDetailsTimelineSectionWidget extends StatelessWidget {
  final order_details.Data data;
  final P2pOrderDetailsController controller;

  const OrderDetailsTimelineSectionWidget({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Escrow Stepper (Created -> Payment Sent -> Crypto Released)
        _buildEscrowStepper(context, isDark),
        SizedBox(height: 16.h),

        // 2. Order Financial Details Card (Price, Quantity, Fiat)
        _buildOrderSummaryCard(context, isDark),
        SizedBox(height: 16.h),

        // 3. Prominent Bank Account Details Card to Pay To
        if (_shouldShowBankAccountDetails()) ...[
          _buildProminentBankDetailsCard(context, isDark),
          SizedBox(height: 16.h),
        ],
      ],
    );
  }

  /// 1. Escrow Stepper: Created -> Payment Sent -> Crypto Released
  Widget _buildEscrowStepper(BuildContext context, bool isDark) {
    final status = (data.status ?? '').toLowerCase();

    // Determine state for each step (0 = pending, 1 = active/current, 2 = completed, -1 = cancelled/failed)
    final isCancelled = status == 'cancelled' || status == 'expired';

    int step1State = 2; // Created is always completed once order exists
    int step2State; // Payment Sent
    int step3State; // Crypto Released

    if (isCancelled) {
      step2State = status == 'paid' ? 2 : -1;
      step3State = -1;
    } else if (status == 'pending_payment') {
      step2State = 1; // Active: buyer needs to pay
      step3State = 0; // Upcoming
    } else if (status == 'paid') {
      step2State = 2; // Payment is sent
      step3State = 1; // Active: awaiting seller release
    } else if (status == 'completed') {
      step2State = 2;
      step3State = 2; // All completed
    } else {
      step2State = 1;
      step3State = 0;
    }

    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final steps = [
      {
        'title': l10nPick(context, en: 'Created', fa: 'ثبت سفارش'),
        'subtitle': l10nPick(context, en: 'Order opened', fa: 'سفارش ایجاد شد'),
        'state': step1State,
      },
      {
        'title': l10nPick(context, en: 'Paid', fa: 'ارسال پرداخت'),
        'subtitle': controller.isBuy
            ? l10nPick(context, en: 'Pay seller', fa: 'واریز به فروشنده')
            : l10nPick(context, en: 'Buyer pays', fa: 'واریز توسط خریدار'),
        'state': step2State,
      },
      {
        'title': l10nPick(context, en: 'Released', fa: 'آزادسازی ارز'),
        'subtitle': l10nPick(
          context,
          en: 'Crypto in wallet',
          fa: 'دریافت رمزارز',
        ),
        'state': step3State,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 16.r,
                color: isDark ? AppColors.darkPrimary : AppColors.brandViolet,
              ),
              SizedBox(width: 6.w),
              Text(
                l10nPick(
                  context,
                  en: 'Escrow Stepper',
                  fa: 'مراحل تسویه امانی',
                ),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Horizontal 3-step nodes with progress lines
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: _buildStepNode(
                    index: i + 1,
                    title: steps[i]['title'] as String,
                    subtitle: steps[i]['subtitle'] as String,
                    state: steps[i]['state'] as int,
                    isDark: isDark,
                  ),
                ),
                if (i < steps.length - 1)
                  _buildStepConnector(
                    isCompleted: (steps[i]['state'] as int) == 2,
                    isDark: isDark,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int index,
    required String title,
    required String subtitle,
    required int
    state, // 2 = completed, 1 = active, 0 = pending, -1 = cancelled
    required bool isDark,
  }) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.brandViolet;

    Color nodeBg;
    Color nodeBorder;
    Widget nodeContent;

    if (state == 2) {
      // Completed
      nodeBg = AppColors.success;
      nodeBorder = AppColors.success;
      nodeContent = Icon(
        Icons.check_rounded,
        size: 14.r,
        color: AppColors.white,
      );
    } else if (state == 1) {
      // Active current step
      nodeBg = activeColor.withValues(alpha: isDark ? 0.25 : 0.15);
      nodeBorder = activeColor;
      nodeContent = Container(
        width: 8.r,
        height: 8.r,
        decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
      );
    } else if (state == -1) {
      // Cancelled
      nodeBg = AppColors.error.withValues(alpha: 0.15);
      nodeBorder = AppColors.error;
      nodeContent = Icon(
        Icons.close_rounded,
        size: 14.r,
        color: AppColors.error,
      );
    } else {
      // Pending
      nodeBg = isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant;
      nodeBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
      nodeContent = Text(
        '$index',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: nodeBg,
            shape: BoxShape.circle,
            border: Border.all(color: nodeBorder, width: 2),
            boxShadow: state == 1
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Center(child: nodeContent),
        ),
        SizedBox(height: 6.h),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            letterSpacing: 0,
            fontSize: 11.5.sp,
            fontWeight: state == 1 ? FontWeight.w800 : FontWeight.w700,
            color: state == 1
                ? (isDark ? AppColors.darkPrimary : AppColors.brandViolet)
                : state == 2
                ? AppColors.success
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            letterSpacing: 0,
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({
    required bool isCompleted,
    required bool isDark,
  }) {
    return Container(
      width: 24.w,
      height: 2.h,
      margin: EdgeInsets.only(top: 13.h),
      color: isCompleted
          ? AppColors.success
          : (isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant),
    );
  }

  /// 2. Order Financial Summary Card (Price, Quantity, Fiat)
  Widget _buildOrderSummaryCard(BuildContext context, bool isDark) {
    final localization = AppLocalizations.of(context)!;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(context, en: 'Order Summary', fa: 'خلاصه سفارش'),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5.sp,
                  color: textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                  ),
                  child: Text(
                    data.paymentMethod?.name ?? '--',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.brandViolet,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow(
            label: localization.p2pFiatAmount,
            value: data.fiatAmount ?? '--',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isHighlight: true,
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            label: localization.p2pPrice,
            value: data.price ?? '--',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            label: localization.p2pReceiveQuantity,
            value: data.assetAmount ?? '--',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: isHighlight ? 14.5.sp : 13.sp,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
              color: isHighlight ? AppColors.success : textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  bool _shouldShowBankAccountDetails() {
    final status = (data.status ?? '').toLowerCase();
    // Buyer needs to pay in pending_payment
    if (controller.isBuy && status == 'pending_payment') return true;
    // Both buyer and seller can review bank details in paid or completed
    if (status == 'paid' || status == 'completed') return true;
    return false;
  }

  /// 3. Prominent Bank Account Details Card to Pay To
  Widget _buildProminentBankDetailsCard(BuildContext context, bool isDark) {
    final localization = AppLocalizations.of(context)!;
    final cardBg = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurfaceVariant;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final methodName =
        data.recipientPaymentMethod?.name ??
        data.paymentMethod?.name ??
        localization.p2pPaymentMethod;

    final fields =
        data.recipientPaymentMethod?.fields ?? <order_details.Field>[];
    final totalPayAmount = data.totalFiatAmount ?? data.fiatAmount ?? '--';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandViolet.withValues(
              alpha: isDark ? 0.12 : 0.07,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Payment Method & Change Action
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimaryContainer
                  : AppColors.brandVioletContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusXl.r),
                topRight: Radius.circular(AppSpacing.radiusXl.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  size: 18.r,
                  color: AppColors.brandViolet,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    methodName,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5.sp,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.brandViolet,
                    ),
                  ),
                ),
                if (_canChangePaymentMethod(data, controller)) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        _openPaymentMethodChangeSheet(controller, data),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandViolet.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm.r,
                        ),
                      ),
                      child: Text(
                        localization.p2pChange,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          color: AppColors.brandViolet,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prominent Amount To Pay
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(
                                context,
                                en: 'Total Amount to Pay',
                                fa: 'مبلغ قابل پرداخت',
                              ),
                              style: TextStyle(
                                letterSpacing: 0,
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              totalPayAmount,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontSize: 16.5.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildCopyIcon(totalPayAmount, context),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Bank Account Recipient Fields
                if (fields.isEmpty) ...[
                  Text(
                    l10nPick(
                      context,
                      en: 'No bank account details specified.',
                      fa: 'اطلاعات حساب بانکی ثبت نشده است.',
                    ),
                    style: TextStyle(fontSize: 12.sp, color: textSecondary),
                  ),
                ] else ...[
                  for (final field in fields) ...[
                    if (_isImageField(field))
                      _buildImagePreviewRow(
                        field.name ?? '--',
                        field.value ?? '',
                        isDark,
                        context,
                      )
                    else
                      _buildBankFieldTile(
                        title: field.name ?? '--',
                        value: field.value ?? '--',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isDark: isDark,
                        context: context,
                      ),
                    SizedBox(height: 8.h),
                  ],
                ],

                SizedBox(height: 6.h),

                // Safety Advisory Notice Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(
                      alpha: isDark ? 0.15 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(
                      color: AppColors.warning.withValues(
                        alpha: isDark ? 0.4 : 0.25,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16.r,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Security Notice: Do NOT include crypto terms (Bitcoin, Tether, USDT, eCardo) in bank transfer description.',
                            fa: 'نکته امنیتی: از نوشتن کلمات رمزارز، تتر، بیت‌کوین و نام صرافی در شرح واریز بانکی اکیداً خودداری نمایید.',
                          ),
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.warningContainer
                                : AppColors.warmBrown,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankFieldTile({
    required String title,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required BuildContext context,
  }) {
    final isFormattedCard =
        title.toLowerCase().contains('card') ||
        title.toLowerCase().contains('کارت') ||
        title.toLowerCase().contains('شماره کارت');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    letterSpacing: isFormattedCard ? 1.0 : 0.2,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildCopyIcon(value, context),
        ],
      ),
    );
  }

  Widget _buildCopyIcon(String value, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _copyFieldValue(value, context),
      child: Container(
        padding: EdgeInsets.all(7.r),
        decoration: BoxDecoration(
          color: AppColors.brandViolet.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        ),
        child: Icon(
          Icons.copy_rounded,
          size: 15.r,
          color: AppColors.brandViolet,
        ),
      ),
    );
  }

  Future<void> _copyFieldValue(String value, BuildContext context) async {
    final safeValue = value.trim();
    if (safeValue.isEmpty || safeValue == '--') return;
    HapticFeedback.lightImpact();
    final message = AppLocalizations.of(context)?.p2pCopied ?? 'Copied';
    await Clipboard.setData(ClipboardData(text: safeValue));
    ToastHelper().showSuccessToast(message);
  }

  Widget _buildImagePreviewRow(
    String title,
    String imageUrl,
    bool isDark,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            letterSpacing: 0,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => _showImagePreviewDialog(imageUrl),
          child: Text(
            l10nPick(context, en: 'View Image', fa: 'مشاهده تصویر'),
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.brandViolet,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  bool _isImageField(order_details.Field field) {
    final type = (field.type ?? '').toLowerCase();
    final value = (field.value ?? '').trim().toLowerCase();

    if (value.isEmpty) return false;
    if (type.contains('image') || type.contains('file')) return true;
    return value.endsWith('.png') ||
        value.endsWith('.jpg') ||
        value.endsWith('.jpeg') ||
        value.endsWith('.webp') ||
        value.endsWith('.gif');
  }

  void _showImagePreviewDialog(String imageUrl) {
    if (imageUrl.trim().isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.transparent,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GestureDetector(
                  onTap: Get.back,
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.r,
                    color: AppColors.deepBlack,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120.h,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(
                              Get.context!,
                            )?.p2pUnableToLoadImage ??
                            'Unable to load image',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softGray,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canChangePaymentMethod(
    order_details.Data data,
    P2pOrderDetailsController controller,
  ) {
    return controller.isBuy &&
        (data.status ?? '').toLowerCase() == 'pending_payment';
  }

  void _openPaymentMethodChangeSheet(
    P2pOrderDetailsController controller,
    order_details.Data data,
  ) {
    if (!_canChangePaymentMethod(data, controller)) return;
    final methods = controller.paymentMethods;
    if (methods.isEmpty) return;

    final labels = methods.map((item) => item.label).toList();
    final selected = controller.selectedPaymentMethod?.label ?? '';
    final textController = TextEditingController(text: selected);

    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: AppLocalizations.of(Get.context!)!.p2pSelectPaymentMethod,
        isShowTitle: true,
        dropdownItems: labels,
        selectedValue: labels,
        selectedItem: selected,
        currentlySelectedValue: selected,
        textController: textController,
        bottomSheetHeight: 420.h,
        notFoundText:
            AppLocalizations.of(Get.context!)?.p2pNoPaymentMethodFound ??
            'No payment method found',
        onValueSelected: (value) async {
          final selectedValue = value.toString();
          AdPaymentOption? selectedOption;
          for (final item in methods) {
            if (item.label == selectedValue) {
              selectedOption = item;
              break;
            }
          }
          if (selectedOption == null) return;
          if (controller.selectedPaymentMethodId.value == selectedOption.id) {
            return;
          }
          Get.back();
          await controller.updateOrderPaymentMethod(selectedOption.id);
        },
      ),
    );
  }
}
