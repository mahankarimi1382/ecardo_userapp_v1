import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/controller/airtime_controller.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/view/airtime/sub_sections/airtime_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/view/airtime/sub_sections/airtime_review_step_section.dart';

class Airtime extends StatefulWidget {
  const Airtime({super.key});

  @override
  State<Airtime> createState() => _AirtimeState();
}

class _AirtimeState extends State<Airtime> {
  final AirtimeController controller = Get.find();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    controller.currentStep.value == 0;
    await controller.fetchBillCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Obx(
                () => Visibility(
                  visible:
                      controller.currentStep.value == 0 ||
                      controller.currentStep.value == 1,
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      CommonAppBar(
                        title: AppLocalizations.of(context)!.airtimeAppBarTitle,
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
              Obx(
                () => controller.currentStep.value == 0
                    ? AirtimeAmountStepSection()
                    : controller.currentStep.value == 1
                    ? AirtimeReviewStepSection()
                    : SizedBox(),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible:
                  controller.isPayBillServiceLoading.value ||
                  controller.isSubmitLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
