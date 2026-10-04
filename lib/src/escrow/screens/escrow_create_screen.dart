import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';
import 'escrow_detail_screen.dart';

class EscrowCreateScreen extends StatefulWidget {
  const EscrowCreateScreen({super.key});

  @override
  State<EscrowCreateScreen> createState() => _EscrowCreateScreenState();
}

class _EscrowCreateScreenState extends State<EscrowCreateScreen> {
  final EscrowController controller = Get.find<EscrowController>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _counterpartyController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _shippingCostController = TextEditingController(text: '0');

  String _creatorRole = 'SELLER'; // SELLER or BUYER
  String _currency = 'IRR';
  String _feePayer = 'BUYER'; // BUYER, SELLER, 50_50
  final String _shippingPayer = 'BUYER';
  int _inspectionHours = 72;
  final DateTime _shipDeadline = DateTime.now().add(const Duration(days: 5));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    _counterpartyController.dispose();
    _quantityController.dispose();
    _shippingCostController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final counterparty = _counterpartyController.text.trim();

    if (title.isEmpty || amount <= 0 || counterparty.isEmpty) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'لطفاً تمامی فیلدهای الزامی را پر نمایید.', en: 'Please fill all required fields.'),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    final payload = {
      'creator_role': _creatorRole,
      'counterparty_identifier': counterparty,
      'title': title,
      'description': _descController.text.trim(),
      'quantity': double.tryParse(_quantityController.text.trim()) ?? 1.0,
      'unit': 'عدد',
      'amount': amount,
      'currency': _currency,
      'fee_payer': _feePayer,
      'shipping_cost': double.tryParse(_shippingCostController.text.trim()) ?? 0.0,
      'shipping_payer': _shippingPayer,
      'ship_deadline': _shipDeadline.toIso8601String().split('T')[0],
      'inspection_hours': _inspectionHours,
    };

    HapticFeedback.lightImpact();
    final order = await controller.createDeal(payload);
    if (!mounted) return;
    if (order != null) {
      Get.back(); // close form
      Get.to(() => EscrowDetailScreen(orderId: order.id));
      Get.snackbar(
        l10nPick(context, fa: 'ثبت شد', en: 'Created'),
        l10nPick(context, fa: 'پیش‌نویس معامله با موفقیت ذخیره شد.', en: 'Draft deal created successfully.'),
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          l10nPick(context, fa: 'ایجاد معامله امانی جدید (New Escrow Deal)', en: 'New Escrow Deal'),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role selector
            Text(
              l10nPick(context, fa: 'شما در این معامله چه نقشی دارید؟', en: 'Your Role in this Deal:'),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(l10nPick(context, fa: 'فروشنده / بازرگان (Seller)', en: 'Seller')),
                    selected: _creatorRole == 'SELLER',
                    selectedColor: primaryAccent.withValues(alpha: 0.2),
                    onSelected: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _creatorRole = 'SELLER');
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: ChoiceChip(
                    label: Text(l10nPick(context, fa: 'خریدار / تاجر (Buyer)', en: 'Buyer')),
                    selected: _creatorRole == 'BUYER',
                    selectedColor: primaryAccent.withValues(alpha: 0.2),
                    onSelected: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _creatorRole = 'BUYER');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Counterparty
            _buildTextField(
              isDark: isDark,
              controller: _counterpartyController,
              label: l10nPick(context, fa: 'ایمیل یا شماره حساب طرف مقابل *', en: 'Counterparty Account/Email *'),
              hint: 'مثلا: 1000000001 یا user@example.com',
            ),
            SizedBox(height: AppSpacing.md.h),

            // Title
            _buildTextField(
              isDark: isDark,
              controller: _titleController,
              label: l10nPick(context, fa: 'عنوان کالا یا خدمت *', en: 'Deal Title / Goods *'),
              hint: 'مثلا: خرید ۵۰ تن برنج طارم محلی',
            ),
            SizedBox(height: AppSpacing.md.h),

            // Description
            _buildTextField(
              isDark: isDark,
              controller: _descController,
              label: l10nPick(context, fa: 'توضیحات و مشخصات کالا', en: 'Description & Specs'),
              hint: 'کیفیت، برند، بسته‌بندی و جزئیات توافق...',
              maxLines: 3,
            ),
            SizedBox(height: AppSpacing.md.h),

            // Amount & Currency
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    isDark: isDark,
                    controller: _amountController,
                    label: l10nPick(context, fa: 'مبلغ کل معامله *', en: 'Deal Amount *'),
                    hint: 'مثلا: 50000000',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, fa: 'واحد ارز', en: 'Currency'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'IRR', child: Text('ریال')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _currency = val ?? 'IRR');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),

            // Inspection period
            Text(
              l10nPick(context, fa: 'مدت دوره بازرسی خریدار (پس از تحویل)', en: 'Inspection Period (after delivery):'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Wrap(
              spacing: AppSpacing.sm.w,
              children: [24, 48, 72, 120, 168].map((hrs) {
                final isSel = _inspectionHours == hrs;
                return ChoiceChip(
                  label: Text('$hrs ساعت'),
                  selected: isSel,
                  selectedColor: primaryAccent.withValues(alpha: 0.2),
                  onSelected: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _inspectionHours = hrs);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.md.h),

            // Fee payer
            Text(
              l10nPick(context, fa: 'پرداخت‌کننده کارمزد پلتفرم امانی (۱٪)', en: 'Escrow Fee Payer (1%):'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            RadioGroup<String>(
              groupValue: _feePayer,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _feePayer = v ?? 'BUYER');
              },
              child: Row(
                children: [
                  _buildRadio('BUYER', l10nPick(context, fa: 'خریدار', en: 'Buyer'), primaryAccent),
                  _buildRadio('SELLER', l10nPick(context, fa: 'فروشنده', en: 'Seller'), primaryAccent),
                  _buildRadio('50_50', l10nPick(context, fa: 'نصف-نصف (50/50)', en: '50/50'), primaryAccent),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                    ),
                    onPressed: controller.isActionLoading.value ? null : _handleSubmit,
                    child: controller.isActionLoading.value
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : Text(
                            l10nPick(context, fa: 'ذخیره پیش‌نویس (Save Draft)', en: 'Save Draft'),
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

  Widget _buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildRadio(String value, String label, Color activeColor) {
    return Expanded(
      child: RadioListTile<String>(
        value: value,
        activeColor: activeColor,
        title: Text(
          label,
          style: AppTextStyles.labelSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}
