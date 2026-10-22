import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/model/device_session_model.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/pulsing_indicator.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/visual_pin_dots_indicator.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/this_device_hero_card.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/other_session_card.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/terminate_all_button.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget wrapWithScreenUtil(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('DeviceSessionItem & DeviceOs Model Tests', () {
    test('DeviceSessionItem properties and copyWith', () {
      final now = DateTime.now();
      final item = DeviceSessionItem(
        id: 'sess_1',
        deviceName: 'Pixel 8 Pro',
        deviceType: DeviceFormFactor.phone,
        os: DeviceOs.android,
        operatingSystem: 'Android 14',
        browser: 'Ecardo App v1.0.41',
        appVersion: 'v1.0.41 (Build 41)',
        ipAddress: '192.168.1.10',
        location: 'Tehran, Iran',
        loginTimestamp: now.subtract(const Duration(hours: 1)),
        lastActive: now,
        isCurrentDevice: true,
      );

      expect(item.id, 'sess_1');
      expect(item.deviceName, 'Pixel 8 Pro');
      expect(item.deviceType, DeviceFormFactor.phone);
      expect(item.os, DeviceOs.android);
      expect(item.icon, Icons.phone_android_rounded);
      expect(item.os.icon, Icons.android_rounded);
      expect(item.isCurrentDevice, isTrue);

      final updated = item.copyWith(
        deviceName: 'Samsung S24 Ultra',
        ipAddress: '10.0.0.1',
      );
      expect(updated.deviceName, 'Samsung S24 Ultra');
      expect(updated.ipAddress, '10.0.0.1');
      expect(updated.id, 'sess_1');
    });

    test('DeviceOs returns dedicated icons and brand colors', () {
      expect(DeviceOs.android.icon, Icons.android_rounded);
      expect(DeviceOs.ios.icon, Icons.apple);
      expect(DeviceOs.windows.icon, Icons.window_rounded);
      expect(DeviceOs.macos.icon, Icons.laptop_mac_rounded);
      expect(DeviceOs.linux.icon, Icons.terminal_rounded);
      expect(DeviceOs.web.icon, Icons.language_rounded);

      expect(DeviceOs.android.brandColor, isNotNull);
      expect(DeviceOs.windows.brandColor, isNotNull);
    });

    test(
      'DeviceSessionItem.icon resolves specific icons for phone, iphone, and desktop',
      () {
        final androidPhone = DeviceSessionItem(
          id: '1',
          deviceName: 'Pixel 8',
          deviceType: DeviceFormFactor.phone,
          os: DeviceOs.android,
          operatingSystem: 'Android 14',
          browser: 'App',
          ipAddress: '1.1.1.1',
          location: 'Tehran',
          loginTimestamp: DateTime.now(),
          lastActive: DateTime.now(),
        );
        expect(androidPhone.icon, Icons.phone_android_rounded);

        final iphone = DeviceSessionItem(
          id: '2',
          deviceName: 'iPhone 15 Pro',
          deviceType: DeviceFormFactor.phone,
          os: DeviceOs.ios,
          operatingSystem: 'iOS 17',
          browser: 'App',
          ipAddress: '1.1.1.1',
          location: 'Tehran',
          loginTimestamp: DateTime.now(),
          lastActive: DateTime.now(),
        );
        expect(iphone.icon, Icons.phone_iphone_rounded);

        final desktop = DeviceSessionItem(
          id: '3',
          deviceName: 'MacBook Pro',
          deviceType: DeviceFormFactor.desktop,
          os: DeviceOs.macos,
          operatingSystem: 'macOS 14',
          browser: 'Chrome',
          ipAddress: '1.1.1.1',
          location: 'Tehran',
          loginTimestamp: DateTime.now(),
          lastActive: DateTime.now(),
        );
        expect(desktop.icon, Icons.laptop_mac_rounded);
      },
    );
  });

  group('VisualPinDotsIndicator Widget Tests', () {
    testWidgets('renders 4 dots correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          const VisualPinDotsIndicator(
            length: 4,
            filledCount: 2,
            isDark: false,
          ),
        ),
      );

      expect(find.byType(VisualPinDotsIndicator), findsOneWidget);
    });

    testWidgets('renders 6 dots correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          const VisualPinDotsIndicator(length: 6, filledCount: 4, isDark: true),
        ),
      );

      expect(find.byType(VisualPinDotsIndicator), findsOneWidget);
    });

    testWidgets('compact mode renders configured and unconfigured dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          Row(
            children: [
              VisualPinDotsIndicator.compact(
                length: 4,
                isConfigured: true,
                isDark: false,
              ),
              VisualPinDotsIndicator.compact(
                length: 6,
                isConfigured: false,
                isDark: true,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(Row), findsWidgets);
    });
  });

  group('PulsingIndicator Widget Tests', () {
    testWidgets('renders pulsing beacon without exceptions', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          const PulsingIndicator(color: Colors.green, size: 10),
        ),
      );

      expect(find.byType(PulsingIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('ThisDeviceHeroCard Widget Tests', () {
    testWidgets('renders hero card with device details and IP', (tester) async {
      final now = DateTime.now();
      final device = DeviceSessionItem(
        id: 'sess_hero',
        deviceName: 'Samsung Galaxy S24 Ultra',
        deviceType: DeviceFormFactor.phone,
        os: DeviceOs.android,
        operatingSystem: 'Android 14 (One UI 6.1)',
        browser: 'Ecardo App v1.0.41',
        appVersion: 'v1.0.41 (41)',
        ipAddress: '5.127.189.42',
        location: 'تهران، ایران',
        loginTimestamp: now.subtract(const Duration(hours: 2)),
        lastActive: now,
        isCurrentDevice: true,
      );

      await tester.pumpWidget(
        wrapWithScreenUtil(ThisDeviceHeroCard(device: device, isDark: false)),
      );

      expect(find.text('Samsung Galaxy S24 Ultra'), findsOneWidget);
      expect(find.textContaining('5.127.189.42'), findsOneWidget);
      expect(find.text('تهران، ایران'), findsOneWidget);
      expect(find.byType(PulsingIndicator), findsOneWidget);
    });
  });

  group('OtherSessionCard Widget Tests', () {
    testWidgets('renders active session card and fires onRevoke', (
      tester,
    ) async {
      bool revoked = false;
      final session = DeviceSessionItem(
        id: 'sess_other',
        deviceName: 'Chrome در Windows 11',
        deviceType: DeviceFormFactor.desktop,
        os: DeviceOs.windows,
        operatingSystem: 'Windows 11 Pro',
        browser: 'Google Chrome 128.0',
        ipAddress: '185.192.112.5',
        location: 'تهران، ایران',
        loginTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        isCurrentDevice: false,
      );

      await tester.pumpWidget(
        wrapWithScreenUtil(
          OtherSessionCard(
            session: session,
            isDark: false,
            onRevoke: () => revoked = true,
          ),
        ),
      );

      expect(find.text('Chrome در Windows 11'), findsOneWidget);
      expect(find.textContaining('185.192.112.5'), findsOneWidget);

      final revokeButton = find.byType(OutlinedButton);
      expect(revokeButton, findsOneWidget);
      await tester.tap(revokeButton);
      expect(revoked, isTrue);
    });
  });

  group('TerminateAllButton Widget Tests', () {
    testWidgets('triggers callback when sessions count > 0', (tester) async {
      bool terminated = false;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          TerminateAllButton(
            otherCount: 3,
            isDark: false,
            onTerminateAll: () => terminated = true,
          ),
        ),
      );

      expect(find.byType(TerminateAllButton), findsOneWidget);
      final emergencyBtn = find.byType(ElevatedButton);
      expect(emergencyBtn, findsOneWidget);

      await tester.tap(emergencyBtn);
      expect(terminated, isTrue);
    });

    testWidgets('disables button when sessions count == 0', (tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          TerminateAllButton(
            otherCount: 0,
            isDark: true,
            onTerminateAll: () {},
          ),
        ),
      );

      final emergencyBtn = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(emergencyBtn.onPressed, isNull);
    });
  });
}
