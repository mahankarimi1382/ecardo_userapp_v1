import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/model/create_ad_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/widgets/create_ad_success_section.dart';

class CreateAdSuccessScreen extends StatelessWidget {
  final Data? adData;

  const CreateAdSuccessScreen({super.key, required this.adData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: CreateAdSuccessSection(adData: adData),
        ),
      ),
    );
  }
}
