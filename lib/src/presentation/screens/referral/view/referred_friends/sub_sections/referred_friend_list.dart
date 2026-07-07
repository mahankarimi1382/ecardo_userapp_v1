import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/referral/controller/referred_friends_controller.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class ReferredFriendList extends StatelessWidget {
  const ReferredFriendList({super.key});

  @override
  Widget build(BuildContext context) {
    final ReferredFriendsController controller = Get.find();
    final localization = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(30),
          topEnd: Radius.circular(30),
        ),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return CommonLoading(isColorShow: false);
        }

        if (controller.referredFriendsList.isEmpty) {
          return NoDataFound();
        }

        return ListView.separated(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
          itemBuilder: (context, index) {
            final referred = controller.referredFriendsList[index];
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      referred.avatar ?? "",
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          PngAssets.commonErrorIcon,
                          color: AppColors.error.withValues(alpha: 0.7),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          referred.username ?? "",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${localization.referredFriendListJoinedOn} ${DateFormat('dd MMM yyyy').format(DateTime.parse(referred.createdAt!))}",
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color:
                          (referred.status == true
                                  ? AppColors.success
                                  : AppColors.error)
                              .withValues(alpha: 0.10),
                    ),
                    child: Text(
                      referred.status == true
                          ? localization.referredFriendListActive
                          : localization.referredFriendListInactive,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: referred.status == true
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
                height: 0,
              ),
            );
          },
          itemCount: controller.referredFriendsList.length,
        );
      }),
    );
  }
}
