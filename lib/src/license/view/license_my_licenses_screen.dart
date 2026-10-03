import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../controller/license_controller.dart';
import '../model/license_models.dart';

class LicenseMyLicensesScreen extends StatefulWidget {
  const LicenseMyLicensesScreen({super.key});

  @override
  State<LicenseMyLicensesScreen> createState() => _LicenseMyLicensesScreenState();
}

class _LicenseMyLicensesScreenState extends State<LicenseMyLicensesScreen> with SingleTickerProviderStateMixin {
  late final LicenseController controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LicenseController>()
        ? Get.find<LicenseController>()
        : Get.put(LicenseController());
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchMyLicenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              en: 'My Licenses',
              fa: 'لایسنس‌های من',
              ar: 'تراخيصي',
              zh: '我的许可证',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.lightPrimary,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: AppColors.lightPrimary,
              tabs: [
                Tab(text: l10nPick(context, en: 'Active Licenses', fa: 'لایسنس‌های فعال')),
                Tab(text: l10nPick(context, en: 'Expired Licenses', fa: 'منقضی‌شده')),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMyLicenses.value && controller.myLicenses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final activeList = controller.myLicenses.where((k) => !k.isExpired).toList();
              final expiredList = controller.myLicenses.where((k) => k.isExpired).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(context, activeList, isActive: true),
                  _buildList(context, expiredList, isActive: false),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<LicenseKeyItem> list, {required bool isActive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vpn_key_off_outlined, size: 56.sp, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              isActive
                  ? l10nPick(context, en: 'No active licenses.', fa: 'لایسنس فعالی ندارید.')
                  : l10nPick(context, en: 'No expired licenses.', fa: 'لایسنس منقضی‌شده‌ای ندارید.'),
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchMyLicenses(),
      child: ListView.separated(
        padding: EdgeInsets.all(16.r),
        itemCount: list.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, i) => _buildLicenseCard(context, list[i]),
      ),
    );
  }

  Widget _buildLicenseCard(BuildContext context, LicenseKeyItem item) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: item.isExpired ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.isExpired
                      ? l10nPick(context, en: 'Expired', fa: 'منقضی‌شده')
                      : '${item.daysRemaining ?? 30} ${l10nPick(context, en: 'Days Left', fa: 'روز باقی‌مانده')}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: item.isExpired ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${item.edition} • ${item.durationMonths} ${l10nPick(context, en: 'Months', fa: 'ماهه')}',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 14.h),

          // Key box with copy button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.licenseKey.isNotEmpty ? item.licenseKey : item.keyMasked,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item.licenseKey.isNotEmpty ? item.licenseKey : item.keyMasked));
                    ToastHelper().showSuccessToast(l10nPick(context, en: 'Key copied!', fa: 'کلید کپی شد!'));
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.expiresAt != null
                    ? '${l10nPick(context, en: 'Expires:', fa: 'انقضا:')} ${item.expiresAt!.split("T")[0]}'
                    : '',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
              ),
              CommonButton(
                width: 140,
                height: 38,
                fontSize: 12,
                text: l10nPick(
                  context,
                  en: 'Renew License',
                  fa: 'تمدید لایسنس',
                  ar: 'تجديد الترخيص',
                  zh: '续订许可证',
                ),
                onPressed: () async {
                  final newOrd = await controller.renewLicense(item.id);
                  if (newOrd != null) {
                    ToastHelper().showSuccessToast(l10nPick(
                      context,
                      en: 'Renewal order created!',
                      fa: 'سفارش تمدید لایسنس ثبت شد!',
                    ));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
