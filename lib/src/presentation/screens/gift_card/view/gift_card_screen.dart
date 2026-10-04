import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_header_section.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_history_section.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_list_section.dart';

class GiftCardScreen extends StatefulWidget {
  const GiftCardScreen({super.key});

  @override
  State<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends State<GiftCardScreen> {
  final GiftCardController controller = Get.find<GiftCardController>();

  @override
  void initState() {
    super.initState();
    controller.clearInitialData();
    controller.initGiftCardFilterDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkBackground]
                : [AppColors.white, AppColors.lightBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.26, 0.31],
          ),
        ),
        child: Column(
          children: [
            const GiftCardHeaderSection(),
            Obx(
              () => controller.selectedScreen.value == 0
                  ? const GiftCardListSection()
                  : controller.selectedScreen.value == 1
                  ? const GiftCardHistorySection()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
