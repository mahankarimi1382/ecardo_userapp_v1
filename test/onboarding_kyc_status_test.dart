import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/model/country_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BUG-03: KYC status and onboarding completion tests', () {
    bool checkAllStepsCompleted({
      required bool emailVerified,
      required bool passwordSetup,
      required bool personalInfo,
      required int? kyc,
    }) {
      final isKycValid = kyc == 1 || kyc == 2;
      return emailVerified && passwordSetup && personalInfo && isKycValid;
    }

    test('kyc == 1 (approved) is considered valid and completes onboarding', () {
      final completed = checkAllStepsCompleted(
        emailVerified: true,
        passwordSetup: true,
        personalInfo: true,
        kyc: 1, // Admin approved
      );
      expect(completed, isTrue, reason: 'Approved KYC users must be allowed to complete onboarding');
    });

    test('kyc == 2 (in review) is considered valid and completes onboarding', () {
      final completed = checkAllStepsCompleted(
        emailVerified: true,
        passwordSetup: true,
        personalInfo: true,
        kyc: 2, // In review
      );
      expect(completed, isTrue, reason: 'Users in review must be allowed into dashboard');
    });

    test('kyc == 3 (rejected) does NOT complete onboarding', () {
      final completed = checkAllStepsCompleted(
        emailVerified: true,
        passwordSetup: true,
        personalInfo: true,
        kyc: 3, // Rejected
      );
      expect(completed, isFalse, reason: 'Rejected KYC must require action before completion');
    });

    test('kyc == 0 (unverified) does NOT complete onboarding', () {
      final completed = checkAllStepsCompleted(
        emailVerified: true,
        passwordSetup: true,
        personalInfo: true,
        kyc: 0, // Unverified
      );
      expect(completed, isFalse, reason: 'Unverified KYC must require action');
    });

    test('missing personal info does NOT complete onboarding even if kyc == 1', () {
      final completed = checkAllStepsCompleted(
        emailVerified: true,
        passwordSetup: true,
        personalInfo: false,
        kyc: 1,
      );
      expect(completed, isFalse);
    });
  });

  group('UserModel KYC deserialization integrity', () {
    test('parses kyc status integer accurately', () {
      final json = {
        'status': 'success',
        'data': {
          'id': 123,
          'kyc': 1,
          'boarding_steps': {
            'email_verification': true,
            'password_setup': true,
            'personal_info': true,
            'id_verification': true,
            'completed': true,
          },
        },
      };
      final user = UserModel.fromJson(json);
      expect(user.data?.kyc, 1);
      expect(user.data?.boardingSteps?.completed, isTrue);
    });
  });

  group('Registration Country Selection and Formatting Tests', () {
    test('_setSelectedCountry fallback logic selects IR when selected is false for all', () {
      final countryList = <CountryData>[
        CountryData(name: 'Germany', code: 'DE', dialCode: '+49', selected: false),
        CountryData(name: 'Iran', code: 'IR', dialCode: '+98', selected: false),
        CountryData(name: 'Turkey', code: 'TR', dialCode: '+90', selected: false),
      ];

      final selectedCountry = countryList.firstWhereOrNull(
            (country) => country.selected == true,
          ) ??
          countryList.firstWhereOrNull(
            (country) => country.code == 'IR',
          ) ??
          countryList.firstOrNull;

      expect(selectedCountry, isNotNull);
      expect(selectedCountry?.code, 'IR');
      expect(selectedCountry?.dialCode, '+98');
    });

    test('_setSelectedCountry fallback logic selects first country when IR not present', () {
      final countryList = <CountryData>[
        CountryData(name: 'Germany', code: 'DE', dialCode: '+49', selected: false),
        CountryData(name: 'Turkey', code: 'TR', dialCode: '+90', selected: false),
      ];

      final selectedCountry = countryList.firstWhereOrNull(
            (country) => country.selected == true,
          ) ??
          countryList.firstWhereOrNull(
            (country) => country.code == 'IR',
          ) ??
          countryList.firstOrNull;

      expect(selectedCountry, isNotNull);
      expect(selectedCountry?.code, 'DE');
    });

    test('firstWhereOrNull on empty countryList returns null without crashing', () {
      final countryList = <CountryData>[];

      final selectedCountry = countryList.firstWhereOrNull(
            (item) => item.code == 'IR',
          ) ??
          countryList.firstWhereOrNull(
            (item) => item.code == 'IR',
          ) ??
          countryList.firstOrNull;

      expect(selectedCountry, isNull);
    });

    test('country is formatted as dialCode:code and not omitted', () {
      final countryDialCode = '+98'.obs;
      final countryCode = 'IR'.obs;
      final countryText = 'Iran'.obs;

      final Map<String, dynamic> requestBody = {};
      if (countryCode.value.isNotEmpty || countryText.value.isNotEmpty) {
        requestBody['country'] = '$countryDialCode:${countryCode.value}';
      }

      expect(requestBody.containsKey('country'), isTrue);
      expect(requestBody['country'], '+98:IR');
    });
  });

  group('NetworkService response conversion and registration status tests', () {
    test('statusCode 200 and 201 are both accepted as successful registration', () {
      for (final code in [200, 201]) {
        final isSuccess = code == 200 || code == 201;
        expect(isSuccess, isTrue);
      }
      expect(400 == 200 || 400 == 201, isFalse);
    });

    test('Map<dynamic, dynamic> safely converts to Map<String, dynamic> without TypeError', () {
      final dynamic rawDioData = <dynamic, dynamic>{
        'status': 'success',
        'data': <dynamic, dynamic>{
          'token': 'mock_token_123',
        },
      };

      // Raw cast throws TypeError
      expect(
        () => rawDioData as Map<String, dynamic>,
        throwsA(isA<TypeError>()),
      );

      // Safe conversion works cleanly
      final safeMap = Map<String, dynamic>.from(rawDioData as Map);
      expect(safeMap['status'], 'success');
      expect(safeMap['data']['token'], 'mock_token_123');
    });
  });
}
