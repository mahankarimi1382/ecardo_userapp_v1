import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/controller/transactions_controller.dart';

class TransactionTypeList extends StatefulWidget {
  const TransactionTypeList({super.key});

  @override
  State<TransactionTypeList> createState() => _TransactionTypeListState();
}

class _TransactionTypeListState extends State<TransactionTypeList> {
  final TransactionsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 18),
      separatorBuilder: (context, index) => SizedBox(width: 8),
      itemCount: controller.typesList.length,
      itemBuilder: (context, index) {
        final type = controller.typesList[index];

        return Obx(() {
          final isSelected = controller.selectedTypeIndex.value == index;

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              controller.selectedTypeIndex.value = index;
              controller.clearOtherFiltersOnTypeChange();
              if (index == 0) {
                controller.selectedType.value = "";
              } else {
                controller.selectedType.value = type;
              }
              controller.isFilter.value = true;
              await controller.fetchDynamicTransactions();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isSelected ? AppColors.lightPrimary : AppColors.white,
              ),
              child: Text(
                type,
                style: TextStyle(
                  letterSpacing: 0,
                  fontSize: 15,
                  color: isSelected
                      ? AppColors.white
                      : AppColors.lightTextTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
