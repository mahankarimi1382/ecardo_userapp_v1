import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/controller/auth_id_verification_controller.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/model/user_kyc_model.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/camera_type_section.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/file_type_section.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/front_camera_type_section.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class AuthIdVerificationScreen extends StatefulWidget {
  const AuthIdVerificationScreen({super.key});

  @override
  State<AuthIdVerificationScreen> createState() =>
      _AuthIdVerificationScreenState();
}

class _AuthIdVerificationScreenState extends State<AuthIdVerificationScreen> {
  final AuthIdVerificationController controller = Get.find();
  final String kycId = Get.arguments["kyc_id"] ?? "";
  final List<Fields> fields = (Get.arguments["fields"] as List<Fields>?) ?? [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.kycId.value = kycId;
      controller.fields.value = fields;
      controller.currentFieldIndex.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Obx(() {
        if (fields.isEmpty) {
          return NoDataFound();
        }

        if (controller.currentFieldIndex.value < 0 ||
            controller.currentFieldIndex.value >= fields.length) {
          return SizedBox.shrink();
        }

        final currentField = fields[controller.currentFieldIndex.value];
        return _buildFieldScreen(currentField);
      }),
    );
  }

  Widget _buildFieldScreen(Fields field) {
    final localizations = AppLocalizations.of(context)!;

    if (field.type == null) {
      return Center(
        child: Text(localizations.authIdVerificationInvalidFieldType),
      );
    }

    switch (field.type!.toLowerCase()) {
      case 'camera':
        return CameraTypeSection(field: field);
      case 'file':
        return FileTypeSection(field: field);
      case 'front_camera':
        return FrontCameraTypeSection(field: field);
      default:
        return Center(
          child: Text(
            "${localizations.authIdVerificationUnknownFieldType} ${field.type}",
          ),
        );
    }
  }
}
