import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/card_holder_tab_section.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/choose_card_holder_section.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/choose_card_provider_section.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/create_new_card_holder_section.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/irr_card_order_section.dart';

class CreateVirtualCard extends StatefulWidget {
  const CreateVirtualCard({super.key});

  @override
  State<CreateVirtualCard> createState() => _CreateVirtualCardState();
}

class _CreateVirtualCardState extends State<CreateVirtualCard> {
  final CreateVirtualCardController controller = Get.find();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    controller.selectedTab.value = true;
    controller.isLoading.value = true;
    await Future.wait([
      controller.fetchCardProducts(),
      controller.fetchCardProviders(),
      controller.fetchCountries(),
    ]);
    if (controller.cardProducts.isNotEmpty) await controller.fetchIrrWallets();
    controller.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16.h),
              CommonAppBar(
                title: AppLocalizations.of(
                  context,
                )!.createVirtualCardAppBarTitle,
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CommonLoading();
                  }

                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(30.r),
                        topEnd: Radius.circular(30.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CommonLoading()
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 16.h),
                                  if (controller.cardProducts.isNotEmpty) ...[
                                    const CreateNewCardHolderSection(
                                      showSubmitButton: false,
                                    ),
                                    SizedBox(height: 20.h),
                                    const IrrCardOrderSection(),
                                    const Divider(),
                                    SizedBox(height: 20.h),
                                  ],
                                  ChooseCardProviderSection(),
                                  SizedBox(height: 16.h),
                                  CardHolderTabSection(),
                                  SizedBox(height: 16.h),
                                  controller.selectedTab.value == true
                                      ? ChooseCardHolderSection()
                                      : CreateNewCardHolderSection(),
                                ],
                              ),
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isCardHolderLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
