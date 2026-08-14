import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';

class RemittanceHistoryScreen extends StatefulWidget {
  const RemittanceHistoryScreen({super.key});
  @override
  State<RemittanceHistoryScreen> createState() => _RemittanceHistoryScreenState();
}

class _RemittanceHistoryScreenState extends State<RemittanceHistoryScreen> {
  final RemittanceController controller = Get.put(RemittanceController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.fetchHistory(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary), onPressed: () => Get.back()),
        title: Text(l.remittanceHistoryTitle, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppColors.lightPrimary), onPressed: () => Get.toNamed(BaseRoute.remittance)),
        ],
      ),
      body: Obx(() {
        if (controller.isHistoryLoading.value && controller.history.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.history.isEmpty) {
          return _EmptyState(onRefresh: () => controller.fetchHistory(refresh: true), l: l);
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchHistory(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            itemCount: controller.history.length + (controller.historyHasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.history.length) {
                return Padding(padding: EdgeInsets.all(16.w), child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))));
              }
              return _RemittanceCard(
                remittance: controller.history[index],
                onTap: () {
                  controller.selectedRemittance.value = controller.history[index];
                  Get.toNamed(BaseRoute.remittanceDetails, arguments: controller.history[index].uuid);
                },
                l: l,
              );
            },
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  final AppLocalizations l;
  const _EmptyState({required this.onRefresh, required this.l});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: EdgeInsets.all(32.w),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long, size: 64.sp, color: AppColors.lightBorder),
      SizedBox(height: 16.h),
      Text(l.remittanceNoHistory, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary)),
      SizedBox(height: 8.h),
      Text(l.remittanceNoHistoryHint, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary), textAlign: TextAlign.center),
      SizedBox(height: 24.h),
      ElevatedButton(onPressed: onRefresh, child: Text(l.remittanceRefresh)),
    ]),
  ));
}

class _RemittanceCard extends StatelessWidget {
  final Remittance remittance;
  final VoidCallback onTap;
  final AppLocalizations l;
  const _RemittanceCard({required this.remittance, required this.onTap, required this.l});

  @override
  Widget build(BuildContext context) {
    final status = remittance.status;
    final statusColor = _statusColor(status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(color: AppColors.lightSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(remittance.trx, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(remittanceStatusLabel(status, l), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: statusColor)),
            ),
          ]),
          SizedBox(height: 12.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.remittanceSend, style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary)),
              Text(remittance.sendAmount.toStringAsFixed(2), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
            ]),
            Icon(Icons.arrow_forward, color: AppColors.lightTextSecondary, size: 16.sp),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(l.remittanceReceive, style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary)),
              Text(remittance.receiveAmount.toStringAsFixed(2), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
            ]),
          ]),
          if (remittance.createdAt != null) ...[
            SizedBox(height: 8.h),
            Divider(color: AppColors.lightBorder, height: 1),
            SizedBox(height: 8.h),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.remittanceDate, style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
              Text(_formatDate(remittance.createdAt!), style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
            ]),
          ],
        ]),
      ),
    );
  }

  Color _statusColor(RemittanceStatus s) => switch (s) {
    RemittanceStatus.completed || RemittanceStatus.destinationPaid || RemittanceStatus.refundCompleted => AppColors.success,
    RemittanceStatus.rejected || RemittanceStatus.expired || RemittanceStatus.cancelled => AppColors.error,
    RemittanceStatus.draft || RemittanceStatus.waitingInformation || RemittanceStatus.waitingDocuments => AppColors.grey,
    _ => AppColors.warning,
  };

  String _formatDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
