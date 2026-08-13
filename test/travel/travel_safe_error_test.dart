import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

void main() {
  group('travelSafeErrorMessage', () {
    test('does not expose raw exceptions', () {
      final message = travelSafeErrorMessage(
        StateError('database password leaked'),
      );

      expect(message, travelGenericErrorMessage);
      expect(message, isNot(contains('database password leaked')));
    });

    test('keeps safe request references from Dio responses', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/travel/bootstrap'),
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/travel/bootstrap'),
          data: const {
            'error': {'message': 'provider failed', 'request_id': 'req-123'},
          },
        ),
      );

      expect(
        travelSafeErrorMessage(error),
        '$travelGenericErrorMessage Reference: req-123',
      );
    });

    test('handles empty nested response maps without recursion', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/travel'),
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/travel'),
          data: {'error': <String, dynamic>{}, 'data': null},
        ),
      );

      expect(travelSafeErrorMessage(error), travelGenericErrorMessage);
    });
  });

  group('travelSafePresentationMessage', () {
    test('leaves normal frontend copy unchanged', () {
      expect(
        travelSafePresentationMessage('Please check your travel details.'),
        'Please check your travel details.',
      );
    });

    test('replaces raw exception text and preserves reference', () {
      expect(
        travelSafePresentationMessage(
          'DioException [bad response]: {"message":"boom","trace_id":"trc-9"}',
        ),
        '$travelGenericErrorMessage Reference: trc-9',
      );
    });
  });
}
