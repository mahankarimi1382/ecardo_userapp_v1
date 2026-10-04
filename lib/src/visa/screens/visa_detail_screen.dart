import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_spacing.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Tracking', fa: 'رهگیری پرونده ویزا'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _controller.loadRequestDetail(widget.caseNo);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoadingDetail.value && _controller.currentRequest.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
            ),
          );
        }

        final req = _controller.currentRequest.value;
        if (req == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: AppSpacing.iconXl.r,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Text(
                    l10nPick(context, en: 'Visa request not found', fa: 'پرونده ویزا یافت نشد'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.lg.h,
          ),
          children: [
            // Case Tracking Header Card
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
                            l10nPick(context, en: 'Case Reference No.', fa: 'شماره پیگیری پرونده:'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
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
                                    color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs.w),
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
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
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.xs.r),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: AppSpacing.iconXs.r,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      VisaStatusBadge(status: req.status),
                    ],
                  ),
                  Divider(
                    height: AppSpacing.xxl,
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                  Row(
                    children: [
                      VisaCountryFlag(flagUrl: req.countryFlag, size: 36),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.countryName,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              req.visaTitle,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
            SizedBox(height: AppSpacing.lg.h),

            // Multi-Step Progress Tracker Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10nPick(context, en: 'Application Progress', fa: 'وضعیت و مراحل پرونده'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  req.statusLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            VisaTimelineWidget(currentStatus: req.status),
            SizedBox(height: AppSpacing.lg.h),

            // Action Alert for Pending Actions
            if (req.isAwaitingPayment)
              _alertBanner(
                context,
                isDark: isDark,
                color: isDark ? AppColors.warning.withValues(alpha: 0.15) : AppColors.warningContainer,
                borderColor: AppColors.warning,
                icon: Icons.payment_rounded,
                iconColor: AppColors.warning,
                title: l10nPick(context, en: 'Payment Required', fa: 'در انتظار پرداخت هزینه'),
                desc: l10nPick(
                  context,
                  en: 'Please complete the payment so our consultants can begin reviewing your application.',
                  fa: 'جهت شروع بررسی اسناد توسط کارشناسان رسمی، لطفاً هزینه پرونده را پرداخت فرمایید.',
                ),
                buttonText: l10nPick(context, en: 'Pay Now', fa: 'پرداخت آنلاین'),
                onTap: () => Get.to(() => VisaPaymentScreen(request: req)),
              )
            else if (req.isApproved)
              _alertBanner(
                context,
                isDark: isDark,
                color: isDark ? AppColors.success.withValues(alpha: 0.15) : AppColors.successContainer,
                borderColor: AppColors.success,
                icon: Icons.verified_rounded,
                iconColor: AppColors.success,
                title: l10nPick(context, en: 'Visa Issued!', fa: 'ویزای الکترونیک صادر گردید!'),
                desc: l10nPick(
                  context,
                  en: 'Your official E-Visa has been issued by the authority. Tap to view and download.',
                  fa: 'ویزای الکترونیک شما با موفقیت صادر شد. برای مشاهده و دانلود واچر کلیک کنید.',
                ),
                buttonText: l10nPick(context, en: 'View E-Visa', fa: 'مشاهده و دانلود ویزا'),
                onTap: () => Get.to(() => VisaResultScreen(request: req)),
              )
            else if (req.isRejected)
              _alertBanner(
                context,
                isDark: isDark,
                color: isDark ? AppColors.error.withValues(alpha: 0.15) : AppColors.errorContainer,
                borderColor: AppColors.error,
                icon: Icons.cancel_outlined,
                iconColor: AppColors.error,
                title: l10nPick(context, en: 'Application Rejected', fa: 'درخواست رد شد'),
                desc: req.rejectionReason ??
                    l10nPick(
                      context,
                      en: 'Tap to see details and appeal instructions.',
                      fa: 'جهت مشاهده دلایل و شرایط ثبت اعتراض کلیک نمایید.',
                    ),
                buttonText: l10nPick(context, en: 'View Details', fa: 'مشاهده جزئیات رد'),
                onTap: () => Get.to(() => VisaResultScreen(request: req)),
              ),
            if (req.isAwaitingPayment || req.isApproved || req.isRejected)
              SizedBox(height: AppSpacing.lg.h),

            // Applicant Details Card
            VisaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Applicant Details', fa: 'مشخصات متقاضی و مسافر'),
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  _detailRow(context, l10nPick(context, en: 'Full Name:', fa: 'نام و نام خانوادگی:'), req.applicantName, isDark),
                  _detailRow(context, l10nPick(context, en: 'Passport Number:', fa: 'شماره گذرنامه:'), req.applicantPassport, isDark),
                  _detailRow(context, l10nPick(context, en: 'Nationality:', fa: 'ملیت:'), req.applicantNationality, isDark),
                  _detailRow(context, l10nPick(context, en: 'Phone:', fa: 'شماره تماس:'), req.applicantPhone, isDark),
                  if (req.applicantEmail.isNotEmpty)
                    _detailRow(context, l10nPick(context, en: 'Email:', fa: 'ایمیل:'), req.applicantEmail, isDark),
                  if (req.travelDate != null)
                    _detailRow(context, l10nPick(context, en: 'Travel Date:', fa: 'تاریخ تقریبی سفر:'), req.travelDate!, isDark),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Submitted Documents Status Checklist
            VisaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, en: 'Submitted Documents', fa: 'مدارک و ضمائم ارسالی'),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (req.isComplementRequired)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            l10nPick(context, en: 'Needs Revision', fa: 'نیاز به اصلاح مدارک'),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  if (req.documents.isEmpty)
                    Text(
                      l10nPick(context, en: 'No documents recorded.', fa: 'هنوز مدرکی برای این پرونده بارگذاری نشده است.'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    )
                  else
                    ...req.documents.map(
                      (d) => VisaDocUploadCard(
                        title: d.title.isNotEmpty ? d.title : d.docKey,
                        instructions: d.fileName,
                        isAccepted: d.isAccepted,
                        isRejected: d.isRejected,
                        rejectionNote: d.rejectionNote,
                        onPickFile: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
                          );
                          if (result != null && result.files.single.path != null) {
                            await _controller.uploadDocumentForCurrent(
                              d.docKey,
                              File(result.files.single.path!),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Timeline Events History Log
            if (req.events.isNotEmpty) ...[
              VisaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, en: 'Activity Log', fa: 'تاریخچه اقدامات پرونده'),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    ...req.events.map((evt) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 4.h),
                                width: 8.r,
                                height: 8.r,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evt.title,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    if (evt.note != null && evt.note!.isNotEmpty)
                                      Text(
                                        evt.note!,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    Text(
                                      evt.createdAt.split('T').first,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: isDark ? AppColors.darkTextTertiary : AppColors.softGray,
                                      ),
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
              SizedBox(height: AppSpacing.lg.h),
            ],

            // Cancel action if permitted
            if (req.canCancel)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
                child: OutlinedButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10nPick(ctx, en: 'Cancel Application', fa: 'لغو پرونده ویزا')),
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
                              style: const TextStyle(color: AppColors.error),
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
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                  ),
                  child: Text(
                    l10nPick(context, en: 'Cancel This Application', fa: 'انصراف و لغو این پرونده'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            SizedBox(height: AppSpacing.xxxl.h),
          ],
        );
      }),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertBanner(
    BuildContext context, {
    required bool isDark,
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
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20.r),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                title,
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: iconColor),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.35,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.sm.h),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
