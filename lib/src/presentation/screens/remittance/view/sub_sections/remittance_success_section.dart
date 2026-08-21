import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 5: Success + document upload.
class RemittanceSuccessSection extends StatelessWidget {
  const RemittanceSuccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RemittanceController>();
    final l = AppLocalizations.of(context)!;
    return Obx(() {
      final r = c.createdRemittance.value;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(children: [
            Container(width: 72.w, height: 72.w, decoration: BoxDecoration(color: AppColors.successContainer, shape: BoxShape.circle),
              child: Icon(Icons.check_circle, color: AppColors.success, size: 48.sp)),
            SizedBox(height: 12.h),
            Text(l.remittanceRequestSubmitted, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
            SizedBox(height: 4.h),
            Text(l.remittanceRequestCreated, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
          ]),
        )),
        SizedBox(height: 16.h),
        if (r != null) Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(color: AppColors.lightPrimaryContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Info('Tracking UUID', r.uuid),
            SizedBox(height: 8.h),
            _Info('Reference', r.trx),
            SizedBox(height: 8.h),
            _Info(l.remittanceDocumentType, c.localizedStatusLabel(r.status)),
            SizedBox(height: 8.h),
            _Info(l.remittanceSendAmount, r.sendAmount.toStringAsFixed(2)),
            SizedBox(height: 8.h),
            _Info(l.remittanceReceiveAmount, r.receiveAmount.toStringAsFixed(2)),
          ]),
        ),
        SizedBox(height: 24.h),
        Text(l.remittanceUploadDocuments, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
        SizedBox(height: 4.h),
        Text(l.remittanceUploadHint, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
        SizedBox(height: 16.h),
        Obx(() => c.pendingAttachments.isEmpty ? const SizedBox.shrink() : Column(children: c.pendingAttachments.asMap().entries.map((e) => _AttachmentItem(path: e.value['path'] ?? '', type: e.value['type'] ?? 'other', onRemove: () => c.removeAttachmentAt(e.key), l: l)).toList())),
        SizedBox(height: 12.h),
        _AddDocumentButton(controller: c, l: l),
      ]);
    });
  }
}

class _Info extends StatelessWidget {
  final String label, value;
  const _Info(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
        SizedBox(width: 12.w),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600))),
      ]);
}

class _AttachmentItem extends StatelessWidget {
  final String path, type;
  final VoidCallback onRemove;
  final AppLocalizations l;
  const _AttachmentItem({required this.path, required this.type, required this.onRemove, required this.l});

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: AppColors.lightSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.lightBorder)),
        child: Row(children: [
          Icon(_icon(type), color: AppColors.lightPrimary, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_label(type), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
            Text(path.split('/').last, style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          IconButton(icon: Icon(Icons.close, color: AppColors.error, size: 18.sp), onPressed: onRemove, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
      );

  String _label(String t) => switch (t) {
    'kyc'              => l.remittanceDocTypeKyc,
    'payment_receipt'  => l.remittanceDocTypePaymentReceipt,
    'payout_receipt'   => l.remittanceDocTypePayoutReceipt,
    _                  => l.remittanceDocTypeOther,
  };
  IconData _icon(String t) => switch (t) { 'kyc' => Icons.badge, 'payment_receipt' => Icons.receipt, 'payout_receipt' => Icons.payment, _ => Icons.insert_drive_file };
}

class _AddDocumentButton extends StatelessWidget {
  final RemittanceController controller;
  final AppLocalizations l;
  const _AddDocumentButton({required this.controller, required this.l});

  @override
  Widget build(BuildContext context) => Obx(() => InkWell(
        onTap: controller.isUploadLoading.value ? null : () => _showAddDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(border: Border.all(color: AppColors.lightPrimary, width: 1.5), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add, color: AppColors.lightPrimary, size: 18.sp),
            SizedBox(width: 6.w),
            Text(l.remittanceAddDocument, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.lightPrimary)),
          ])),
        ),
      ));

  void _showAddDialog(BuildContext context) {
    String selectedType = 'kyc';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: Text(l.remittanceAddDocument),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.remittanceDocumentType),
        SizedBox(height: 8.h),
        DropdownButton<String>(value: selectedType, isExpanded: true,
          items: [
            DropdownMenuItem(value: 'kyc', child: Text(l.remittanceDocTypeKyc)),
            DropdownMenuItem(value: 'payment_receipt', child: Text(l.remittanceDocTypePaymentReceipt)),
            DropdownMenuItem(value: 'payout_receipt', child: Text(l.remittanceDocTypePayoutReceipt)),
            DropdownMenuItem(value: 'other', child: Text(l.remittanceDocTypeOther)),
          ],
          onChanged: (v) { if (v != null) setState(() => selectedType = v); },
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text(l.remittanceCancel)),
        // v1.0.23+23 (R-2) — Three real pickers instead of the previous
        // single fake "Add" button that just inserted a hardcoded path.
        // Each picker calls the controller with the chosen `selectedType`
        // so the type is preserved across all three pickers.
        TextButton(
          onPressed: () async {
            Get.back();
            await controller.pickAttachmentFile(
              type: selectedType,
              imageSource: ImageSource.camera,
            );
          },
          child: Text(l.remittanceTakePhoto),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await controller.pickAttachmentFile(
              type: selectedType,
              imageSource: ImageSource.gallery,
            );
          },
          child: Text(l.remittanceChooseFromGallery),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await controller.pickAttachmentAnyFile(type: selectedType);
          },
          child: Text(l.remittanceChooseFile),
        ),
      ],
    )));
  }
}
