// kyc_file_reader_io.dart — mobile implementation (uses dart:io)
// This file is used when dart:io is available (mobile/desktop platforms)

import 'dart:io';
import 'dart:typed_data';

class KycFileReader {
  static Future<Uint8List?> readBytes(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (_) {}
    return null;
  }
}
