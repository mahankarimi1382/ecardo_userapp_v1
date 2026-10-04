import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_label_text.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/multiple_image_picker_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/add_new_ticket_controller.dart';

class AddNewTicket extends StatefulWidget {
  const AddNewTicket({super.key});

  @override
  State<AddNewTicket> createState() => _AddNewTicketState();
}

class _AddNewTicketState extends State<AddNewTicket> {
  final AddNewTicketController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: AppSpacing.cardGap),
              CommonAppBar(title: localization.addNewTicketScreenTitle),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Container(
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(24),
                      topEnd: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSpacing.sm),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localization.addNewTicketTitle,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.titleFocusNode,
                              isFocused: controller.isTitleFocused.value,
                              backgroundColor: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground,
                              controller: controller.titleController,
                              hintText: "",
                              keyboardType: TextInputType.text,
                              textStyle: AppTextStyles.bodyMedium.copyWith(
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localization.addNewTicketDescription,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.descriptionFocusNode,
                              isFocused: controller.isDescriptionFocused.value,
                              backgroundColor: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground,
                              controller: controller.descriptionController,
                              keyboardType: TextInputType.text,
                              hintText: "",
                              maxLine: 4,
                              textStyle: AppTextStyles.bodyMedium.copyWith(
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonLabelText(
                              text: localization.addNewTicketAttachments,
                              isRequired: false,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                controller.addAttachment();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.mainSoftBlue
                                      : AppColors.lightPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  PngAssets.addCommonIcon,
                                  color: isDark ? AppColors.deepBlack : AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        Obx(
                          () => Column(
                            children: controller.attachments
                                .map(
                                  (id) => Padding(
                                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                                    child: _buildAttachmentItem(
                                      context,
                                      id,
                                      controller,
                                      isDark,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        CommonButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            if (!controller.validateForm()) {
                              return;
                            }
                            await controller.addNewTicket();
                          },
                          width: double.infinity,
                          text: localization.addNewTicketAddButton,
                        ),
                        SizedBox(height: AppSpacing.bottomSafe(context, 20)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isAddTicketLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(
    BuildContext context,
    int id,
    AddNewTicketController controller,
    bool isDark,
  ) {
    final localization = AppLocalizations.of(context)!;
    final MultipleImagePickerController multipleImagePickerController = Get.put(
      MultipleImagePickerController(),
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showImageSourceSheet(id);
      },
      child: Obx(
        () => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: !multipleImagePickerController.images.containsKey(id)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          localization.addNewTicketAttachFile,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.softGray : AppColors.lightTextTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            if (multipleImagePickerController.images.containsKey(id))
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Image.file(
                  multipleImagePickerController.images[id]!,
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            if (controller.attachments.length > 1 ||
                multipleImagePickerController.images.containsKey(id))
              PositionedDirectional(
                top: 8,
                end: 8,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.removeAttachment(id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showImageSourceSheet(int attachmentId) {
    Get.bottomSheet(
      MultipleImagePickerDropdownBottomSheet(attachmentId: attachmentId),
    );
  }
}
