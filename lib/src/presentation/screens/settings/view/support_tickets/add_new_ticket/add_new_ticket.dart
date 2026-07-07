import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_label_text.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/multiple_image_picker_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/add_new_ticket_controller.dart';

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

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              CommonAppBar(title: localization.addNewTicketScreenTitle),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
                  padding: EdgeInsetsDirectional.only(start: 20, end: 20, top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localization.addNewTicketTitle,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.titleFocusNode,
                              isFocused: controller.isTitleFocused.value,
                              backgroundColor: AppColors.transparent,
                              controller: controller.titleController,
                              hintText: "",
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localization.addNewTicketDescription,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.descriptionFocusNode,
                              isFocused: controller.isDescriptionFocused.value,
                              backgroundColor: AppColors.transparent,
                              controller: controller.descriptionController,
                              keyboardType: TextInputType.text,
                              hintText: "",
                              maxLine: 4,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonLabelText(
                              text: localization.addNewTicketAttachments,
                              isRequired: false,
                            ),
                            GestureDetector(
                              onTap: () => controller.addAttachment(),
                              child: Container(
                                padding: EdgeInsets.all(3),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: AppColors.lightPrimary,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Image.asset(PngAssets.addCommonIcon),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Obx(
                          () => Column(
                            children: controller.attachments
                                .map(
                                  (id) => Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: _buildAttachmentItem(
                                      context,
                                      id,
                                      controller,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 40),
                        CommonButton(
                          onPressed: () async {
                            if (!controller.validateForm()) {
                              return;
                            }
                            await controller.addNewTicket();
                          },
                          width: double.infinity,

                          text: localization.addNewTicketAddButton,
                        ),
                        SizedBox(height: 50),
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
              child: CommonLoading(),
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
  ) {
    final localization = AppLocalizations.of(context)!;
    final MultipleImagePickerController multipleImagePickerController = Get.put(
      MultipleImagePickerController(),
    );

    return GestureDetector(
      onTap: () {
        showImageSourceSheet(id);
      },
      child: Obx(
        () => Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(PngAssets.attachFileTwo),
            if (multipleImagePickerController.images.containsKey(id))
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  multipleImagePickerController.images[id]!,
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            if (!multipleImagePickerController.images.containsKey(id))
              Column(
                children: [
                  Image.asset(
                    PngAssets.commonUploadIcon,
                    width: 20,
                    height: 20,
                    color: AppColors.lightTextTertiary,
                  ),
                  SizedBox(height: 5),
                  Text(
                    localization.addNewTicketAttachFile,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            if (controller.attachments.length > 1 ||
                multipleImagePickerController.images.containsKey(id))
              PositionedDirectional(
                top: 10,
                end: 10,
                child: GestureDetector(
                  onTap: () => controller.removeAttachment(id),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Image.asset(
                      PngAssets.closeCommonIcon,
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
