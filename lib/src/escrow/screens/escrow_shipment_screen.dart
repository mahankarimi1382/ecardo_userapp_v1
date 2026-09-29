import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';

class EscrowShipmentScreen extends StatefulWidget {
  final int orderId;

  const EscrowShipmentScreen({super.key, required this.orderId});

  @override
  State<EscrowShipmentScreen> createState() => _EscrowShipmentScreenState();
}

class _EscrowShipmentScreenState extends State<EscrowShipmentScreen> {
  final EscrowController controller = Get.find<EscrowController>();

  final TextEditingController _carrierController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _suggestedCarriers = ['تیپاکس (Tipax)', 'پست پیشتاز', 'چاپار (Chapar)', 'باربری اختصاصی'];

  @override
  void dispose() {
    _carrierController.dispose();
    _trackingController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final carrier = _carrierController.text.trim();
    final tracking = _trackingController.text.trim();

    if (carrier.isEmpty || tracking.isEmpty) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'نام شرکت حمل‌ونقل و شماره بارنامه الزامی است.', en: 'Carrier and tracking number are required.'),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await controller.submitShipment(
      widget.orderId,
      carrier: carrier,
      trackingNumber: tracking,
      trackingUrl: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
      shippingNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (ok) {
      Get.back();
      Get.snackbar(
        l10nPick(context, fa: 'ثبت شد', en: 'Submitted'),
        l10nPick(context, fa: 'اطلاعات ارسال کالا با موفقیت ثبت شد.', en: 'Shipment details submitted successfully.'),
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
          l10nPick(context, fa: 'ثبت اطلاعات ارسال (Step 4)', en: 'Submit Shipment'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightTextPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(16.r)),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: Colors.amber.shade800, size: 24.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'فروشنده گرامی، لطفاً اطلاعات دقیق بارنامه را ثبت نمایید تا وضعیت معامله به «در حال ارسال» تغییر کند.',
                        en: 'Please provide shipping carrier and tracking number to update deal status to In Delivery.',
                      ),
                      style: TextStyle(fontSize: 11.sp, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Carrier input & chips
            Text(l10nPick(context, fa: 'شرکت حمل‌ونقل یا شرکت باربری *', en: 'Shipping Carrier *'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 8.w,
              children: _suggestedCarriers.map((c) {
                return ActionChip(
                  label: Text(c, style: TextStyle(fontSize: 11.sp)),
                  onPressed: () => setState(() => _carrierController.text = c),
                );
              }).toList(),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _carrierController,
              decoration: InputDecoration(
                hintText: l10nPick(context, fa: 'نام شرکت حمل (مثلا تیپاکس)', en: 'e.g. Tipax, Iran Post'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            SizedBox(height: 16.h),

            // Tracking number
            Text(l10nPick(context, fa: 'شماره پیگیری / شماره بارنامه *', en: 'Tracking / Consignment Number *'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            TextField(
              controller: _trackingController,
              decoration: InputDecoration(
                hintText: 'مثلا: 9812400015',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            SizedBox(height: 16.h),

            // Tracking URL
            Text(l10nPick(context, fa: 'لینک پیگیری آنلاین (اختیاری)', en: 'Tracking URL (Optional)'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://tipaxco.com/tracking/...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            SizedBox(height: 16.h),

            // Notes
            Text(l10nPick(context, fa: 'توضیحات و نکات تحویل', en: 'Shipping Notes'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10nPick(context, fa: 'نکاتی مانند لزوم تحویل با ارائه کارت ملی...', en: 'Special delivery instructions...'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            SizedBox(height: 32.h),

            // Submit
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
                            l10nPick(context, fa: 'ثبت اطلاعات ارسال (Submit Shipment)', en: 'Submit Shipment Details'),
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