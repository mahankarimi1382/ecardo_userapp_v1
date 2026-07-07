import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class WithdrawAccountController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isTransactionsLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isFilter = false.obs;
  final Rx<WithdrawAccountModel> withdrawAccountModel =
      WithdrawAccountModel().obs;

  // Method Name
  final RxBool isMethodNameFocused = false.obs;
  final FocusNode methodNameFocusNode = FocusNode();
  final methodNameController = TextEditingController();

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  @override
  void onInit() {
    super.onInit();
    methodNameFocusNode.addListener(() {
      isMethodNameFocused.value = methodNameFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    methodNameFocusNode.dispose();
    methodNameController.dispose();
    super.onClose();
  }

  // Fetch Withdraw Accounts From API
  Future<void> fetchWithdrawAccounts() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.withdrawAccountEndpoint}?page=$currentPage',
      );

      if (response.status == Status.completed) {
        withdrawAccountModel.value = WithdrawAccountModel.fromJson(
          response.data!,
        );
        if (withdrawAccountModel.value.data!.accounts!.length <
            withdrawAccountModel.value.data!.pagination!.perPage!) {
          hasMorePages.value = false;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWithdrawAccounts() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Dynamic Withdraw Accounts
  Future<void> fetchDynamicWithdrawAccounts() async {
    try {
      isTransactionsLoading.value = true;
      currentPage.value = 1;
      hasMorePages.value = true;

      final queryParams = <String>[];
      queryParams.add('page=${currentPage.value}');

      if (methodNameController.text.isNotEmpty) {
        queryParams.add(
          'keyword=${Uri.encodeComponent(methodNameController.text)}',
        );
      }

      final endpoint =
          '${ApiPath.withdrawAccountEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);

      if (response.status == Status.completed) {
        withdrawAccountModel.value = WithdrawAccountModel.fromJson(
          response.data!,
        );
        if (withdrawAccountModel.value.data!.accounts == null ||
            withdrawAccountModel.value.data!.accounts!.isEmpty) {
          withdrawAccountModel.value.data!.accounts = [];
          hasMorePages.value = false;
        } else if (withdrawAccountModel.value.data!.accounts!.length <
            withdrawAccountModel.value.data!.pagination!.perPage!) {
          hasMorePages.value = false;
        }
      } else {
        withdrawAccountModel.value.data!.accounts = [];
        hasMorePages.value = false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchDynamicWithdrawAccounts() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isTransactionsLoading.value = false;
      isFilter.value = false;
    }
  }

  // Fetch More Withdraw Accounts
  Future<void> loadMoreWithdrawAccounts() async {
    if (!hasMorePages.value || isPageLoading.value) return;
    isPageLoading.value = true;
    currentPage.value++;
    try {
      final queryParams = <String>[];
      queryParams.add('page=${currentPage.value}');

      if (methodNameController.text.isNotEmpty) {
        queryParams.add(
          'keyword=${Uri.encodeComponent(methodNameController.text)}',
        );
      }
      final endpoint =
          '${ApiPath.withdrawAccountEndpoint}?${queryParams.join('&')}';
      final response = await Get.find<NetworkService>().get(endpoint: endpoint);
      if (response.status == Status.completed) {
        final newTransactions = WithdrawAccountModel.fromJson(response.data!);

        if (newTransactions.data!.accounts!.isEmpty) {
          hasMorePages.value = false;
        } else {
          withdrawAccountModel.value.data!.accounts!.addAll(
            newTransactions.data!.accounts!,
          );
          withdrawAccountModel.refresh();
          if (newTransactions.data!.accounts!.length <
              withdrawAccountModel.value.data!.pagination!.perPage!) {
            hasMorePages.value = false;
          }
        }
      }
    } catch (e, stackTrace) {
      currentPage.value--;
      debugPrint('❌ loadMoreWithdrawAccounts() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isPageLoading.value = false;
    }
  }

  Future<void> deleteWithdrawAccount(String accountId) async {
    try {
      isLoading.value = true;
      final response = await Get.find<NetworkService>().delete(
        endpoint: '${ApiPath.withdrawAccountEndpoint}/$accountId',
      );

      if (response.status == Status.completed) {
        await fetchWithdrawAccounts();
        ToastHelper().showSuccessToast(response.data!['message']);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ deleteWithdrawAccount() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await fetchWithdrawAccounts();
    isLoading.value = false;
  }
}
