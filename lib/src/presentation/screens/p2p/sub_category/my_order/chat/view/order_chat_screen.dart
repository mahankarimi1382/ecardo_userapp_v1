import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/chat/controller/order_chat_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/chat/widgets/order_chat_message_bubble.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/model/my_order_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/model/order_message_response_model.dart'
    as chat_model;

class OrderChatScreen extends StatefulWidget {
  final String orderId;
  final Role role;

  const OrderChatScreen({super.key, required this.orderId, required this.role});

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  late final String _tag;
  late final OrderChatController controller;

  @override
  void initState() {
    super.initState();
    _tag = 'order_chat_${widget.orderId}';
    controller = Get.put(
      OrderChatController(orderId: widget.orderId),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<OrderChatController>(tag: _tag)) {
      Get.delete<OrderChatController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final counterparty = _counterpartyName(widget.role);
    final initial = counterparty.isNotEmpty
        ? counterparty[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: Image.asset(
            PngAssets.arrowLeftCommonIcon,
            width: 24.w,
            color: AppColors.lightTextPrimary,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.lightTextPrimary.withValues(
                alpha: 0.7,
              ),
              child: Text(
                initial,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              counterparty,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.08),
                  ),
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CommonLoading();
                  }
                  if (controller.messages.isEmpty) {
                    return Center(
                      child: Text(
                        localization.p2pNoMessagesYet,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.fetchMessages(),
                    child: ListView.builder(
                      controller: controller.scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final item = controller.messages[index];
                        return OrderChatMessageBubble(
                          message: item,
                          onAttachmentTap: _showAttachmentPreview,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          _buildComposer(localization),
        ],
      ),
    );
  }

  Widget _buildComposer(AppLocalizations localization) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 8.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Obx(() {
              final file = controller.selectedAttachment.value;
              if (file == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          file.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.clearAttachment,
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.w,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.messageController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: localization.p2pTypeYourMessage,
                              hintStyle: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w500,
                                fontSize: 13.sp,
                                color: AppColors.lightTextPrimary.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showAttachmentPicker,
                          child: Icon(
                            Icons.attach_file_rounded,
                            size: 22.w,
                            color: AppColors.lightTextPrimary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Obx(
                  () => GestureDetector(
                    onTap: controller.isSending.value
                        ? null
                        : controller.sendMessage,
                    child: Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: controller.isSending.value
                          ? Center(
                              child: SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              size: 20.w,
                              color: AppColors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPicker() {
    Get.bottomSheet(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(20.r),
            topEnd: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: AppLocalizations.of(Get.context!)!.p2pCamera,
                    onPressed: () async {
                      Get.back();
                      await controller.pickAttachment(ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CommonButton(
                    text: AppLocalizations.of(Get.context!)!.p2pGallery,
                    onPressed: () async {
                      Get.back();
                      await controller.pickAttachment(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPreview(chat_model.Attachment attachment) {
    final url = attachment.path;
    if (url == null || url.isEmpty) return;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      attachment.name ??
                          AppLocalizations.of(Get.context!)!.p2pAttachment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.w,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => SizedBox(
                    height: 150.h,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(
                          Get.context!,
                        )!.p2pUnableToLoadAttachment,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _counterpartyName(Role role) {
    if (role.isBuyer == true) {
      return role.seller?.name ??
          role.seller?.username ??
          AppLocalizations.of(Get.context!)!.p2pUser;
    }
    return role.buyer?.name ??
        role.buyer?.username ??
        AppLocalizations.of(Get.context!)!.p2pUser;
  }
}
