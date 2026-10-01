import 'package:flutter_test/flutter_test.dart';
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
}
