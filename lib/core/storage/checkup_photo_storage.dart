import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Stores captured checkup photos privately inside the app's documents folder
/// (never exposed to the device's public photo gallery) for Before/After
/// visual comparison and doctor review.
class CheckupPhotoStorage {
  CheckupPhotoStorage._();

  static Future<String?> savePhoto({
    required String resultId,
    required Uint8List imageBytes,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${dir.path}${Platform.pathSeparator}checkup_photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      // Downscale slightly so storage stays lightweight while preserving detail.
      Uint8List bytesToWrite = imageBytes;
      final decoded = img.decodeImage(imageBytes);
      if (decoded != null) {
        final resized = decoded.width > 800 || decoded.height > 800
            ? img.copyResize(
                decoded,
                width: decoded.width >= decoded.height ? 800 : null,
                height: decoded.height > decoded.width ? 800 : null,
              )
            : decoded;
        bytesToWrite = Uint8List.fromList(img.encodeJpg(resized, quality: 84));
      }

      final safeId = resultId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final file = File('${photosDir.path}${Platform.pathSeparator}$safeId.jpg');
      await file.writeAsBytes(bytesToWrite, flush: true);
      return file.path;
    } catch (_) {
      // Gracefully skip on test hosts without platform path_provider plugin.
      return null;
    }
  }

  static Future<void> deletePhoto(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup errors.
    }
  }
}
