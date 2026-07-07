import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/referral/model/referred_friends_model.dart';

class ReferredFriendsController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxList<ReferredFriendsData> referredFriendsList =
      <ReferredFriendsData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReferredFriends();
  }

  // Fetch Referred Friends
  Future<void> fetchReferredFriends() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.referralFriendsEndpoint,
      );
      if (response.status == Status.completed) {
        final referredFriendsModel = ReferredFriendsModel.fromJson(
          response.data!,
        );
        referredFriendsList.clear();
        referredFriendsList.assignAll(referredFriendsModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchReferredFriends() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
