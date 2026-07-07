import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/apply_verification/controller/apply_verification_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/apply_verification/widgets/apply_verification_placeholder_section.dart';

class ApplyVerificationScreen extends StatefulWidget {
  const ApplyVerificationScreen({super.key});

  @override
  State<ApplyVerificationScreen> createState() =>
      _ApplyVerificationScreenState();
}

class _ApplyVerificationScreenState extends State<ApplyVerificationScreen> {
  final ApplyVerificationController controller = Get.put(
    ApplyVerificationController(),
  );

  @override
  Widget build(BuildContext context) {
    return ApplyVerificationPlaceholderSection(controller: controller);
  }
}
