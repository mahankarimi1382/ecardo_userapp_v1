import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/controller/create_ad_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/widgets/create_ad_eligibility_failed_section.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/widgets/create_ad_placeholder_section.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final CreateAdController controller = Get.put(CreateAdController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isEligibilityLoading.value) {
          return const CommonLoading();
        }

        return Stack(
          children: [
            if (controller.isEligibleToCreateAd.value)
              CreateAdPlaceholderSection(controller: controller)
            else
              CreateAdEligibilityFailedSection(
                reasons: controller.eligibilityReasons,
              ),
            if (controller.isCreateAdLoading.value) const CommonLoading(),
          ],
        );
      },
    );
  }
}
