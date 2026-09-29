import 'dart:io';
import 'package:dio/dio.dart' as dio;

/// Reusable helper for multipart uploads (Profile avatar, KYC documents, etc.)
class UploadHelper {
  /// Maximum avatar size: 2MB (aligned with Laravel validator max:2048).
  static const int maxAvatarBytes = 2 * 1024 * 1024;

  /// Maximum KYC document size: 5MB (aligned with ImageUploadTrait 5100000 bytes).
  static const int maxKycDocBytes = 5 * 1024 * 1024;

  /// Cleans and extracts the filename from a file path across platforms.
  static String extractFileName(String filePath) {
    if (filePath.isEmpty) return 'file.jpg';
    final segments = filePath.split(RegExp(r'[/\\]'));
    return segments.isNotEmpty ? segments.last : 'file.jpg';
  }

  /// Determines the appropriate [dio.DioMediaType] from filename/extension.
  static dio.DioMediaType getMediaType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return dio.DioMediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return dio.DioMediaType('image', 'jpeg');
    }
    if (lower.endsWith('.webp')) return dio.DioMediaType('image', 'webp');
    if (lower.endsWith('.gif')) return dio.DioMediaType('image', 'gif');
    if (lower.endsWith('.svg')) return dio.DioMediaType('image', 'svg+xml');
    if (lower.endsWith('.pdf')) return dio.DioMediaType('application', 'pdf');
    if (lower.endsWith('.doc')) return dio.DioMediaType('application', 'msword');
    if (lower.endsWith('.docx')) {
      return dio.DioMediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    }
    return dio.DioMediaType('application', 'octet-stream');
  }

  /// Checks if file exceeds maximum allowed bytes.
  static bool exceedsSize(File file, int maxBytes) {
    try {
      return file.lengthSync() > maxBytes;
    } catch (_) {
      return false;
    }
  }

  /// Creates a [dio.MultipartFile] with correct filename and contentType.
  static Future<dio.MultipartFile> createMultipartFile(
    File file, {
    String? customFileName,
  }) async {
    final fileName = customFileName ?? extractFileName(file.path);
    final contentType = getMediaType(fileName);

    return await dio.MultipartFile.fromFile(
      file.path,
      filename: fileName,
      contentType: contentType,
    );
  }
}
