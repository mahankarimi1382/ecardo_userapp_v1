import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

class WalletDetailsController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Wallets> walletsList = <Wallets>[].obs;
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final Rx<TransactionsModel> transactionsModel = TransactionsModel().obs;

  // Pagination Variables
  final RxList<Transactions> allTransactions = <Transactions>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 15.obs;
  final RxBool hasMoreData = true.obs;

  // Wallet
  final RxString walletName = "".obs;
  final RxString walletIcon = "".obs;
  final RxString walletId = "".obs;

  @override
  void onInit() {
    super.onInit();
    resetPagination();
  }

  void resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    allTransactions.clear();
  }

  // Fetch Wallets
  Future<void> fetchWallets({required int id}) async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsList.clear();
        walletsList.value = walletsModel.data!.wallets ?? [];
        final selectedWallet = walletsList.firstWhere((w) => w.id == id);
        wallet.value = selectedWallet;
        walletName.value = wallet.value!.name ?? "";
        walletIcon.value = (wallet.value!.isDefault == true
            ? wallet.value!.symbol
            : wallet.value!.icon)!;
        walletId.value = wallet.value!.id.toString();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  // Fetch Transactions
  Future<void> fetchTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      resetPagination();
    }

    if (!hasMoreData.value && !isRefresh) return;

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            "${ApiPath.transactionsEndpoint}?wallet_id=${walletId.value == "0" ? "default" : walletId.value}&page=${currentPage.value}&per_page=${perPage.value}",
      );

      if (response.status == Status.completed) {
        final newTransactionsModel = TransactionsModel.fromJson(response.data!);
        final newTransactions = newTransactionsModel.data?.transactions ?? [];

        if (isRefresh) {
          allTransactions.clear();
        }
        allTransactions.addAll(newTransactions);
        transactionsModel.value = newTransactionsModel;
        if (newTransactions.length < perPage.value) {
          hasMoreData.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchTransactions() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more transactions
  Future<void> loadMoreTransactions() async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchTransactions();
    }
  }
}
