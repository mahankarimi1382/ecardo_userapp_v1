import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

class _FakeSettingsService extends SettingsService {
  @override
  Future<bool> saveEmailVerified(bool value) async => true;

  @override
  Future<bool> saveSetUpPassword(bool value) async => true;

  @override
  Future<bool> saveLoginCurrentState(String state) async => true;

  @override
  Future<bool> saveLoggedInUserEmail(String email) async => true;

  @override
  Future<bool> clearLoggedInUserPassword() async => true;
}

class _FakeTokenService extends TokenService {
  @override
  void onInit() {
    super.onInit();
    accessToken.value = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<SettingsService>(_FakeSettingsService());
    Get.put<TokenService>(_FakeTokenService());
  });

  tearDown(() {
    Get.reset();
  });

  group('SignInController - profile fetch resilience and state', () {
    test('hasPendingProfileFetch starts false and resets on field edits', () {
      final controller = SignInController();
      expect(controller.hasPendingProfileFetch.value, isFalse);

      controller.hasPendingProfileFetch.value = true;
      expect(controller.hasPendingProfileFetch.value, isTrue);

      controller.onEmailChanged('user@ecardo.ir');
      expect(controller.hasPendingProfileFetch.value, isFalse);

      controller.hasPendingProfileFetch.value = true;
      controller.onPasswordChanged('new_pass');
      expect(controller.hasPendingProfileFetch.value, isFalse);

      controller.hasPendingProfileFetch.value = true;
      controller.resetFields();
      expect(controller.hasPendingProfileFetch.value, isFalse);

      controller.dispose();
    });
  });
}
