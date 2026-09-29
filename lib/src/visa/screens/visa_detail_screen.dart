import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../widgets/visa_widgets.dart';
import 'visa_payment_screen.dart';
import 'visa_result_screen.dart';

class VisaDetailScreen extends StatefulWidget {
  final String caseNo;

  const VisaDetailScreen({super.key, required this.caseNo});

  @override
  State<VisaDetailScreen> createState() => _VisaDetailScreenState();
}

class _VisaDetailScreenState extends State<VisaDetailScreen> {
  late final VisaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());
    _controller.loadRequestDetail(widget.caseNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Tracking', fa: 'پیگیری پرونده ویزا'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF7445FF)),
            onPressed: () => _controller.loadRequestDetail(widget.caseNo),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoadingDetail.value && _controller.currentRequest.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final req = _controller.currentRequest.value;
        if (req == null) {
          return Center(
            child: Text(
              l10nPick(context, en: 'Visa request not found', fa: 'پرونده ویزا یافت نشد'),
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            // Case Tracking Bar
            VisaCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, en: 'Case Reference No.', fa: 'شماره پرونده مرجع:'),
                            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  req.caseNo,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF7445FF),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: req.caseNo));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10nPick(context, en: 'Case number copied to clipboard', fa: 'شماره پرونده کپی شد'),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      VisaStatusBadge(status: req.status),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      VisaCountryFlag(flagUrl: req.countryFlag, size: 36),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.countryName,
                              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              req.visaTitle,
                              style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Timeline tracker
            Text(
              l10nPick(context, en: 'Application Progress', fa: 'وضعیت و مراحل پرونده'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            VisaTimelineWidget(currentStatus: req.status),
            SizedBox(height: 16.h),

            // Action Alert for Pending Actions
            if (req.isAwaitingPayment)
              _alertBanner(
                context,
                color: const Color(0xFFFDF4FF),
                borderColor: const Color(0xFFF0ABFC),
                icon: Icons.payment_rounded,
                iconColor: const Color(0xFFC026D3),
                title: l10nPick(context, en: 'Payment Required', fa: 'در انتظار پرداخت'),
                desc: l10nPick(
                  context,
                  en: 'Please complete the payment so our consultants can begin reviewing your application.',
                  fa: 'جهت شروع بررسی توسط کارشناسان، لطفاً هزینه پرونده را پرداخت فرمایید.',
                ),
                buttonText: l10nPick(context, en: 'Pay Now', fa: 'پرداخت آنلاین'),
                onTap: () => Get.to(() => VisaPaymentScreen(request: req)),
              )
            else if (req.isApproved)
              _alertBanner(
                context,
                color: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF059669),
                title: l10nPick(context, en: 'Visa Issued!', fa: 'ویزا صادر گردید!'),
                desc: l10nPick(
                  context,
                  en: 'Your official E-Visa has been issued by the authority. Tap to view and download.',
                  fa: 'ویزای الکترونیک شما با موفقیت صادر شد. جهت مشاهده و دانلود کلیک کنید.',
                ),
                buttonText: l10nPick(context, en: 'View E-Visa', fa: 'مشاهده و دانلود ویزا'),
                onTap: () => Get.to(() => VisaResultScreen(request: req)),
              )
            else if (req.isRejected)
              _alertBanner(
                context,
                color: const Color(0xFFFEF2F2),
                borderColor: const Color(0xFFFECACA),
                icon: Icons.cancel_outlined,
                iconColor: const Color(0xFFDC2626),
                title: l10nPick(context, en: 'Application Rejected', fa: 'درخواست رد شد'),
                desc: req.rejectionReason ??
                    l10nPick(
                      context,
                      en: 'Tap to see details and appeal instructions.',
                      fa: 'جهت مشاهده دلایل و شرایط ثبت اعتراض کلیک نمایید.',
                    ),
                buttonText: l10nPick(context, en: 'View Details', fa: 'مشاهده توضیحات'),
                onTap: () => Get.to(() => VisaResultScreen(request: req)),
              ),
            SizedBox(height: 16.h),

            // Applicant Details Card
            VisaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Applicant Details', fa: 'مشخصات ثبت‌شده متقاضی'),
                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 12.h),
                  _detailRow(l10nPick(context, en: 'Full Name:', fa: 'نام و نام خانوادگی:'), req.applicantName),
                  _detailRow(l10nPick(context, en: 'Passport Number:', fa: 'شماره گذرنامه:'), req.applicantPassport),
                  _detailRow(l10nPick(context, en: 'Nationality:', fa: 'ملیت:'), req.applicantNationality),
                  _detailRow(l10nPick(context, en: 'Phone:', fa: 'تلفن:'), req.applicantPhone),
                  if (req.applicantEmail.isNotEmpty)
                    _detailRow(l10nPick(context, en: 'Email:', fa: 'ایمیل:'), req.applicantEmail),
                  if (req.travelDate != null)
                    _detailRow(l10nPick(context, en: 'Travel Date:', fa: 'تاریخ سفر:'), req.travelDate!),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Uploaded Documents Status Checklist
            VisaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, en: 'Submitted Documents', fa: 'مدارک و ضمائم پرونده'),
                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                      ),
                      if (req.isComplementRequired)
                        Text(
                          l10nPick(context, en: 'Complement Needed', fa: 'نیاز به تکمیل'),
                          style: TextStyle(fontSize: 11.sp, color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (req.documents.isEmpty)
                    Text(
                      l10nPick(context, en: 'No documents recorded.', fa: 'هنوز مدرکی ثبت نشده است.'),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    )
                  else
                    ...req.documents.map((d) => _DocumentStatusRow(doc: d, caseNo: req.caseNo)),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Timeline Events History
            if (req.events.isNotEmpty) ...[
              VisaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, en: 'Activity Log', fa: 'تاریخچه رویدادهای پرونده'),
                      style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 10.h),
                    ...req.events.map((evt) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 4.h),
                                width: 8.r,
                                height: 8.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7445FF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evt.title,
                                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                                    ),
                                    if (evt.note != null && evt.note!.isNotEmpty)
                                      Text(
                                        evt.note!,
                                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                                      ),
                                    Text(
                                      evt.createdAt.split('T').first,
                                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Cancel action if allowed
            if (req.canCancel)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: OutlinedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10nPick(ctx, en: 'Cancel Application', fa: 'لغو درخواست ویزا')),
                        content: Text(
                          l10nPick(
                            ctx,
                            en: 'Are you sure you want to cancel this visa application?',
                            fa: 'آیا از لغو این پرونده ویزا اطمینان دارید؟',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10nPick(ctx, en: 'No', fa: 'خیر')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              l10nPick(ctx, en: 'Yes, Cancel', fa: 'بله، لغو شود'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _controller.cancelRequest(req.caseNo);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    l10nPick(context, en: 'Cancel This Application', fa: 'لغو این درخواست'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            SizedBox(height: 30.h),
          ],
        );
      }),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
          Text(value, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _alertBanner(
    BuildContext context, {
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: iconColor),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            desc,
            style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF334155), height: 1.3),
          ),
          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentStatusRow extends StatelessWidget {
  final VisaSubmittedDoc doc;
  final String caseNo;

  const _DocumentStatusRow({required this.doc, required this.caseNo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaController>();

    Color badgeBg;
    Color badgeFg;
    String badgeText;

    if (doc.isAccepted) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeFg = const Color(0xFF16A34A);
      badgeText = l10nPick(context, en: 'Approved', fa: 'تأیید شد');
    } else if (doc.isRejected) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeFg = const Color(0xFFDC2626);
      badgeText = l10nPick(context, en: 'Needs Revision', fa: 'نیاز به اصلاح');
    } else {
      badgeBg = const Color(0xFFFEF3C7);
      badgeFg = const Color(0xFFD97706);
      badgeText = l10nPick(context, en: 'Uploaded', fa: 'در حال بررسی');
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doc.title.isNotEmpty ? doc.title : doc.docKey,
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: badgeFg),
                ),
              ),
            ],
          ),
          if (doc.rejectionNote != null && doc.rejectionNote!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              '${l10nPick(context, en: 'Note', fa: 'توضیحات')}: ${doc.rejectionNote!}',
              style: TextStyle(fontSize: 11.sp, color: Colors.red[700]),
            ),
          ],
          if (doc.isRejected) ...[
            SizedBox(height: 6.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
                  );
                  if (result != null && result.files.single.path != null) {
                    await controller.uploadDocumentForCurrent(
                      doc.docKey,
                      File(result.files.single.path!),
                    );
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: Text(l10nPick(context, en: 'Re-upload', fa: 'بارگذاری مجدد')),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7445FF),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
