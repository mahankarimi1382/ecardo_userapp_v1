import 'package:flutter/material.dart';

class Responsive {
  static double pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return 12;
    if (w < 390) return 14;
    if (w < 414) return 16;
    return 18;
  }

  static double cardRadius(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w < 360 ? 14 : 16;
  }

  static double sectionGap(BuildContext context) => 20;
}
