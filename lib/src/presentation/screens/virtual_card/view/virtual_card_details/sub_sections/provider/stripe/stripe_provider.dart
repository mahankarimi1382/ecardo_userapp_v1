import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/stripe/stripe_card_details_info.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/stripe/stripe_virtual_card.dart';

class StripeProvider extends StatelessWidget {
  const StripeProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30.h),
        const StripeVirtualCard(),
        SizedBox(height: 30.h),
        const StripeCardDetailsInfo(),
        SizedBox(height: 30.h),
      ],
    );
  }
}
