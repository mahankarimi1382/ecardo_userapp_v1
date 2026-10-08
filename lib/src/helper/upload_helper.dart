import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

/// Reusable helper for multipart uploads (Profile avatar, KYC documents, etc.)
class UploadHelper {
  /// Maximum avatar size: 2MB (aligned with Laravel validator max:2048).
  static const int maxAvatarBytes = 2 * 1024 * 1024;

  /// Maximum KYC document size: 20MB. The server's ImageUploadTrait now
  /// accepts 20MB for KYC call sites (owner directive 2026-09-29 — camera
  /// photos kept failing the old 5MB cap), while other callers keep 5MB.
  static const int maxKycDocBytes = 20 * 1024 * 1024;

  /// Target maximum dimension for image compression (1080p equivalent).
  static const int maxTargetDimension = 1920;

  /// Compresses and downscales an image file to max [maxWidth]x[maxHeight]
  /// so uploads are fast, lean (<500KB), and never time out over slow networks.
  static Future<File> compressImageIfNeeded(
    File file, {
    int maxWidth = maxTargetDimension,
    int maxHeight = 1080,
  }) async {
    try {
      if (!file.existsSync()) return file;
      final fileLength = file.lengthSync();
      // If already under 400KB, no downscaling needed
      if (fileLength <= 400 * 1024) return file;

      final name = file.path.toLowerCase();
      final isImage = name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png') ||
          name.endsWith('.webp');
      if (!isImage) return file;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxWidth,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return file;

      final tempDir = Directory.systemTemp;
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_${extractFileName(file.path)}.png';
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(byteData.buffer.asUint8List());

      if (compressedFile.lengthSync() < fileLength) {
        debugPrint(
          '🗜️ [UploadHelper] Compressed image from ${(fileLength / 1024).toStringAsFixed(1)}KB to ${(compressedFile.lengthSync() / 1024).toStringAsFixed(1)}KB',
        );
        return compressedFile;
      }
      return file;
    } catch (e) {
      debugPrint('⚠️ [UploadHelper] Image compression fallback: $e');
      return file;
    }
  }

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
  /// Automatically compresses oversized images before creating the multipart.
  static Future<dio.MultipartFile> createMultipartFile(
    File file, {
    String? customFileName,
  }) async {
    final processedFile = await compressImageIfNeeded(file);
    final fileName = customFileName ?? extractFileName(processedFile.path);
    final contentType = getMediaType(fileName);

    return await dio.MultipartFile.fromFile(
      processedFile.path,
      filename: fileName,
      contentType: contentType,
    );
  }
}
