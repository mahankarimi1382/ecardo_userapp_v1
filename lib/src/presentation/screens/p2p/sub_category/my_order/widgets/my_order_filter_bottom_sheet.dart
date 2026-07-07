import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/controller/my_order_controller.dart';

import '../../../../../../../l10n/app_localizations.dart';

class MyOrderFilterBottomSheet extends StatefulWidget {
  final MyOrderController controller;

  const MyOrderFilterBottomSheet({super.key, required this.controller});

  @override
  State<MyOrderFilterBottomSheet> createState() =>
      _MyOrderFilterBottomSheetState();
}

class _MyOrderFilterBottomSheetState extends State<MyOrderFilterBottomSheet> {
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  String _selectedStatus = '';
  bool _isSearching = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _orderNumberController.text = widget.controller.orderNumberFilter.value;
    _selectedStatus = widget.controller.statusFilter.value;
    _statusController.text = _statusLabel(_selectedStatus);
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20.r),
          topEnd: Radius.circular(20.r),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.filterMyOrder,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 20.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: AppColors.lightTextPrimary.withValues(alpha: 0.10)),
            SizedBox(height: 12.h),
            _buildInputField(
              label: localization.p2pOrderNumber,
              controller: _orderNumberController,
              hintText: localization.p2pSearchOrderNumber,
            ),
            SizedBox(height: 14.h),
            _buildStatusDropdownField(),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: localization.reset,
                    isLoading: _isResetting,
                    loadingColor: AppColors.lightPrimary,
                    backgroundColor: AppColors.transparent,
                    textColor: AppColors.lightTextPrimary,
                    borderColor: AppColors.lightPrimary.withValues(alpha: 0.6),
                    borderWidth: 1.4,
                    onPressed: _isSearching ? null : _resetFilters,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: CommonButton(
                    text: localization.search,
                    isLoading: _isSearching,
                    onPressed: _isResetting ? null : _applyFilters,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.45),
              ),
            ),
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdownField() {
    final localization = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.status,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _openStatusDropdown,
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _statusController.text.isEmpty
                        ? localization.selectStatus
                        : _statusController.text,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.w,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openStatusDropdown() {
    final items = widget.controller.statusFilterOptions
        .map(_statusLabel)
        .toList();
    final localization = AppLocalizations.of(context)!;
    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.selectStatus,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: _statusController.text,
        currentlySelectedValue: _statusController.text,
        textController: _statusController,
        bottomSheetHeight: 380.h,
        notFoundText: localization.noStatusFound,
        onValueSelected: (value) {
          final selectedLabel = value.toString();
          final index = items.indexOf(selectedLabel);
          if (index == -1) return;
          setState(() {
            _selectedStatus = widget.controller.statusFilterOptions[index];
            _statusController.text = selectedLabel;
          });
        },
      ),
    );
  }

  Future<void> _applyFilters() async {
    if (_isSearching || _isResetting) return;
    setState(() {
      _isSearching = true;
    });
    await widget.controller.applyFilters(
      orderNumber: _orderNumberController.text,
      status: _selectedStatus,
    );
    if (!mounted) return;
    setState(() {
      _isSearching = false;
    });
    Get.back();
  }

  Future<void> _resetFilters() async {
    if (_isSearching || _isResetting) return;
    setState(() {
      _isResetting = true;
      _selectedStatus = '';
      _orderNumberController.clear();
      _statusController.clear();
    });
    await widget.controller.clearFilters();
    if (!mounted) return;
    setState(() {
      _isResetting = false;
    });
    Get.back();
  }

  String _statusLabel(String raw) {
    switch (raw) {
      case 'pending_payment':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'disputed':
        return 'Disputed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return raw;
    }
  }
}
