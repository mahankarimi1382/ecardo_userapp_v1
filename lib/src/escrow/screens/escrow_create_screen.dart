import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/escrow_controller.dart';
import 'escrow_detail_screen.dart';

/// New Escrow Deal Screen — matches `new_escrow_deal.html`
/// Features:
/// 1. Role selector: [Seller / Buyer]
/// 2. Counterparty email or wallet ID
/// 3. Deal title / goods
/// 4. Deal amount in USD
/// 5. Real-time cost preview (Amount, Escrow fee 1%, Total funded, KYC limit note)
/// 6. Inspection window selector [24h, 48h, 72h, 120h, 168h]
/// 7. Fee payer selector [Buyer, Seller, 50 / 50]
/// 8. Attach invoice or specs
/// 9. Action buttons: "Send to counterparty" (primary) + "Save draft" (secondary)
class EscrowCreateScreen extends StatefulWidget {
  const EscrowCreateScreen({super.key});

  @override
  State<EscrowCreateScreen> createState() => _EscrowCreateScreenState();
}

class _EscrowCreateScreenState extends State<EscrowCreateScreen> {
  late final EscrowController controller;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _counterpartyController = TextEditingController();

  String _creatorRole = 'SELLER'; // SELLER or BUYER
  double _amount = 2400.0;
  int _inspectionHours = 72; // default from spec: 72h
  String _feePayer = 'BUYER'; // BUYER, SELLER, 50_50
  String? _attachedFileName;

  final List<int> _inspectionOptions = [24, 48, 72, 120, 168];
  final List<String> _feePayerOptions = ['Buyer', 'Seller', '50 / 50'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
    _amountController.text = '2400';
    _titleController.text = 'Industrial valve set — 40 units';
    _counterpartyController.text = 'delta@trading.co';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    _counterpartyController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '').trim());
    if (parsed != null && parsed >= 0) {
      setState(() => _amount = parsed);
    }
  }

  void _handleSubmit({bool isDraft = false}) async {
    final title = _titleController.text.trim();
    final counterparty = _counterpartyController.text.trim();

    if (title.isEmpty || _amount <= 0 || counterparty.isEmpty) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'لطفاً عنوان معامله، مبلغ و طرف مقابل را مشخص کنید.', en: 'Please fill all required fields.'),
        backgroundColor: ECardoTokens.dangerBg(context),
        colorText: ECardoTokens.danger(context),
      );
      return;
    }

    final fee = _amount * 0.01;
    final total = _amount + fee;

    final payload = {
      'creator_role': _creatorRole,
      'counterparty_identifier': counterparty,
      'title': title,
      'description': _descController.text.trim(),
      'amount': _amount,
      'currency': 'USD',
      'fee_amount': fee,
      'fee_payer': _feePayer,
      'total_escrow_amount': total,
      'inspection_hours': _inspectionHours,
      'status': isDraft ? 'DRAFT' : 'AWAITING_AGREEMENT',
    };

    HapticFeedback.lightImpact();
    final order = await controller.createDeal(payload);
    if (!mounted) return;
    if (order != null) {
      Get.back();
      Get.to(() => EscrowDetailScreen(orderId: order.id, initialOrder: order));
      Get.snackbar(
        l10nPick(context, fa: 'موفقیت', en: 'Success'),
        l10nPick(context, fa: 'معامله با موفقیت ثبت و برای طرف مقابل ارسال گردید.', en: 'Escrow deal sent to counterparty.'),
        backgroundColor: ECardoTokens.successBg(context),
        colorText: ECardoTokens.success(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = _amount * 0.01;
    final total = _amount + fee;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'معامله جدید امانی',
              en: 'New escrow deal',
              ar: 'معاملة ضمان جديدة',
              zh: '新建担保交易',
            ),
            isBackLogicApply: true,
            backLogicFunction: Get.back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ECardoTokens.space4.w,
          vertical: ECardoTokens.space3.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ Form Card ------------------
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Selector
                  Text(
                    l10nPick(context, fa: 'نقش شما در این معامله', en: 'Your role'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space2.h),

                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text(l10nPick(context, fa: 'فروشنده', en: 'Seller'))),
                          selected: _creatorRole == 'SELLER',
                          selectedColor: ECardoTokens.brand900(context),
                          backgroundColor: ECardoTokens.surfaceSunken(context),
                          labelStyle: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: _creatorRole == 'SELLER' ? Colors.white : ECardoTokens.ink(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                            side: BorderSide(
                              color: _creatorRole == 'SELLER' ? ECardoTokens.brand900(context) : ECardoTokens.border(context),
                            ),
                          ),
                          onSelected: (_) => setState(() => _creatorRole = 'SELLER'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ChoiceChip(
                          label: Center(child: Text(l10nPick(context, fa: 'خریدار', en: 'Buyer'))),
                          selected: _creatorRole == 'BUYER',
                          selectedColor: ECardoTokens.brand900(context),
                          backgroundColor: ECardoTokens.surfaceSunken(context),
                          labelStyle: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: _creatorRole == 'BUYER' ? Colors.white : ECardoTokens.ink(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                            side: BorderSide(
                              color: _creatorRole == 'BUYER' ? ECardoTokens.brand900(context) : ECardoTokens.border(context),
                            ),
                          ),
                          onSelected: (_) => setState(() => _creatorRole = 'BUYER'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ECardoTokens.space4.h),

                  // Counterparty field
                  Text(
                    l10nPick(context, fa: 'ایمیل یا شناسه ولت طرف مقابل', en: 'Counterparty email or wallet ID'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space1.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      border: Border.all(color: ECardoTokens.borderStrong(context)),
                    ),
                    child: TextField(
                      controller: _counterpartyController,
                      style: TextStyle(fontSize: 14.sp, color: ECardoTokens.ink(context)),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),

                  SizedBox(height: ECardoTokens.space4.h),

                  // Deal title
                  Text(
                    l10nPick(context, fa: 'عنوان معامله و شرح کالا / خدمات', en: 'Deal title / goods'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space1.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      border: Border.all(color: ECardoTokens.borderStrong(context)),
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: TextStyle(fontSize: 14.sp, color: ECardoTokens.ink(context)),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),

                  SizedBox(height: ECardoTokens.space4.h),

                  // Deal amount in USD
                  Text(
                    l10nPick(context, fa: 'مبلغ معامله', en: 'Deal amount'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space1.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      border: Border.all(color: ECardoTokens.borderStrong(context)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.ink(context),
                            ),
                            decoration: const InputDecoration(border: InputBorder.none),
                            onChanged: _onAmountChanged,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand100(context),
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                          ),
                          child: Text(
                            'USD',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.brand700(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Cost Preview Breakdown Card ------------------
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                children: [
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'مبلغ معامله', en: 'Deal amount'),
                    value: '${_amount.toStringAsFixed(2)} USD',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کارمزد ۱٪ اسکرو', en: 'Escrow fee 1% · paid by buyer'),
                    value: '${fee.toStringAsFixed(2)} USD',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کل واریز خریدار به حساب امانی', en: 'Buyer pays into escrow'),
                    value: '${total.toStringAsFixed(2)} USD',
                    isBold: true,
                    valueColor: ECardoTokens.brand900(context),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: ECardoTokens.brand100(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                    ),
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'سطح ۲ احراز هویت شما امکان معاملات تا سقف ۲۵,۰۰۰ دلار را فراهم می‌کند.',
                        en: 'Your KYC tier 2 allows deals up to 25,000 USD.',
                      ),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: ECardoTokens.brand700(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Inspection Window Chips ------------------
            Text(
              l10nPick(
                context,
                fa: 'مهلت بازرسی پس از تحویل کالا',
                en: 'Inspection window after delivery',
                ar: 'مهلة الفحص بعد الاستلام',
                zh: '交付后验收期限',
              ),
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Wrap(
              spacing: 8.w,
              children: _inspectionOptions.map((h) {
                final isSelected = _inspectionHours == h;
                return ChoiceChip(
                  label: Text('${h}h'),
                  selected: isSelected,
                  selectedColor: ECardoTokens.brand900(context),
                  backgroundColor: ECardoTokens.surfaceSunken(context),
                  labelStyle: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : ECardoTokens.ink(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                    side: BorderSide(
                      color: isSelected ? ECardoTokens.brand900(context) : ECardoTokens.border(context),
                    ),
                  ),
                  onSelected: (_) => setState(() => _inspectionHours = h),
                );
              }).toList(),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Fee Payer Chips ------------------
            Text(
              l10nPick(
                context,
                fa: 'پرداخت‌کننده کارمزد ۱٪',
                en: 'Who pays the 1% fee',
                ar: 'المتحمل لرسوم الضمان 1%',
                zh: '谁承担1%手续费',
              ),
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Wrap(
              spacing: 8.w,
              children: _feePayerOptions.map((payer) {
                final isSelected = _feePayer == payer.toUpperCase().replaceAll(' ', '').replaceAll('/', '_');
                return ChoiceChip(
                  label: Text(payer),
                  selected: isSelected,
                  selectedColor: ECardoTokens.brand900(context),
                  backgroundColor: ECardoTokens.surfaceSunken(context),
                  labelStyle: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : ECardoTokens.ink(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                    side: BorderSide(
                      color: isSelected ? ECardoTokens.brand900(context) : ECardoTokens.border(context),
                    ),
                  ),
                  onSelected: (_) => setState(() => _feePayer = payer.toUpperCase().replaceAll(' ', '').replaceAll('/', '_')),
                );
              }).toList(),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Attachment Button ------------------
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: ECardoTokens.ink(context),
                side: BorderSide(color: ECardoTokens.borderStrong(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _attachedFileName = 'Invoice-spec-2026.pdf');
              },
              icon: Icon(Icons.attach_file_rounded, size: 18.sp, color: ECardoTokens.brand500(context)),
              label: Text(
                _attachedFileName ?? l10nPick(context, fa: 'پیوست پیش‌فاکتور یا مشخصات فنی', en: 'Attach invoice or specs'),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: ECardoTokens.space8.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          border: Border(top: BorderSide(color: ECardoTokens.border(context))),
          boxShadow: ECardoTokens.shadowSheet(context),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ECardoTokens.brand900(context),
                    foregroundColor: ECardoTokens.inkOnBrand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                    ),
                  ),
                  onPressed: () => _handleSubmit(isDraft: false),
                  child: Text(
                    l10nPick(
                      context,
                      fa: 'ارسال برای طرف مقابل (Send to counterparty)',
                      en: 'Send to counterparty',
                      ar: 'إرسال إلى الطرف الآخر',
                      zh: '发送给交易对手',
                    ),
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              TextButton(
                onPressed: () => _handleSubmit(isDraft: true),
                child: Text(
                  l10nPick(context, fa: 'ذخیره به عنوان پیش‌نویس (Save draft)', en: 'Save draft'),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.inkMuted(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: isBold ? ECardoTokens.ink(context) : ECardoTokens.inkMuted(context),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15.sp : 13.5.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}
