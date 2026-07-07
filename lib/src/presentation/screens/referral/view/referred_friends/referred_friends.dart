import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/presentation/screens/referral/controller/referred_friends_controller.dart';
import 'package:qunzo_user/src/presentation/screens/referral/view/referred_friends/sub_sections/referred_friend_list.dart';

class ReferredFriends extends StatefulWidget {
  const ReferredFriends({super.key});

  @override
  State<ReferredFriends> createState() => _ReferredFriendsState();
}

class _ReferredFriendsState extends State<ReferredFriends> {
  final ReferredFriendsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16),
          CommonAppBar(title: localization.referredFriendsScreenTitle),
          SizedBox(height: 30),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.lightPrimary,
              onRefresh: () => controller.fetchReferredFriends(),
              child: ReferredFriendList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 40),
        child: SizedBox(
          height: 48,
          width: 130,
          child: FloatingActionButton(
            heroTag: null,
            elevation: 0,
            onPressed: () {
              Get.toNamed(BaseRoute.referralTree);
            },
            backgroundColor: AppColors.lightPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              localization.referredFriendsScreenReferralTreeButton,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
