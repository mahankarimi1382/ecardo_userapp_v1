import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class TravelersScreen extends StatelessWidget {
  const TravelersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    return TravelPage(
      title: localization.travelSavedTravelers,
      trailing: Padding(
        padding: EdgeInsetsDirectional.only(end: 14.w),
        child: IconButton(
          onPressed: () => _showTravelerEditor(context, controller),
          icon: const Icon(Icons.person_add_alt_1_rounded),
        ),
      ),
      child: Obx(
        () => controller.travelers.isEmpty
            ? TravelEmptyState(message: localization.travelNoTravelers)
            : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: controller.travelers.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final traveler = controller.travelers[index];
                  return TravelCard(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFEAF3FF),
                          child: Icon(
                            Icons.person_rounded,
                            color: TravelTheme.blue,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  traveler.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  '${traveler.nationalityCode} • ${_maskedPassport(traveler.passportNumber)}',
                                  style: TextStyle(
                                    color: TravelTheme.muted,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showTravelerEditor(
                            context,
                            controller,
                            traveler: traveler,
                          ),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _maskedPassport(String value) {
    if (value.length <= 3) return value;
    return '${value.substring(0, 1)}•••••${value.substring(value.length - 3)}';
  }

  Future<void> _showTravelerEditor(
    BuildContext context,
    TravelController controller, {
    TravelTraveler? traveler,
  }) async {
    final localization = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: traveler?.fullName);
    final passportController = TextEditingController(
      text: traveler?.passportNumber,
    );
    final nationalityController = TextEditingController(
      text: traveler?.nationalityCode ?? 'IR',
    );
    // The travel service requires both dates when saving a traveler
    // (passport_expiry after +6 months, birth_date before -1 year). They were
    // never collected, so the save could never succeed.
    final passportExpiry = Rxn<DateTime>(traveler?.passportExpiry);
    final birthDate = Rxn<DateTime>(traveler?.birthDate);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            20.w,
            22.h,
            20.w,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  traveler == null
                      ? localization.travelAddTraveler
                      : localization.travelEditTraveler,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 18.h),
                CommonTextInputField(
                  controller: nameController,
                  hintText: localization.travelTravelerFullName,
                  validator: (value) => value?.trim().isEmpty == false
                      ? null
                      : localization.travelFieldRequired,
                ),
                SizedBox(height: 12.h),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: CommonTextInputField(
                    controller: passportController,
                    hintText: localization.travelPassportNumber,
                    validator: (value) => value?.trim().isEmpty == false
                        ? null
                        : localization.travelFieldRequired,
                  ),
                ),
                SizedBox(height: 12.h),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: CommonTextInputField(
                    controller: nationalityController,
                    hintText: localization.travelNationalityCode,
                    validator: (value) => value?.trim().length == 2
                        ? null
                        : localization.travelNationalityCodeInvalid,
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(
                  () => Directionality(
                    textDirection: TextDirection.ltr,
                    child: CommonSingleDatePicker(
                      hintText: localization.travelBirthDate,
                      initialDate: birthDate.value,
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      isFocused: false,
                      datePattern: 'yyyy-MM-dd',
                      onDateSelected: (value) => birthDate.value = value,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(
                  () => Directionality(
                    textDirection: TextDirection.ltr,
                    child: CommonSingleDatePicker(
                      hintText: localization.travelPassportExpiry,
                      initialDate: passportExpiry.value,
                      firstDate: DateTime.now().add(const Duration(days: 180)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
                      isFocused: false,
                      datePattern: 'yyyy-MM-dd',
                      onDateSelected: (value) => passportExpiry.value = value,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Obx(
                  () => CommonButton(
                    width: double.infinity,
                    text: localization.travelSaveTraveler,
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      if (formKey.currentState?.validate() != true) {
                        return;
                      }
                      // Both dates are mandatory server-side; check here so the
                      // user gets the local field error instead of a 422.
                      if (birthDate.value == null ||
                          passportExpiry.value == null) {
                        ToastHelper().showErrorToast(
                          localization.travelFieldRequired,
                        );
                        return;
                      }
                      await controller.saveTraveler(
                        TravelTraveler(
                          id: traveler?.id ?? '',
                          fullName: nameController.text.trim(),
                          passportNumber: passportController.text
                              .trim()
                              .toUpperCase(),
                          nationalityCode: nationalityController.text
                              .trim()
                              .toUpperCase(),
                          birthDate: birthDate.value,
                          passportExpiry: passportExpiry.value,
                        ),
                      );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    nameController.dispose();
    passportController.dispose();
    nationalityController.dispose();
  }
}
