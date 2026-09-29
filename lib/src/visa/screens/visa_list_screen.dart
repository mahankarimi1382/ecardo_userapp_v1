import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_detail_screen.dart';

class VisaListScreen extends StatefulWidget {
  const VisaListScreen({super.key});

  @override
  State<VisaListScreen> createState() => _VisaListScreenState();
}

class _VisaListScreenState extends State<VisaListScreen> {
  late final VisaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());
    _controller.loadUserRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'My Visa Applications', fa: 'درخواست‌های ویزای من'),
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
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadUserRequests,
        color: const Color(0xFF7445FF),
        child: Column(
          children: [
            // Status Filter Tabs
            Container(
              height: 48.h,
              color: Colors.white,
              child: Obx(() {
                final current = _controller.selectedFilterStatus.value;
                final filters = [
                  {'id': 'ALL', 'label': l10nPick(context, en: 'All', fa: 'همه')},
                  {'id': 'UNDER_REVIEW', 'label': l10nPick(context, en: 'Reviewing', fa: 'در حال بررسی')},
                  {'id': 'AWAITING_PAYMENT', 'label': l10nPick(context, en: 'Payment', fa: 'منتظر پرداخت')},
                  {'id': 'APPROVED', 'label': l10nPick(context, en: 'Approved', fa: 'صادرشده')},
                  {'id': 'REJECTED', 'label': l10nPick(context, en: 'Rejected', fa: 'ردشده')},
                ];

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final f = filters[index];
                    final isSelected = current == f['id'];

                    return InkWell(
                      onTap: () {
                        _controller.selectedFilterStatus.value = f['id'] as String;
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF7445FF) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Text(
                            f['label'] as String,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1),

            // List of Requests
            Expanded(
              child: Obx(() {
                if (_controller.isLoadingRequests.value && _controller.myRequests.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = _controller.filteredRequests;

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 64.r, color: Colors.grey[400]),
                          SizedBox(height: 12.h),
                          Text(
                            l10nPick(context, en: 'No visa applications found', fa: 'هیچ درخواست ویزایی یافت نشد'),
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF334155)),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Apply for your destination visa and track the status in real time.',
                              fa: 'کشور مقصد خود را انتخاب کرده و درخواست ویزای آنلاین ثبت فرمایید.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7445FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: Text(
                              l10nPick(context, en: 'New Application', fa: 'ثبت درخواست جدید'),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final req = list[index];
                    return _VisaRequestCard(
                      request: req,
                      onTap: () {
                        Get.to(() => VisaDetailScreen(caseNo: req.caseNo));
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisaRequestCard extends StatelessWidget {
  final VisaRequestModel request;
  final VoidCallback onTap;

  const _VisaRequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return VisaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  VisaCountryFlag(flagUrl: request.countryFlag, size: 36),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.countryName,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        request.visaTitle,
                        style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              VisaStatusBadge(status: request.status),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.applicantName,
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2.h),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      request.caseNo,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${request.totalFee.toStringAsFixed(0)} ${request.currency}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF7445FF),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        l10nPick(context, en: 'Track', fa: 'پیگیری'),
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF7445FF)),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF7445FF)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
