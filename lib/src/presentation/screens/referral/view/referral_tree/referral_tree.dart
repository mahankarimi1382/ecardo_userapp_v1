import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/referral/controller/referral_tree_controller.dart';
import 'package:qunzo_user/src/presentation/screens/referral/view/referral_tree/sub_sections/referral_tree_widget.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class NodeInfo {
  final GlobalKey key;
  final List<GlobalKey> childrenKeys;

  NodeInfo({required this.key, required this.childrenKeys});
}

class ReferralTree extends StatefulWidget {
  const ReferralTree({super.key});

  @override
  State<ReferralTree> createState() => _ReferralTreeState();
}

class _ReferralTreeState extends State<ReferralTree> {
  final ReferralTreeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonDefaultAppBar(backgroundColor: AppColors.white),
      body: Column(
        children: [
          const SizedBox(height: 16),
          CommonAppBar(title: localization.referralTreeScreenTitle),
          const SizedBox(height: 30),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CommonLoading();
              }
              if (controller.referralTreeModel.value.data!.children!.isEmpty) {
                return NoDataFound();
              }
              return ReferralTreeWidget(
                root: controller.referralTreeModel.value.data!,
              );
            }),
          ),
        ],
      ),
    );
  }
}
