import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';

import '../model/travel_model.dart';

class TravelController extends GetxController {
  static const String _apiBaseUrl = 'https://trip.ecardo.ir/api/v1';

  final Dio _client = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  final RxBool isBootstrapLoading = false.obs;
  final RxBool isSearchLoading = false.obs;
  final RxBool isOfferLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TravelServiceDefinition> services =
      <TravelServiceDefinition>[].obs;
  final RxList<TravelOffer> offers = <TravelOffer>[].obs;
  final RxMap<String, dynamic> facets = <String, dynamic>{}.obs;
  final Rxn<TravelOffer> selectedOffer = Rxn<TravelOffer>();
  String? _travelAccessToken;

  @override
  void onInit() {
    super.onInit();
    loadBootstrap();
  }

  Future<void> loadBootstrap() async {
    try {
      isBootstrapLoading.value = true;
      errorMessage.value = '';
      final response = await _client.get('/travel/bootstrap');
      final data = travelMap(travelMap(response.data)['data']);
      final rawServices = data['services'] as List? ?? const [];
      services.assignAll(
        rawServices
            .whereType<Map>()
            .map(
              (item) => TravelServiceDefinition.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((service) => service.key.isNotEmpty),
      );
    } on DioException catch (error) {
      errorMessage.value = _messageFor(
        error,
        'دریافت خدمات سفر امکان‌پذیر نیست.',
      );
    } finally {
      isBootstrapLoading.value = false;
    }
  }

  Future<bool> search(
    TravelServiceDefinition service,
    Map<String, dynamic> criteria,
  ) async {
    try {
      isSearchLoading.value = true;
      errorMessage.value = '';
      offers.clear();
      facets.clear();
      final response = await _client.post(
        '/travel/services/${service.key}/search',
        data: {'criteria': criteria},
      );
      final data = travelMap(travelMap(response.data)['data']);
      final rawOffers = data['offers'] as List? ?? const [];
      offers.assignAll(
        rawOffers.whereType<Map>().map(
          (item) => TravelOffer.fromJson(
            Map<String, dynamic>.from(item),
            service.key,
          ),
        ),
      );
      facets.assignAll(travelMap(data['facets']));
      return true;
    } on DioException catch (error) {
      errorMessage.value = _messageFor(
        error,
        'جستجوی سرویس با خطا روبه‌رو شد.',
      );
      return false;
    } finally {
      isSearchLoading.value = false;
    }
  }

  Future<TravelOffer?> loadOffer(
    TravelServiceDefinition service,
    TravelOffer offer,
  ) async {
    try {
      isOfferLoading.value = true;
      errorMessage.value = '';
      selectedOffer.value = offer;
      final response = await _client.get(
        '/travel/services/${service.key}/offers/${Uri.encodeComponent(offer.id)}',
      );
      final data = travelMap(travelMap(response.data)['data']);
      final rawOffer = travelMap(data['offer']);
      if (rawOffer.isNotEmpty) {
        selectedOffer.value = TravelOffer.fromJson(rawOffer, service.key);
      }
      return selectedOffer.value;
    } on DioException catch (error) {
      errorMessage.value = _messageFor(
        error,
        'دریافت جزئیات پیشنهاد امکان‌پذیر نیست.',
      );
      return null;
    } finally {
      isOfferLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> executeAction(TravelAction action) async {
    try {
      isActionLoading.value = true;
      errorMessage.value = '';
      if (!action.url.startsWith('/')) {
        errorMessage.value = 'آدرس عملیات سفر معتبر نیست.';
        return null;
      }
      final options = Options(method: action.method);
      if (action.requiresAuth) {
        final token = await _ensureTravelAccessToken();
        if (token == null) return null;
        options.headers = {'Authorization': 'Bearer $token'};
      }
      final response = action.method == 'GET'
          ? await _client.get(
              action.url,
              queryParameters: action.payload,
              options: options,
            )
          : await _client.request(
              action.url,
              data: action.payload,
              options: options,
            );
      return travelMap(response.data);
    } on DioException catch (error) {
      errorMessage.value = _messageFor(
        error,
        'انجام عملیات سفر امکان‌پذیر نیست.',
      );
      return null;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<String?> _ensureTravelAccessToken() async {
    if (_travelAccessToken?.isNotEmpty == true) return _travelAccessToken;
    if (!Get.isRegistered<TokenService>()) {
      errorMessage.value = 'برای ادامه، ابتدا وارد حساب کاربری شوید.';
      return null;
    }
    final sourceToken = Get.find<TokenService>().accessToken.value;
    if (sourceToken?.isNotEmpty != true) {
      errorMessage.value = 'برای ادامه، ابتدا وارد حساب کاربری شوید.';
      return null;
    }
    try {
      final response = await _client.post(
        '/auth/exchange',
        data: {'source_token': sourceToken},
      );
      final data = travelMap(travelMap(response.data)['data']);
      final token = data['token']?.toString();
      if (token?.isNotEmpty != true) {
        errorMessage.value = 'ورود به سرویس سفر تکمیل نشد.';
        return null;
      }
      _travelAccessToken = token;
      return token;
    } on DioException catch (error) {
      errorMessage.value = _messageFor(
        error,
        'ورود به سرویس سفر امکان‌پذیر نیست.',
      );
      return null;
    }
  }

  String _messageFor(DioException error, String fallback) {
    debugPrint(
      'Travel API error: ${error.requestOptions.uri} ${error.message}',
    );
    final root = travelMap(error.response?.data);
    final apiError = travelMap(root['error']);
    final message = apiError['message'] ?? root['message'];
    return message is String && message.trim().isNotEmpty ? message : fallback;
  }
}
