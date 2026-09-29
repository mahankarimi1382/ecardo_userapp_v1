import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';

class EscrowDisputeScreen extends StatefulWidget {
  final int orderId;

  const EscrowDisputeScreen({super.key, required this.orderId});

  @override
  State<EscrowDisputeScreen> createState() => _EscrowDisputeScreenState();
}

class _EscrowDisputeScreenState extends State<EscrowDisputeScreen> {
  final EscrowController controller = Get.find<EscrowController>();

  String _disputeType = 'QUALITY_ISSUE';
  final TextEditingController _descController = TextEditingController();

  final List<Map<String, String>> _types = [
    {'key': 'QUALITY_ISSUE', 'label': 'کیفیت نامطلوب / معیوب بودن کالا'},
    {'key': 'ITEM_NOT_AS_DESCRIBED', 'label': 'مغایرت کالا با توضیحات و قرارداد'},
    {'key': 'QUANTITY_SHORTAGE', 'label': 'کسری در تعداد یا مقدار ارسالی'},
    {'key': 'SHIPPING_DELAY', 'label': 'تأخیر غیرمجاز در ارسال کالا'},
    {'key': 'NON_DELIVERY', 'label': 'عدم تحویل کالا توسط فروشنده'},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final desc = _descController.text.trim();
    if (desc.length < 50) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'شرح اختلاف باید حداقل ۵۰ کاراکتر باشد.', en: 'Description must be at least 50 characters.'),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await controller.openDispute(
      widget.orderId,
      type: _disputeType,
      description: desc,
      evidenceFiles: ['evidence_sample_photo1.jpg', 'evidence_sample_photo2.jpg'],
    );

    if (ok) {
      Get.back();
      Get.snackbar(
        l10nPick(context, fa: 'پرونده ثبت شد', en: 'Dispute Opened'),
        l10nPick(context, fa: 'پرونده اختلاف با موفقیت ثبت شد و وجه معامله فریز گردید.', en: 'Dispute opened and funds frozen.'),
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
          l10nPick(context, fa: 'ثبت اختلاف و داوری (Open Dispute)', en: 'Open Dispute'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightTextPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Box
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16.r)),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'توجه: پس از ثبت اختلاف، وجه معامله فریز شده و فروشنده ۴۸ ساعت فرصت دارد پاسخ دهد. در صورت عدم توافق، داور رسمی پلتفرم رأی قطعی را صادر خواهد کرد.',
                        en: 'Notice: Funds will be frozen. Seller has 48h to respond before platform arbitration.',
                      ),
                      style: TextStyle(fontSize: 11.sp, color: Colors.red.shade900, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Dispute Type
            Text(l10nPick(context, fa: 'علت و نوع اختلاف *', en: 'Dispute Type *'), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            ..._types.map((t) => RadioListTile<String>(
                  value: t['key']!,
                  groupValue: _disputeType,
                  title: Text(t['label']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.redAccent,
                  dense: true,
                  onChanged: (val) {
                    if (val != null) setState(() => _disputeType = val);
                  },
                )),
            SizedBox(height: 16.h),

            // Description
            Text(l10nPick(context, fa: 'شرح کامل اختلاف (حداقل ۵۰ کاراکتر) *', en: 'Detailed Description (min 50 chars) *'), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10nPick(
                  context,
                  fa: 'لطفاً جزئیات دقیق مغایرت، تاریخ دریافت، نواقص مشاهده‌شده و توافقات انجام‌شده را بنویسید...',
                  en: 'Describe discrepancies, delivery date, observed defects...',
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            SizedBox(height: 16.h),

            // Evidence Upload Section
            Text(l10nPick(context, fa: 'بارگذاری مدارک و مستندات (عکس / ویدیو)', en: 'Upload Evidence Documents'), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_upload_outlined, color: AppColors.lightPrimary, size: 28.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10nPick(context, fa: 'افزودن تصویر بارنامه، کالا یا فیلم بسته‌بندی', en: 'Attach photo or video evidence'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        Text(l10nPick(context, fa: 'فرمت‌های مجاز: JPG, PNG, PDF (حداکثر ۲۰ مگابایت)', en: 'JPG, PNG, PDF (Max 20MB)'), style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Submit
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    onPressed: controller.isActionLoading.value ? null : _handleSubmit,
                    child: controller.isActionLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10nPick(context, fa: 'ثبت نهایی اختلاف (Open Dispute)', en: 'Confirm & Open Dispute'),
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}