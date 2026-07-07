import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/view/sub_sections/payment_links_create_section.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/view/sub_sections/payment_links_header_section.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/view/sub_sections/payment_links_list_section.dart';

import '../../../../app/constants/app_colors.dart';

class PaymentLinksScreen extends StatefulWidget {
  const PaymentLinksScreen({super.key});

  @override
  State<PaymentLinksScreen> createState() => _PaymentLinksScreenState();
}

class _PaymentLinksScreenState extends State<PaymentLinksScreen> {
  final PaymentLinksController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.clearFields();
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
            PaymentLinksHeaderSection(),
            Obx(
              () => controller.selectedScreen.value == 0
                  ? PaymentLinksListSection()
                  : controller.selectedScreen.value == 1
                  ? PaymentLinksCreateSection()
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
