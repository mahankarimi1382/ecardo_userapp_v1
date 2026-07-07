import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/notifications_model.dart';

class NotificationController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isNotificationsLoading = false.obs;
  final Rx<NotificationsModel> notificationModel = NotificationsModel().obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  // Fetch Notifications From API
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.getNotificationsEndpoint}?for=user&page=${currentPage.value}',
      );

      if (response.status == Status.completed) {
        notificationModel.value = NotificationsModel.fromJson(response.data!);
        if (notificationModel.value.data!.notifications!.length <
            notificationModel.value.data!.meta!.perPage!) {
          hasMorePages.value = false;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchNotifications() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch More Notifications
  Future<void> loadMoreNotifications() async {
    if (!hasMorePages.value || isPageLoading.value) return;
    isPageLoading.value = true;
    currentPage.value++;

    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.getNotificationsEndpoint}?for=user&page=${currentPage.value}',
      );

      if (response.status == Status.completed) {
        final newNotifications = NotificationsModel.fromJson(response.data!);

        if (newNotifications.data!.notifications!.isEmpty) {
          hasMorePages.value = false;
        } else {
          notificationModel.value.data!.notifications!.addAll(
            newNotifications.data!.notifications!,
          );
          notificationModel.refresh();
          if (newNotifications.data!.notifications!.length <
              notificationModel.value.data!.meta!.perPage!) {
            hasMorePages.value = false;
          }
        }
      }
    } catch (e, stackTrace) {
      currentPage.value--;
      debugPrint('❌ loadMoreNotifications() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isPageLoading.value = false;
    }
  }

  // Mark As Read Notification
  Future<void> markAsReadNotification() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: "${ApiPath.markAsReadNotificationEndpoint}?for=user",
      );
      if (response.status == Status.completed) {
        await fetchNotifications();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ markAsReadNotification() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
