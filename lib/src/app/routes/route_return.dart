import 'package:get/get.dart';

import 'routes.dart';

class RouteReturn {
  static String? get requestedRoute {
    final arguments = Get.arguments;
    if (arguments is! Map) return null;
    final route = arguments['returnRoute']?.toString();
    return route?.isNotEmpty == true ? route : null;
  }

  static void complete({String fallbackRoute = BaseRoute.navigation}) {
    final route = requestedRoute;
    if (Get.key.currentState?.canPop() == true) {
      Get.back();
      return;
    }
    Get.offNamed(route ?? fallbackRoute);
  }
}
