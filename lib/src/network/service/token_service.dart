import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService extends GetxService {
  static const String accessTokenKey = 'access_token';

  final Rx<String?> accessToken = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadAccessToken();
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken.value = prefs.getString(accessTokenKey);
  }

  Future<bool> saveAccessToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken.value = token;
    return await prefs.setString(accessTokenKey, token);
  }

  Future<bool> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken.value = null;
    await prefs.remove(accessTokenKey);
    return true;
  }
}
