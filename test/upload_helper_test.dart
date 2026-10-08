import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';

void main() {
  test('UploadHelper extractFileName and getMediaType', () {
    expect(UploadHelper.extractFileName('/tmp/my_photo.jpg'), 'my_photo.jpg');
    expect(UploadHelper.extractFileName(r'C:\docs\id.png'), 'id.png');
    expect(UploadHelper.getMediaType('photo.jpg').mimeType, 'image/jpeg');
    expect(UploadHelper.getMediaType('doc.pdf').mimeType, 'application/pdf');
  });

  test('UploadHelper compressImageIfNeeded handles small and large images', () async {
    // Generate a dummy PNG image
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 200, 200), ui.Paint()..color = const ui.Color(0xFF123456));
    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    final tempFile = File('${Directory.systemTemp.path}/test_img.png');
    await tempFile.writeAsBytes(byteData!.buffer.asUint8List());

    final compressed = await UploadHelper.compressImageIfNeeded(tempFile);
    expect(compressed.existsSync(), isTrue);

    await tempFile.delete();
    if (compressed.path != tempFile.path && compressed.existsSync()) {
      await compressed.delete();
    }
  });
}
