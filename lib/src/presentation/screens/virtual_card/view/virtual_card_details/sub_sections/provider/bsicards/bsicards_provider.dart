import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/bsicards/bsicards_card_details_info.dart';

import 'bsicards_virtual_card.dart';

class BsicardsProvider extends StatelessWidget {
  const BsicardsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30.h),
        const BsicardsVirtualCard(),
        SizedBox(height: 30.h),
        const BsicardsCardDetailsInfo(),
        SizedBox(height: 30.h),
      ],
    );
  }
}
