import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/controller/p2p_buy_ad_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;

class OrderDetailsTimelineSectionWidget extends StatelessWidget {
  final order_details.Data data;
  final P2pOrderDetailsController controller;

  const OrderDetailsTimelineSectionWidget({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          Obx(
            () => _timelineItem(
              title: localization.p2pOrderCreated,
              isExpanded: controller.isOrderCreatedExpanded.value,
              onToggle: controller.toggleOrderCreated,
              child: Column(
                children: [
                  _keyValue(
                    localization.p2pFiatAmount,
                    data.fiatAmount ?? '--',
                  ),
                  SizedBox(height: 10.h),
                  _keyValue(localization.p2pPrice, data.price ?? '--'),
                  SizedBox(height: 10.h),
                  _keyValue(
                    localization.p2pReceiveQuantity,
                    data.assetAmount ?? '--',
                  ),
                  SizedBox(height: 10.h),
                  _keyValue(
                    localization.p2pPaymentMethod,
                    data.paymentMethod?.name ?? '--',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => _timelineItem(
              title: _transferTimelineTitle(),
              isExpanded: controller.isTransferExpanded.value,
              onToggle: controller.toggleTransfer,
              showHeader: _shouldShowTransferHeader(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_transferTimelineDescription().isNotEmpty) ...[
                    Text(
                      _transferTimelineDescription(),
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.80,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  Divider(
                    height: 1,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.14),
                  ),
                  SizedBox(height: 10.h),
                  if (_canChangePaymentMethod(data, controller)) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.recipientPaymentMethod?.name ??
                                data.paymentMethod?.name ??
                                '--',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () =>
                              _openPaymentMethodChangeSheet(controller, data),
                          child: Text(
                            localization.p2pChange,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                  ..._recipientFields(data.recipientPaymentMethod?.fields),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          if (_shouldShowNotifyTimelineItem()) ...[
            Obx(
              () => _timelineItem(
                title: _notifyTimelineTitle(),
                isExpanded: controller.isNotifySellerExpanded.value,
                onToggle: controller.toggleNotifySeller,
                showConnector: false,
                child: Text(
                  _notifyTimelineDescription(),
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowTransferHeader() {
    final status = (data.status ?? '').toLowerCase();
    if (!controller.isBuy && status != 'paid') return false;
    return true;
  }

  String _transferTimelineTitle() {
    final localization = AppLocalizations.of(Get.context!)!;
    final status = (data.status ?? '').toLowerCase();
    if (!controller.isBuy && status == 'paid') {
      final buyerName = data.role?.buyer?.name?.trim().isNotEmpty == true
          ? data.role?.buyer?.name?.trim()
          : data.role?.buyer?.username?.trim();
      return localization.p2pConfirmPaymentFrom(buyerName ?? '--');
    }

    if (!controller.isBuy) return '';
    return 'Open (${data.recipientPaymentMethod?.name ?? localization.p2pPaymentMethod}) to transfer ${data.totalFiatAmount ?? data.fiatAmount ?? '--'}';
  }

  String _transferTimelineDescription() {
    final localization = AppLocalizations.of(Get.context!)!;
    final status = (data.status ?? '').toLowerCase();
    if (!controller.isBuy && status == 'paid') {
      return localization.p2pVerifyAmountAndSender;
    }
    if (!controller.isBuy) return '';
    return localization.p2pTransferFundsToSeller;
  }

  bool _shouldShowNotifyTimelineItem() {
    final status = (data.status ?? '').toLowerCase();
    if (controller.isBuy && status == 'pending_payment') return true;
    return status == 'paid';
  }

  String _notifyTimelineTitle() {
    final localization = AppLocalizations.of(Get.context!)!;
    final status = (data.status ?? '').toLowerCase();
    if (!controller.isBuy && status == 'paid') {
      return localization.p2pConfirmPaymentReceived;
    }
    return localization.p2pNotifySeller;
  }

  String _notifyTimelineDescription() {
    final localization = AppLocalizations.of(Get.context!)!;
    final status = (data.status ?? '').toLowerCase();
    if (!controller.isBuy && status == 'paid') {
      return localization.p2pConfirmPaymentReceivedDescription;
    }
    return localization.p2pNotifySellerDescription;
  }

  Widget _timelineItem({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    bool showConnector = true,
    bool showHeader = true,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 12.w,
            child: Column(
              children: [
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.lightPrimary.withValues(alpha: 0.45),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onToggle,
                          child: AnimatedRotation(
                            turns: isExpanded ? 0 : -0.5,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20.w,
                              color: AppColors.lightTextPrimary.withValues(
                                alpha: 0.56,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (showHeader && isExpanded) ...[
                    SizedBox(height: 7.h),
                    child,
                  ],
                  if (!showHeader) child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _recipientFields(List<order_details.Field>? fields) {
    final safeFields = fields ?? <order_details.Field>[];
    if (safeFields.isEmpty) {
      return <Widget>[_keyValue('Recipient', '--', showCopy: false)];
    }

    return safeFields
        .map(
          (field) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _isImageField(field)
                ? _imageFieldRow(field.name ?? '--', field.value ?? '')
                : _keyValue(
                    field.name ?? '--',
                    field.value ?? '--',
                    showCopy: true,
                  ),
          ),
        )
        .toList();
  }

  Widget _keyValue(String title, String value, {bool showCopy = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              if (showCopy &&
                  value.trim().isNotEmpty &&
                  value.trim() != '--') ...[
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () => _copyFieldValue(value),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16.w,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copyFieldValue(String value) async {
    final safeValue = value.trim();
    if (safeValue.isEmpty || safeValue == '--') return;
    await Clipboard.setData(ClipboardData(text: safeValue));
    ToastHelper().showSuccessToast('Copied');
  }

  Widget _imageFieldRow(String title, String imageUrl) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _showImagePreviewDialog(imageUrl),
            child: Text(
              "View",
              maxLines: 1,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: AppColors.lightPrimary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isImageField(order_details.Field field) {
    final type = (field.type ?? '').toLowerCase();
    final value = (field.value ?? '').trim().toLowerCase();

    if (value.isEmpty) return false;
    if (type.contains('image') || type.contains('file')) return true;
    return value.endsWith('.png') ||
        value.endsWith('.jpg') ||
        value.endsWith('.jpeg') ||
        value.endsWith('.webp') ||
        value.endsWith('.gif');
  }

  void _showImagePreviewDialog(String imageUrl) {
    if (imageUrl.trim().isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GestureDetector(
                  onTap: Get.back,
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120.h,
                      alignment: Alignment.center,
                      child: Text(
                        'Unable to load image',
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canChangePaymentMethod(
    order_details.Data data,
    P2pOrderDetailsController controller,
  ) {
    return controller.isBuy &&
        (data.status ?? '').toLowerCase() == 'pending_payment';
  }

  void _openPaymentMethodChangeSheet(
    P2pOrderDetailsController controller,
    order_details.Data data,
  ) {
    if (!_canChangePaymentMethod(data, controller)) return;
    final methods = controller.paymentMethods;
    if (methods.isEmpty) return;

    final labels = methods.map((item) => item.label).toList();
    final selected = controller.selectedPaymentMethod?.label ?? '';
    final textController = TextEditingController(text: selected);

    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: AppLocalizations.of(Get.context!)!.p2pSelectPaymentMethod,
        isShowTitle: true,
        dropdownItems: labels,
        selectedValue: labels,
        selectedItem: selected,
        currentlySelectedValue: selected,
        textController: textController,
        bottomSheetHeight: 420.h,
        notFoundText: 'No payment method found',
        onValueSelected: (value) async {
          final selectedValue = value.toString();
          AdPaymentOption? selectedOption;
          for (final item in methods) {
            if (item.label == selectedValue) {
              selectedOption = item;
              break;
            }
          }
          if (selectedOption == null) return;
          if (controller.selectedPaymentMethodId.value == selectedOption.id) {
            return;
          }
          Get.back();
          await controller.updateOrderPaymentMethod(selectedOption.id);
        },
      ),
    );
  }
}
