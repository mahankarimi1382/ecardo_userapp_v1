// kyc_file_reader_stub.dart — web stub (no dart:io)
// This file is used when dart:io is not available (web platform)

import 'dart:typed_data';

class KycFileReader {
  static Future<Uint8List?> readBytes(String path) async {
    // On web, we can't read files from path
    // File uploads on web should use html.File or XFile directly
    return null;
  }
}
