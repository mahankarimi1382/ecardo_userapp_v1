import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';

void main() {
  group('P0 Resilience — Passcode State Machine & Loop Prevention Invariants', () {
    test(
      'isPasscodeRequired returns true when error requires passcode and none was provided',
      () {
        expect(
          PasscodeHelper.isPasscodeRequired(
            'PASSCODE_REQUIRED',
            wasPasscodeProvided: false,
          ),
          isTrue,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'Transaction passcode is required',
            wasPasscodeProvided: false,
          ),
          isTrue,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'رمز عبور معامله الزامی است',
            wasPasscodeProvided: false,
          ),
          isTrue,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'HTTP 422: missing passcode parameter',
            wasPasscodeProvided: false,
          ),
          isTrue,
        );
      },
    );

    test(
      'CRITICAL INVARIANT: wasPasscodeProvided=true NEVER returns true (prevents infinite loop)',
      () {
        // Even if error string contains "passcode" or "PASSCODE_REQUIRED", once a passcode
        // has been submitted, isPasscodeRequired MUST be false to stop prompt/retry loops.
        expect(
          PasscodeHelper.isPasscodeRequired(
            'PASSCODE_REQUIRED',
            wasPasscodeProvided: true,
          ),
          isFalse,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'Transaction passcode is required',
            wasPasscodeProvided: true,
          ),
          isFalse,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'The passcode is incorrect',
            wasPasscodeProvided: true,
          ),
          isFalse,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            '422 Unprocessable: passcode error',
            wasPasscodeProvided: true,
          ),
          isFalse,
        );
      },
    );

    test(
      'isPasscodeRequired returns false for invalid/incorrect passcode messages',
      () {
        expect(
          PasscodeHelper.isPasscodeRequired(
            'PASSCODE_INVALID',
            wasPasscodeProvided: false,
          ),
          isFalse,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'The passcode is invalid',
            wasPasscodeProvided: false,
          ),
          isFalse,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'رمز وارد شده اشتباه است',
            wasPasscodeProvided: false,
          ),
          isFalse,
        );
        expect(
          PasscodeHelper.isPasscodeRequired(
            'Passcode is locked due to multiple attempts',
            wasPasscodeProvided: false,
          ),
          isFalse,
        );
      },
    );

    test(
      'isPasscodeInvalid correctly identifies invalid/wrong passcode signals',
      () {
        expect(PasscodeHelper.isPasscodeInvalid('PASSCODE_INVALID'), isTrue);
        expect(
          PasscodeHelper.isPasscodeInvalid('The passcode is incorrect'),
          isTrue,
        );
        expect(
          PasscodeHelper.isPasscodeInvalid('رمز عبور معامله اشتباه است'),
          isTrue,
        );
        expect(PasscodeHelper.isPasscodeInvalid('PASSCODE_REQUIRED'), isFalse);
        expect(PasscodeHelper.isPasscodeInvalid('Network timeout'), isFalse);
      },
    );

    test('isPasscodeLocked correctly identifies account lockouts', () {
      expect(PasscodeHelper.isPasscodeLocked('PASSCODE_LOCKED'), isTrue);
      expect(
        PasscodeHelper.isPasscodeLocked('Passcode has been locked'),
        isTrue,
      );
      expect(PasscodeHelper.isPasscodeLocked('رمز معامله مسدود شد'), isTrue);
      expect(PasscodeHelper.isPasscodeLocked('PASSCODE_INVALID'), isFalse);
    });

    test(
      'PasscodeHelper format validation and normalization handles Persian digits',
      () {
        expect(PasscodeHelper.isValidFormat('1234'), isTrue);
        expect(PasscodeHelper.isValidFormat('123456'), isTrue);
        expect(PasscodeHelper.isValidFormat('123'), isFalse); // < 4 digits
        expect(PasscodeHelper.isValidFormat('1234567890123'), isFalse); // > max
        expect(PasscodeHelper.isValidFormat('12a4'), isFalse); // non-digit

        // Persian digit normalization
        final normalized = PasscodeHelper.normalize('۱۲۳۴');
        expect(normalized, equals('1234'));
        expect(PasscodeHelper.isValidFormat(normalized), isTrue);
      },
    );
  });
}
