import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';

/// RemittanceDetailsScreen — full details of a remittance including audit log.
class RemittanceDetailsScreen extends StatefulWidget {
  const RemittanceDetailsScreen({super.key});

  @override
  State<RemittanceDetailsScreen> createState() =>
      _RemittanceDetailsScreenState();
}

class _RemittanceDetailsScreenState extends State<RemittanceDetailsScreen> {
  final RemittanceController controller = Get.find<RemittanceController>();

  @override
  void initState() {
    super.initState();
    final uuid = Get.arguments as String?;
    if (uuid != null) {
      controller.fetchDetails(uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Remittance Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isDetailsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final remittance = controller.selectedRemittance.value;
        if (remittance == null) {
          return Center(
            child: Text(
              'Remittance not found',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status banner
              _StatusBanner(status: remittance.status),
              SizedBox(height: 16.h),

              // Tracking info
              _SectionCard(
                title: 'Tracking',
                children: [
                  _DetailRow(label: 'UUID', value: remittance.uuid),
                  _DetailRow(label: 'Reference', value: remittance.trx),
                  if (remittance.createdAt != null)
                    _DetailRow(
                      label: 'Created',
                      value: _formatDate(remittance.createdAt!),
                    ),
                ],
              ),
              SizedBox(height: 16.h),

              // Amounts
              _SectionCard(
                title: 'Amounts',
                children: [
                  _DetailRow(
                    label: 'Send Amount',
                    value: remittance.sendAmount.toStringAsFixed(2),
                  ),
                  _DetailRow(
                    label: 'Exchange Rate',
                    value: remittance.exchangeRate.toStringAsFixed(4),
                  ),
                  _DetailRow(
                    label: 'Receive Amount',
                    value: remittance.receiveAmount.toStringAsFixed(2),
                  ),
                  _DetailRow(
                    label: 'System Fee',
                    value: remittance.systemFee.toStringAsFixed(2),
                  ),
                  _DetailRow(
                    label: 'Total Payable',
                    value: remittance.totalPayable.toStringAsFixed(2),
                    isBold: true,
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Sender
              if (remittance.senderInfo != null)
                _SectionCard(
                  title: 'Sender',
                  children: [
                    _DetailRow(
                      label: 'Name',
                      value: remittance.senderInfo!.name,
                    ),
                    _DetailRow(
                      label: 'Country',
                      value: remittance.senderInfo!.country.toUpperCase(),
                    ),
                    _DetailRow(
                      label: 'Phone',
                      value: remittance.senderInfo!.phone,
                    ),
                    _DetailRow(
                      label: 'ID Number',
                      value: remittance.senderInfo!.idNumber,
                    ),
                    _DetailRow(
                      label: 'Type',
                      value: remittance.senderInfo!.type == 'individual'
                          ? 'Individual'
                          : 'Business',
                    ),
                  ],
                ),
              SizedBox(height: 16.h),

              // Receiver
              if (remittance.receiverInfo != null)
                _SectionCard(
                  title: 'Receiver',
                  children: [
                    _DetailRow(
                      label: 'Name',
                      value: remittance.receiverInfo!.name,
                    ),
                    _DetailRow(
                      label: 'Country',
                      value: remittance.receiverInfo!.country.toUpperCase(),
                    ),
                    _DetailRow(
                      label: 'Phone',
                      value: remittance.receiverInfo!.phone,
                    ),
                    if (remittance.receiverInfo!.bankName != null)
                      _DetailRow(
                        label: 'Bank',
                        value: remittance.receiverInfo!.bankName!,
                      ),
                    if (remittance.receiverInfo!.accountNumber != null)
                      _DetailRow(
                        label: 'Account',
                        value: remittance.receiverInfo!.accountNumber!,
                      ),
                    if (remittance.receiverInfo!.iban != null)
                      _DetailRow(
                        label: 'IBAN',
                        value: remittance.receiverInfo!.iban!,
                      ),
                    if (remittance.receiverInfo!.alipayAccount != null)
                      _DetailRow(
                        label: 'Alipay',
                        value: remittance.receiverInfo!.alipayAccount!,
                      ),
                    if (remittance.receiverInfo!.wechatAccount != null)
                      _DetailRow(
                        label: 'WeChat',
                        value: remittance.receiverInfo!.wechatAccount!,
                      ),
                  ],
                ),

              // Attachments
              if (remittance.attachments != null &&
                  remittance.attachments!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _SectionCard(
                  title: 'Documents (${remittance.attachments!.length})',
                  children: remittance.attachments!
                      .map((a) => _DetailRow(
                            label: _attachmentLabel(a.type),
                            value: a.filePath.split('/').last,
                          ))
                      .toList(),
                ),
              ],

              // Audit log
              if (remittance.logs != null && remittance.logs!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _SectionCard(
                  title: 'Status History',
                  children: remittance.logs!
                      .map((log) => _LogEntry(log: log))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  String _attachmentLabel(String type) {
    switch (type) {
      case 'kyc':
        return 'KYC';
      case 'payment_receipt':
        return 'Payment Receipt';
      case 'payout_receipt':
        return 'Payout Receipt';
      default:
        return 'Document';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBanner extends StatelessWidget {
  final RemittanceStatus status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(status), color: color, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  status.isTerminal
                      ? 'This request is finalized.'
                      : status.isPending
                          ? 'Your request is being processed.'
                          : 'Please complete the required steps.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(RemittanceStatus status) {
    switch (status) {
      case RemittanceStatus.completed:
      case RemittanceStatus.destinationPaid:
      case RemittanceStatus.refundCompleted:
        return Colors.green;
      case RemittanceStatus.rejected:
      case RemittanceStatus.expired:
      case RemittanceStatus.cancelled:
        return Colors.red;
      case RemittanceStatus.draft:
      case RemittanceStatus.waitingInformation:
      case RemittanceStatus.waitingDocuments:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(RemittanceStatus status) {
    if (status.isTerminal) {
      return status == RemittanceStatus.completed
          ? Icons.check_circle
          : Icons.cancel;
    }
    return Icons.hourglass_top;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final RemittanceLog log;

  const _LogEntry({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.h),
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.newStatus?.label ?? '-',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                if (log.note != null && log.note!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    log.note!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
                SizedBox(height: 2.h),
                Text(
                  _formatLogMeta(log),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLogMeta(RemittanceLog log) {
    final parts = <String>[];
    if (log.causerType != null) {
      parts.add('by ${log.causerType}');
    }
    if (log.ipAddress != null && log.ipAddress != 'system') {
      parts.add('IP: ${log.ipAddress}');
    }
    if (log.createdAt != null) {
      parts.add(_formatDate(log.createdAt!));
    }
    return parts.join(' • ');
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
