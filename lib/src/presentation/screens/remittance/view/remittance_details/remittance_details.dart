import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';

class RemittanceDetailsScreen extends StatefulWidget {
  const RemittanceDetailsScreen({super.key});
  @override
  State<RemittanceDetailsScreen> createState() => _RemittanceDetailsScreenState();
}

class _RemittanceDetailsScreenState extends State<RemittanceDetailsScreen> {
  final RemittanceController controller = Get.find<RemittanceController>();

  @override
  void initState() {
    super.initState();
    final uuid = Get.arguments as String?;
    if (uuid != null) controller.fetchDetails(uuid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary), onPressed: () => Get.back()),
        title: Text('Remittance Details', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
      ),
      body: Obx(() {
        if (controller.isDetailsLoading.value) return const Center(child: CircularProgressIndicator());
        final r = controller.selectedRemittance.value;
        if (r == null) return Center(child: Text('Remittance not found', style: TextStyle(color: AppColors.lightTextSecondary)));
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _StatusBanner(status: r.status),
            SizedBox(height: 16.h),
            _Card('Tracking', [_Row('UUID', r.uuid), _Row('Reference', r.trx), if (r.createdAt != null) _Row('Created', _formatDate(r.createdAt!))]),
            SizedBox(height: 16.h),
            _Card('Amounts', [
              _Row('Send Amount', r.sendAmount.toStringAsFixed(2)),
              _Row('Exchange Rate', r.exchangeRate.toStringAsFixed(4)),
              _Row('Receive Amount', r.receiveAmount.toStringAsFixed(2)),
              _Row('System Fee', r.systemFee.toStringAsFixed(2)),
              _Row('Total Payable', r.totalPayable.toStringAsFixed(2), bold: true),
            ]),
            SizedBox(height: 16.h),
            if (r.senderInfo != null) _Card('Sender', [
              _Row('Name', r.senderInfo!.name),
              _Row('Country', r.senderInfo!.country.toUpperCase()),
              _Row('Phone', r.senderInfo!.phone),
              _Row('ID Number', r.senderInfo!.idNumber),
              _Row('Type', r.senderInfo!.type == 'individual' ? 'Individual' : 'Business'),
            ]),
            SizedBox(height: 16.h),
            if (r.receiverInfo != null) _Card('Receiver', [
              _Row('Name', r.receiverInfo!.name),
              _Row('Country', r.receiverInfo!.country.toUpperCase()),
              _Row('Phone', r.receiverInfo!.phone),
              if (r.receiverInfo!.bankName != null) _Row('Bank', r.receiverInfo!.bankName!),
              if (r.receiverInfo!.accountNumber != null) _Row('Account', r.receiverInfo!.accountNumber!),
              if (r.receiverInfo!.iban != null) _Row('IBAN', r.receiverInfo!.iban!),
              if (r.receiverInfo!.alipayAccount != null) _Row('Alipay', r.receiverInfo!.alipayAccount!),
              if (r.receiverInfo!.wechatAccount != null) _Row('WeChat', r.receiverInfo!.wechatAccount!),
            ]),
            if (r.attachments != null && r.attachments!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _Card('Documents (${r.attachments!.length})', r.attachments!.map((a) => _Row(_attachmentLabel(a.type), a.filePath.split('/').last)).toList()),
            ],
            if (r.logs != null && r.logs!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _Card('Status History', r.logs!.map((log) => _LogEntry(log: log)).toList()),
            ],
          ]),
        );
      }),
    );
  }

  String _attachmentLabel(String t) => switch (t) { 'kyc' => 'KYC', 'payment_receipt' => 'Payment Receipt', 'payout_receipt' => 'Payout Receipt', _ => 'Document' };
  String _formatDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _StatusBanner extends StatelessWidget {
  final RemittanceStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(children: [
        Icon(_statusIcon(status), color: color, size: 24.sp),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(status.label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: color)),
          Text(status.isTerminal ? 'This request is finalized.' : status.isPending ? 'Your request is being processed.' : 'Please complete the required steps.', style: TextStyle(fontSize: 11.sp, color: color.withValues(alpha: 0.8))),
        ])),
      ]),
    );
  }

  Color _statusColor(RemittanceStatus s) => switch (s) {
    RemittanceStatus.completed || RemittanceStatus.destinationPaid || RemittanceStatus.refundCompleted => AppColors.success,
    RemittanceStatus.rejected || RemittanceStatus.expired || RemittanceStatus.cancelled => AppColors.error,
    RemittanceStatus.draft || RemittanceStatus.waitingInformation || RemittanceStatus.waitingDocuments => AppColors.grey,
    _ => AppColors.warning,
  };

  IconData _statusIcon(RemittanceStatus s) => s.isTerminal ? (s == RemittanceStatus.completed ? Icons.check_circle : Icons.cancel) : Icons.hourglass_top;
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card(this.title, this.children);
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(color: AppColors.lightSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)), SizedBox(height: 12.h), ...children]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
      SizedBox(width: 12.w),
      Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary, fontWeight: bold ? FontWeight.w700 : FontWeight.w500))),
    ]),
  );
}

class _LogEntry extends StatelessWidget {
  final RemittanceLog log;
  const _LogEntry({required this.log});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(margin: EdgeInsets.only(top: 4.h), width: 8.w, height: 8.w, decoration: BoxDecoration(color: AppColors.lightPrimary, shape: BoxShape.circle)),
      SizedBox(width: 10.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(log.newStatus?.label ?? '-', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        if (log.note != null && log.note!.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(log.note!, style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
        ],
        SizedBox(height: 2.h),
        Text(_meta(log), style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary)),
      ])),
    ]),
  );

  String _meta(RemittanceLog log) {
    final parts = <String>[];
    if (log.causerType != null) parts.add('by ${log.causerType}');
    if (log.ipAddress != null && log.ipAddress != 'system') parts.add('IP: ${log.ipAddress}');
    if (log.createdAt != null) parts.add(_formatDate(log.createdAt!));
    return parts.join(' • ');
  }

  String _formatDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
