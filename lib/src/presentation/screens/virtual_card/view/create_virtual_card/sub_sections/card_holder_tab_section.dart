import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/model/country_model.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_holder_model.dart';

class CardHolderTabSection extends StatelessWidget {
  const CardHolderTabSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateVirtualCardController controller = Get.find();
    final localization = AppLocalizations.of(context);

    return Obx(
      () => Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                borderRadius: 12,
                onPressed: () {
                  controller.selectedTab.value = true;
                  controller.nameController.clear();
                  controller.emailController.clear();
                  controller.phoneNumberController.clear();
                  controller.countryController.clear();
                  controller.selectedCountry.value = CountryData();
                  controller.cityController.clear();
                  controller.stateController.clear();
                  controller.postalCodeController.clear();
                  controller.addressController.clear();
                },
                width: double.infinity,
                text: localization!.cardHolderTabExistingCardholders,
                fontSize: 12,
                backgroundColor: controller.selectedTab.value == true
                    ? AppColors.lightPrimary
                    : AppColors.white,
                textColor: controller.selectedTab.value == true
                    ? AppColors.white
                    : AppColors.lightTextPrimary.withValues(alpha: 0.8),
                height: 42,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CommonButton(
                borderRadius: 12,
                onPressed: () {
                  controller.selectedTab.value = false;
                  controller.cardHolderController.clear();
                  controller.selectedCardHolder.value = CardHolderData();
                },
                width: double.infinity,
                height: 42,
                text: localization.cardHolderTabCreateCardholder,
                fontSize: 12,
                backgroundColor: controller.selectedTab.value == false
                    ? AppColors.lightPrimary
                    : AppColors.white,
                textColor: controller.selectedTab.value == false
                    ? AppColors.white
                    : AppColors.lightTextPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
