import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_header_section.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_history_section.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_list_section.dart';

import '../../../../app/constants/app_colors.dart';

class GiftCardScreen extends StatefulWidget {
  const GiftCardScreen({super.key});

  @override
  State<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends State<GiftCardScreen> {
  final GiftCardController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.clearInitialData();
    controller.initGiftCardFilterDefaults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, AppColors.lightBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.26, 0.31],
          ),
        ),
        child: Column(
          children: [
            GiftCardHeaderSection(),
            Obx(
              () => controller.selectedScreen.value == 0
                  ? GiftCardListSection()
                  : controller.selectedScreen.value == 1
                  ? GiftCardHistorySection()
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
