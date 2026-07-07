import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';

class SignUpBonusPopUp extends StatefulWidget {
  final String signUpBonus;

  const SignUpBonusPopUp({super.key, required this.signUpBonus});

  @override
  State<SignUpBonusPopUp> createState() => _SignUpBonusPopUpState();
}

class _SignUpBonusPopUpState extends State<SignUpBonusPopUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _moveAnimation = Tween<double>(
      begin: 30,
      end: -0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 320.w,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Image.asset(PngAssets.signupGiftFrame, fit: BoxFit.contain),
            AnimatedBuilder(
              animation: _moveAnimation,
              builder: (context, child) {
                return PositionedDirectional(
                  top: _moveAnimation.value,
                  child: Image.asset(PngAssets.signupGift, width: 180),
                );
              },
            ),

            Positioned(
              bottom: 20,
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Text(
                      localizations.signUpBonusCongratulations,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFA869FF),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      localizations.signUpBonusReceived,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      "${Get.find<SettingsService>().getSetting("currency_symbol")}${widget.signUpBonus}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFA869FF),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              top: -10,
              end: -10,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      PngAssets.closeCommonIcon,
                      width: 20,
                      height: 20,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
