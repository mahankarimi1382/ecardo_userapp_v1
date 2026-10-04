import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/referral/model/referred_friends_model.dart';

class ReferredFriendsController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
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
    isError.value = false;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.referralFriendsEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final referredFriendsModel = ReferredFriendsModel.fromJson(
          response.data!,
        );
        referredFriendsList.clear();
        if (referredFriendsModel.data != null) {
          referredFriendsList.assignAll(referredFriendsModel.data!);
        }
      } else {
        isError.value = true;
      }
    } catch (e, stackTrace) {
      isError.value = true;
      debugPrint('❌ fetchReferredFriends() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        ToastHelper().showErrorToast(
          AppLocalizations.of(ctx)!.allControllerLoadError,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
