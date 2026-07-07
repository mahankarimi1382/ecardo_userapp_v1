import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/action_button_section.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/user_profile_section.dart';

class TopHeaderSection extends StatelessWidget {
  const TopHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(20),
                  bottomEnd: Radius.circular(20),
                ),
              ),
              child: UserProfileSection(),
            ),
            Container(
              margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(20),
                  bottomEnd: Radius.circular(20),
                ),
              ),
            ),
          ],
        ),
        ActionButtonSection(),
      ],
    );
  }
}
