import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
  String _shippingPayer = 'BUYER';
  int _inspectionHours = 72;
  DateTime _shipDeadline = DateTime.now().add(const Duration(days: 5));

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
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
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

    final order = await controller.createDeal(payload);
    if (order != null) {
      Get.back(); // close form
      Get.to(() => EscrowDetailScreen(orderId: order.id));
      Get.snackbar(
        l10nPick(context, fa: 'ثبت شد', en: 'Created'),
        l10nPick(context, fa: 'پیش‌نویس معامله با موفقیت ذخیره شد.', en: 'Draft deal created successfully.'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10nPick(context, fa: 'ایجاد معامله امانی جدید (Step 1)', en: 'New Escrow Deal'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightTextPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role selector
            Text(
              l10nPick(context, fa: 'شما در این معامله چه نقشی دارید؟', en: 'Your Role in this Deal:'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(l10nPick(context, fa: 'فروشنده / بازرگان', en: 'Seller')),
                    selected: _creatorRole == 'SELLER',
                    selectedColor: AppColors.lightPrimary.withOpacity(0.2),
                    onSelected: (v) => setState(() => _creatorRole = 'SELLER'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ChoiceChip(
                    label: Text(l10nPick(context, fa: 'خریدار / تاجر', en: 'Buyer')),
                    selected: _creatorRole == 'BUYER',
                    selectedColor: AppColors.lightPrimary.withOpacity(0.2),
                    onSelected: (v) => setState(() => _creatorRole = 'BUYER'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Counterparty
            _buildTextField(
              controller: _counterpartyController,
              label: l10nPick(context, fa: 'ایمیل یا شماره حساب طرف مقابل *', en: 'Counterparty Account/Email *'),
              hint: 'مثلا: 1000000001 یا user@example.com',
            ),
            SizedBox(height: 14.h),

            // Title
            _buildTextField(
              controller: _titleController,
              label: l10nPick(context, fa: 'عنوان کالا یا خدمت *', en: 'Deal Title / Goods *'),
              hint: 'مثلا: خرید ۵۰ تن برنج طارم محلی',
            ),
            SizedBox(height: 14.h),

            // Description
            _buildTextField(
              controller: _descController,
              label: l10nPick(context, fa: 'توضیحات و مشخصات کالا', en: 'Description & Specs'),
              hint: 'کیفیت، برند، بسته‌بندی و جزئیات توافق...',
              maxLines: 3,
            ),
            SizedBox(height: 14.h),

            // Amount & Currency
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: _amountController,
                    label: l10nPick(context, fa: 'مبلغ کل معامله *', en: 'Deal Amount *'),
                    hint: 'مثلا: 50000000',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, fa: 'واحد ارز', en: 'Currency'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'IRR', child: Text('ریال')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                    onChanged: (val) => setState(() => _currency = val ?? 'IRR'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Inspection period
            Text(
              l10nPick(context, fa: 'مدت دوره بازرسی خریدار (پس از تحویل)', en: 'Inspection Period (after delivery):'),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 8.w,
              children: [24, 48, 72, 120, 168].map((hrs) {
                final isSel = _inspectionHours == hrs;
                return ChoiceChip(
                  label: Text('$hrs ساعت'),
                  selected: isSel,
                  onSelected: (v) => setState(() => _inspectionHours = hrs),
                );
              }).toList(),
            ),
            SizedBox(height: 14.h),

            // Fee payer
            Text(
              l10nPick(context, fa: 'پرداخت‌کننده کارمزد پلتفرم امانی (۱٪)', en: 'Escrow Fee Payer (1%):'),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                _buildRadio('BUYER', l10nPick(context, fa: 'خریدار', en: 'Buyer'), _feePayer, (v) => setState(() => _feePayer = v)),
                _buildRadio('SELLER', l10nPick(context, fa: 'فروشنده', en: 'Seller'), _feePayer, (v) => setState(() => _feePayer = v)),
                _buildRadio('50_50', l10nPick(context, fa: 'نصف-نصف', en: '50/50'), _feePayer, (v) => setState(() => _feePayer = v)),
              ],
            ),
            SizedBox(height: 24.h),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    onPressed: controller.isActionLoading.value ? null : _handleSubmit,
                    child: controller.isActionLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10nPick(context, fa: 'ذخیره پیش‌نویس (Save Draft)', en: 'Save Draft'),
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildRadio(String value, String label, String group, Function(String) onChanged) {
    return Expanded(
      child: RadioListTile<String>(
        value: value,
        groupValue: group,
        title: Text(label, style: TextStyle(fontSize: 11.sp)),
        contentPadding: EdgeInsets.zero,
        dense: true,
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}