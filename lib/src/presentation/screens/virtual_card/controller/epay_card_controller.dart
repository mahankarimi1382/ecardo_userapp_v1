import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

/// WAVE-REVIEW (بازبینی مالک): کارت‌های PayCardo — تتر شارژ می‌شود، دلار
/// خرج می‌رود. سرور API کامل دارد (`/api/epay/*`) ولی اپ تا now هیچ UIای
/// نداشت؛ این کنترلر + سکشن My Cards آن را زنده می‌کند.
class EpayCardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxList<Map<String, dynamic>> epayCards = <Map<String, dynamic>>[].obs;

  String _pick({
    required String en,
    required String fa,
    String? ar,
    String? zh,
  }) {
    final ctx = Get.context;
    if (ctx == null) return en;
    return l10nPick(ctx, en: en, fa: fa, ar: ar, zh: zh);
  }

  Future<void> fetchEpayCards() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.epayCardsEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final list = response.data!['data'];
        epayCards.assignAll(
          (list is List ? list : [])
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m)),
        );
      }
    } catch (e) {
      // WAVE-REVIEW: state stays as-is; the section shows the retry button.
    } finally {
      isLoading.value = false;
    }
  }

  /// صدور کارت جدید (هزینه صدور از کیف USDT/USD کاربر کسر می‌شود).
  Future<void> issueCard() async {
    isActionLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.epayIssueEndpoint,
        data: {'payment_method': 'wallet'},
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(_pick(
          en: 'PayCardo card issued successfully',
          fa: 'کارت PayCardo با موفقیت صادر شد',
          ar: 'تم إصدار بطاقة PayCardo بنجاح',
          zh: 'PayCardo 卡发行成功',
        ));
        await fetchEpayCards();
      }
    } catch (e) {
      // Server error envelope is toasted by NetworkService.
    } finally {
      isActionLoading.value = false;
    }
  }

  /// شارژ کارت فعال (۲٪ کارمزد سمت سرور؛ از کیف USDT/USD کاربر).
  Future<void> topUpCard(double amount) async {
    if (amount < 1) {
      ToastHelper().showErrorToast(_pick(
        en: 'Minimum top-up is \$1',
        fa: 'حداقل شارژ ۱ دلار است',
        ar: 'الحد الأدنى للشحن ١ دولار',
        zh: '最低充值 1 美元',
      ));
      return;
    }
    isActionLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.epayTopupEndpoint,
        data: {'amount': amount},
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(_pick(
          en: 'Card topped up successfully (2% fee)',
          fa: 'شارژ موفق — کارمزد ۲٪ کسر شد',
          ar: 'تم الشحن بنجاح (رسوم ٢٪)',
          zh: '充值成功（2% 手续费）',
        ));
        await fetchEpayCards();
      }
    } catch (e) {
      // Server error envelope is toasted by NetworkService.
    } finally {
      isActionLoading.value = false;
    }
  }
}
