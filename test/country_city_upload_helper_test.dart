import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/helper/country_city_helper.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';

void main() {
  group('CountryCityHelper Tests', () {
    test('Returns correct cities for Iran by country code', () {
      final cities = CountryCityHelper.getCities('IR');
      expect(cities, isNotEmpty);
      expect(cities, contains('Tehran'));
      expect(cities, contains('Mashhad'));
      expect(cities, contains('Isfahan'));
      expect(cities, contains('Shiraz'));
      expect(cities, contains('Tabriz'));
    });

    test('Returns correct cities for Turkey', () {
      final cities = CountryCityHelper.getCities('TR');
      expect(cities, isNotEmpty);
      expect(cities, contains('Istanbul'));
      expect(cities, contains('Ankara'));
    });

    test('Returns correct cities for UAE', () {
      final cities = CountryCityHelper.getCities('AE');
      expect(cities, isNotEmpty);
      expect(cities, contains('Dubai'));
      expect(cities, contains('Abu Dhabi'));
    });

    test('Returns correct cities by country name fallback', () {
      final cities = CountryCityHelper.getCities('', countryName: 'Iran, Islamic Republic of');
      expect(cities, isNotEmpty);
      expect(cities, contains('Tehran'));
    });

    test('Returns empty list for null or empty input', () {
      expect(CountryCityHelper.getCities(null), isEmpty);
      expect(CountryCityHelper.getCities(''), isEmpty);
      expect(CountryCityHelper.getCities('XYZ_NON_EXISTENT'), isEmpty);
    });
  });

  group('UploadHelper Tests', () {
    test('extractFileName handles unix and windows paths', () {
      expect(UploadHelper.extractFileName('/home/user/images/avatar.jpg'), equals('avatar.jpg'));
      expect(UploadHelper.extractFileName(r'C:\Users\Lenovo\Pictures\photo.png'), equals('photo.png'));
      expect(UploadHelper.extractFileName('simple_name.webp'), equals('simple_name.webp'));
      expect(UploadHelper.extractFileName(''), equals('file.jpg'));
    });

    test('getMediaType returns correct mime type', () {
      expect(UploadHelper.getMediaType('avatar.jpg').mimeType, equals('image/jpeg'));
      expect(UploadHelper.getMediaType('photo.png').mimeType, equals('image/png'));
      expect(UploadHelper.getMediaType('doc.pdf').mimeType, equals('application/pdf'));
      expect(UploadHelper.getMediaType('image.webp').mimeType, equals('image/webp'));
      expect(UploadHelper.getMediaType('unknown.xyz').mimeType, equals('application/octet-stream'));
    });
  });
}
