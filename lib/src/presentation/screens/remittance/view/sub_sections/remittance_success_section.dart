import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 5: Success + document upload.
class RemittanceSuccessSection extends StatelessWidget {
  const RemittanceSuccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemittanceController>();

    return Obx(() {
      final remittance = controller.createdRemittance.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success indicator
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Request Submitted!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Your remittance request has been created.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Tracking info
          if (remittance != null) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Tracking UUID', value: remittance.uuid),
                  SizedBox(height: 8.h),
                  _InfoRow(label: 'Reference', value: remittance.trx),
                  SizedBox(height: 8.h),
                  _InfoRow(
                    label: 'Status',
                    value: remittance.status.label,
                  ),
                  SizedBox(height: 8.h),
                  _InfoRow(
                    label: 'Send Amount',
                    value: remittance.sendAmount.toStringAsFixed(2),
                  ),
                  SizedBox(height: 8.h),
                  _InfoRow(
                    label: 'Receive Amount',
                    value: remittance.receiveAmount.toStringAsFixed(2),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 24.h),

          // Document upload section
          Text(
            'Upload Documents',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Upload your KYC documents and payment receipt to proceed.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 16.h),

          // Pending attachments list
          Obx(() => controller.pendingAttachments.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  children: controller.pendingAttachments
                      .asMap()
                      .entries
                      .map((entry) {
                    return _AttachmentItem(
                      path: entry.value['path'] ?? '',
                      type: entry.value['type'] ?? 'other',
                      onRemove: () =>
                          controller.removeAttachmentAt(entry.key),
                    );
                  }).toList(),
                )),

          // Add document button
          SizedBox(height: 12.h),
          _AddDocumentButton(controller: controller),
        ],
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final String path;
  final String type;
  final VoidCallback onRemove;

  const _AttachmentItem({
    required this.path,
    required this.type,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Icon(_iconForType(type), color: AppColors.primaryColor, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelForType(type),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  path.split('/').last,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[400], size: 18.sp),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _labelForType(String type) {
    switch (type) {
      case 'kyc':
        return 'KYC Document';
      case 'payment_receipt':
        return 'Payment Receipt';
      case 'payout_receipt':
        return 'Payout Receipt';
      default:
        return 'Document';
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'kyc':
        return Icons.badge;
      case 'payment_receipt':
        return Icons.receipt;
      case 'payout_receipt':
        return Icons.payment;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _AddDocumentButton extends StatelessWidget {
  final RemittanceController controller;

  const _AddDocumentButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
          onTap: controller.isUploadLoading.value
              ? null
              : () => _showAddDialog(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.primaryColor, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Add Document',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _showAddDialog(BuildContext context) {
    String selectedType = 'kyc';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Document Type'),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'kyc', child: Text('KYC Document')),
                  DropdownMenuItem(
                      value: 'payment_receipt',
                      child: Text('Payment Receipt')),
                  DropdownMenuItem(
                      value: 'payout_receipt',
                      child: Text('Payout Receipt')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => selectedType = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would use image_picker/file_picker
                // For now, just add a placeholder
                controller.addAttachment(
                  'uploads/remittance/doc_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  selectedType,
                );
                Get.back();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
