import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';

void main() {
  group('AppUpdateController.isTrustedUpdateUrl', () {
    test('accepts direct APK assets from approved GitHub release repositories', () {
      expect(
        AppUpdateController.isTrustedUpdateUrl(
          'https://github.com/mahankarimi1382/ecardo-apps-releases/'
          'releases/download/userapp-v1.0.89/ecardo_user_v1.0.89.apk',
        ),
        isTrue,
      );
    });

    test('rejects look-alikes, redirectors, non-APK assets and query URLs', () {
      final untrustedUrls = [
        'https://github.com.evil.example/mahankarimi1382/ecardo-apps-releases/'
            'releases/download/v1.0.89/ecardo_user_v1.0.89.apk',
        'https://github.com/mahankarimi1382/other/releases/download/'
            'v1.0.89/ecardo_user_v1.0.89.apk',
        'https://github.com/mahankarimi1382/ecardo-apps-releases/'
            'releases/download/v1.0.89/release-notes.txt',
        'https://github.com/mahankarimi1382/ecardo-apps-releases/'
            'releases/download/v1.0.89/ecardo_user_v1.0.89.apk?redirect=1',
        'http://github.com/mahankarimi1382/ecardo-apps-releases/'
            'releases/download/v1.0.89/ecardo_user_v1.0.89.apk',
      ];

      for (final url in untrustedUrls) {
        expect(AppUpdateController.isTrustedUpdateUrl(url), isFalse);
      }
    });
  });
}
