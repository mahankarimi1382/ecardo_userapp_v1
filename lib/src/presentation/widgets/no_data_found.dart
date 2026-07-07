import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Image.asset(PngAssets.noDataFoundImage, width: 350));
  }
}
