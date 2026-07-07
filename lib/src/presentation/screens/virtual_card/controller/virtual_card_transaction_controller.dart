import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_transaction_model.dart';

class VirtualCardTransactionController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxList<CardTransactionData> cardTransactionList =
      <CardTransactionData>[].obs;

  // Fetch Card Transactions
  Future<void> fetchCardTransactions({required String cardId}) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.getCardTransactionEndpoint}/$cardId",
      );
      if (response.status == Status.completed) {
        final cardTransactionModel = CardTransactionModel.fromJson(
          response.data!,
        );
        cardTransactionList.clear();
        cardTransactionList.assignAll(cardTransactionModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCardTransactions() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Card Transactions By Sync
  Future<void> fetchCardTransactionsBySync({
    required String cardId,
    required String isSync,
  }) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.getCardTransactionEndpoint}/$cardId?sync=$isSync",
      );
      if (response.status == Status.completed) {
        final cardTransactionModel = CardTransactionModel.fromJson(
          response.data!,
        );
        cardTransactionList.clear();
        cardTransactionList.assignAll(cardTransactionModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCardTransactionsBySync() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
