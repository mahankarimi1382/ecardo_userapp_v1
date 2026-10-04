import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../model/license_models.dart';
import 'license_payment_screen.dart';

class LicenseDetailScreen extends StatefulWidget {
  final LicenseProductItem product;

  const LicenseDetailScreen({super.key, required this.product});

  @override
  State<LicenseDetailScreen> createState() => _LicenseDetailScreenState();
}

class _LicenseDetailScreenState extends State<LicenseDetailScreen> with SingleTickerProviderStateMixin {
  late String selectedEdition;
  late int selectedDuration;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    selectedEdition = widget.product.editions.isNotEmpty ? widget.product.editions.first : 'Standard';
    selectedDuration = widget.product.durationsMonths.isNotEmpty ? widget.product.durationsMonths.first : 12;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPrice = widget.product.calculatePrice(selectedEdition, selectedDuration);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              en: 'Product Details',
              fa: 'مشخصات لایسنس',
              ar: 'تفاصيل الترخيص',
              zh: '许可证详情',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header Card
            Container(
              padding: EdgeInsets.all(AppSpacing.xl.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            if (widget.product.vendor != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                widget.product.vendor!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.product.description != null) ...[
                    SizedBox(height: AppSpacing.lg.h),
                    Text(
                      widget.product.description!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Select Edition
            Text(
              l10nPick(context, en: 'Choose Edition', fa: 'انتخاب ویرایش', ar: 'اختر الإصدار', zh: '选择版本'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Wrap(
              spacing: AppSpacing.sm.w,
              children: widget.product.editions.map((ed) {
                final isSelected = selectedEdition == ed;
                return ChoiceChip(
                  label: Text(
                    ed,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? AppColors.deepBlack : AppColors.white)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      setState(() => selectedEdition = ed);
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Select Duration
            Text(
              l10nPick(context, en: 'Choose Duration', fa: 'مدت اعتبار', ar: 'اختر المدة', zh: '选择周期'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Wrap(
              spacing: AppSpacing.sm.w,
              children: widget.product.durationsMonths.map((m) {
                final isSelected = selectedDuration == m;
                final label = m >= 12
                    ? (m == 12 ? '1 Year' : '${m ~/ 12} Years')
                    : '$m Months';
                final labelFa = m >= 12
                    ? (m == 12 ? '۱ ساله' : '${m ~/ 12} ساله')
                    : '$m ماهه';
                return ChoiceChip(
                  label: Text(
                    l10nPick(context, en: label, fa: labelFa),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? AppColors.deepBlack : AppColors.white)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      setState(() => selectedDuration = m);
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.xxl.h),

            // Tabs for Activation & Refund Policy
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    indicatorColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    tabs: [
                      Tab(text: l10nPick(context, en: 'Activation Guide', fa: 'راهنمای فعال‌سازی', ar: 'دليل التفعيل', zh: '激活指南')),
                      Tab(text: l10nPick(context, en: 'Refund Policy', fa: 'شرایط استرداد', ar: 'سياسة الاسترداد', zh: '退款政策')),
                    ],
                  ),
                  SizedBox(
                    height: 130.h,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.lg.r),
                          child: SingleChildScrollView(
                            child: Text(
                              widget.product.activationGuide ??
                                  l10nPick(
                                    context,
                                    en: 'Activation instructions will be provided with your key.',
                                    fa: 'دستورالعمل کامل فعال‌سازی پس از خرید همراه با کلید تحویل خواهد شد.',
                                  ),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.lg.r),
                          child: SingleChildScrollView(
                            child: Text(
                              widget.product.refundPolicy ??
                                  l10nPick(
                                    context,
                                    en: 'In case of key issues, report within 7 days for a full replacement or refund.',
                                    fa: 'در صورت هرگونه نقص در کلید، ظرف ۷ روز با ثبت گزارش کلید جایگزین یا عودت وجه انجام می‌شود.',
                                  ),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w, vertical: AppSpacing.md.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Payable Amount', fa: 'مبلغ قابل پرداخت', ar: 'المبلغ المستحق', zh: '应付金额'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)} USD',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),
              CommonButton(
                width: 160,
                text: l10nPick(
                  context,
                  en: 'Buy License',
                  fa: 'خرید لایسنس',
                  ar: 'شراء الترخيص',
                  zh: '购买许可证',
                ),
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                textColor: isDark ? AppColors.deepBlack : AppColors.white,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => LicensePaymentScreen(
                        product: widget.product,
                        edition: selectedEdition,
                        durationMonths: selectedDuration,
                        priceUsd: currentPrice,
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
