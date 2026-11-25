import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';

/// User-facing upload error for community avatar & chat image uploads.
class CommunityUploadException implements Exception {
  const CommunityUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Result of an uploaded community image (Cloudflare R2 public URL + object key,
/// or local file URI fallback in offline/demo mode).
class CommunityUploadResult {
  const CommunityUploadResult({
    required this.url,
    required this.objectKey,
    this.isLocalFallback = false,
  });

  final String url;
  final String objectKey;
  final bool isLocalFallback;
}

/// Abstraction for uploading profile avatars and chat images.
abstract class CommunityImageUploadService {
  Future<CommunityUploadResult> uploadBytes(
    Uint8List rawBytes, {
    required String folder,
    String fileExtension = '.jpg',
  });
}

/// Zero-client-secret Cloudflare R2 Presigned URL uploader adapted for
/// VisualCheckUp:
/// 1. Automatically fixes EXIF orientation and compresses images under 1 MB
///    in a background isolate.
/// 2. Calls VisualCheckUp's `getR2UploadUrl` Firebase Cloud Function to obtain
///    a short-lived presigned PUT URL (server enforces auth, 1 MB cap, and rate
///    limiting).
/// 3. Streams bytes directly to Cloudflare R2 via HTTP PUT.
/// 4. When running offline or without Firebase Functions deployed, optionally
///    persists the compressed image locally so preview/demo flows still work.
class R2CommunityImageUploadService implements CommunityImageUploadService {
  R2CommunityImageUploadService._();

  static final R2CommunityImageUploadService instance =
      R2CommunityImageUploadService._();

  /// Maximum allowed upload size (1 MB ceiling matching Cloud Function).
  static const int maxFileSizeBytes = 1 * 1024 * 1024;

  static Future<Uint8List> ensureImageUnderLimit(Uint8List rawBytes) async {
    if (rawBytes.lengthInBytes <= maxFileSizeBytes) {
      return rawBytes;
    }
    return compute(_compressImageBytes, rawBytes);
  }

  static Uint8List _compressImageBytes(Uint8List rawBytes) {
    try {
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) return rawBytes;

      final oriented = img.bakeOrientation(decoded);
      int quality = 85;
      int maxDimension = 1600;

      img.Image current = oriented;
      if (current.width > maxDimension || current.height > maxDimension) {
        current = img.copyResize(
          current,
          width: current.width >= current.height ? maxDimension : null,
          height: current.height > current.width ? maxDimension : null,
          interpolation: img.Interpolation.linear,
        );
      }

      var encoded = Uint8List.fromList(img.encodeJpg(current, quality: quality));

      while (encoded.lengthInBytes > maxFileSizeBytes && quality > 40) {
        quality -= 15;
        if (quality <= 55 && (current.width > 1280 || current.height > 1280)) {
          maxDimension = 1280;
          current = img.copyResize(
            current,
            width: current.width >= current.height ? maxDimension : null,
            height: current.height > current.width ? maxDimension : null,
            interpolation: img.Interpolation.linear,
          );
        }
        encoded = Uint8List.fromList(img.encodeJpg(current, quality: quality));
      }

      return encoded;
    } catch (_) {
      return rawBytes;
    }
  }

  @override
  Future<CommunityUploadResult> uploadBytes(
    Uint8List rawBytes, {
    required String folder,
    String fileExtension = '.jpg',
  }) async {
    final safety = ContentSafetyService.validateImageBytes(rawBytes);
    if (!safety.isSafe) {
      throw const CommunityUploadException(
        'Image failed safety validation and could not be uploaded.',
      );
    }

    final compressed = await ensureImageUnderLimit(rawBytes);
    final sizeBytes = compressed.lengthInBytes;
    if (sizeBytes > maxFileSizeBytes) {
      throw CommunityUploadException(
        'Image exceeds 1 MB limit (${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB).',
      );
    }

    final normalizedExt = compressed.lengthInBytes != rawBytes.lengthInBytes
        ? '.jpg'
        : fileExtension.toLowerCase();
    final contentType = _contentTypeFor(normalizedExt);

    // Attempt production Cloudflare R2 presigned upload when Firebase is active
    if (Firebase.apps.isNotEmpty) {
      try {
        final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
            .httpsCallable('getR2UploadUrl');
        final result = await callable.call<dynamic>(<String, dynamic>{
          'contentType': contentType,
          'sizeBytes': sizeBytes,
          'folder': folder,
        });
        final data = Map<String, dynamic>.from(result.data as Map);
        final uploadUrl = data['uploadUrl'] as String;
        final publicUrl = data['publicUrl'] as String;
        final key = data['key'] as String;

        final response = await http.put(
          Uri.parse(uploadUrl),
          headers: {'Content-Type': contentType},
          body: compressed,
        );
        if (response.statusCode == 200) {
          final remoteSafety =
              await ContentSafetyService.moderateImageServerSide(
            imageUrl: publicUrl,
            objectKey: key,
          );
          if (!remoteSafety.isSafe) {
            throw const CommunityUploadException(
              'Image was rejected by automated safety moderation.',
            );
          }
          return CommunityUploadResult(url: publicUrl, objectKey: key);
        }
        throw CommunityUploadException(
          'R2 upload failed (HTTP ${response.statusCode}).',
        );
      } on FirebaseFunctionsException catch (e) {
        if (e.code == 'resource-exhausted' || e.code == 'invalid-argument') {
          throw CommunityUploadException(
            e.message ?? 'Image upload rejected by server.',
          );
        }
        // Fall back to local storage when functions are not yet deployed.
      } on CommunityUploadException {
        rethrow;
      } catch (_) {
        // Fall through to local persistence in offline/unconfigured environments.
      }
    }

    return _saveLocalFallback(
      compressed,
      folder: folder,
      extension: normalizedExt,
    );
  }

  Future<CommunityUploadResult> _saveLocalFallback(
    Uint8List bytes, {
    required String folder,
    required String extension,
  }) async {
    final safeFolder = folder.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    final fileName =
        '${safeFolder.isEmpty ? 'community' : safeFolder}_${DateTime.now().microsecondsSinceEpoch}$extension';
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/community_uploads');
      if (!targetDir.existsSync()) {
        await targetDir.create(recursive: true);
      }
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return CommunityUploadResult(
        url: file.path,
        objectKey: 'local/$fileName',
        isLocalFallback: true,
      );
    } catch (_) {
      return CommunityUploadResult(
        url: 'memory://$fileName',
        objectKey: 'local/$fileName',
        isLocalFallback: true,
      );
    }
  }

  static String _contentTypeFor(String ext) {
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

/// Deterministic test uploader returning a mock R2 URL without touching network.
class MockCommunityImageUploadService implements CommunityImageUploadService {
  int uploadCount = 0;

  @override
  Future<CommunityUploadResult> uploadBytes(
    Uint8List rawBytes, {
    required String folder,
    String fileExtension = '.jpg',
  }) async {
    uploadCount++;
    final key = '$folder/mock_$uploadCount$fileExtension';
    return CommunityUploadResult(
      url: 'https://cdn.visualcheckup.test/$key',
      objectKey: key,
    );
  }
}
