import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Represents a user-uploaded hospital/blood test document (PDF or JPG/PNG).
class PickedLabDocument {
  const PickedLabDocument({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  bool get isPdf =>
      mimeType == 'application/pdf' ||
      fileName.toLowerCase().endsWith('.pdf');

  bool get isImage => mimeType.startsWith('image/');

  String get badgeLabel => isPdf ? 'PDF' : 'JPG/GÖRSEL';

  int get sizeKb => (bytes.length / 1024).ceil();
}

abstract class LabDocumentPicker {
  Future<PickedLabDocument?> pickPdfOrImage();
  Future<PickedLabDocument?> pickCameraPhoto();
}

class DeviceLabDocumentPicker implements LabDocumentPicker {
  const DeviceLabDocumentPicker();

  @override
  Future<PickedLabDocument?> pickPdfOrImage() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Kan Tahlili PDF veya JPG Seçin',
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (file == null) return null;

    final bytes = await file.xFile.readAsBytes();
    final ext = (file.extension ?? '').toLowerCase();
    final mimeType = switch (ext) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      _ => 'image/jpeg',
    };

    return PickedLabDocument(
      fileName: file.name,
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  @override
  Future<PickedLabDocument?> pickCameraPhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return null;
    final bytes = await photo.readAsBytes();
    return PickedLabDocument(
      fileName: photo.name,
      mimeType: 'image/jpeg',
      bytes: bytes,
    );
  }
}

/// Lightweight, 100% on-device pure-Dart PDF text extractor.
///
/// Extracts readable text from uncompressed and FlateDecode (zlib) PDF content
/// streams (such as exported e-Nabız or hospital digital lab PDFs) with zero
/// AI tokens. Returns an empty string cleanly for image-only scanned PDFs.
class PdfTextExtractor {
  PdfTextExtractor._();

  static String extractText(Uint8List pdfBytes) {
    if (pdfBytes.length < 8) return '';
    final raw = latin1.decode(pdfBytes, allowInvalid: true);
    if (!raw.contains('%PDF')) return '';

    final chunks = <String>[];
    final streamRegex = RegExp(r'stream\r?\n([\s\S]*?)\r?\nendstream');

    for (final match in streamRegex.allMatches(pdfBytes.isNotEmpty ? raw : '')) {
      final headerStart = (match.start - 200).clamp(0, raw.length);
      final dictHeader = raw.substring(headerStart, match.start);
      final isFlate = dictHeader.contains('/FlateDecode');

      final rawStreamStr = match.group(1) ?? '';
      String decodedStream = rawStreamStr;

      if (isFlate) {
        try {
          final compressed = latin1.encode(rawStreamStr);
          final inflated = zlib.decode(compressed);
          decodedStream = utf8.decode(inflated, allowMalformed: true);
        } catch (_) {
          // Some PDF streams use raw deflate or non-text image streams; skip safely.
          continue;
        }
      }

      final extracted = _extractPdfTextOperators(decodedStream);
      if (extracted.isNotEmpty) {
        chunks.add(extracted);
      }
    }

    // Fallback: also inspect top-level text operators if present outside streams.
    if (chunks.isEmpty) {
      final direct = _extractPdfTextOperators(raw);
      if (direct.isNotEmpty) chunks.add(direct);
    }

    return chunks.join('\n').trim();
  }

  static String _extractPdfTextOperators(String content) {
    final lines = <String>[];

    // Match simple `(text) Tj` or `(text) '` operators
    final tjRegex = RegExp(r'\(([^()\\]*(?:\\.[^()\\]*)*)\)\s*(?:Tj|\x27)');
    for (final m in tjRegex.allMatches(content)) {
      final decoded = _unescapePdfString(m.group(1) ?? '').trim();
      if (decoded.isNotEmpty) lines.add(decoded);
    }

    // Match array `[(text) -20 (more)] TJ` operators
    final tjArrayRegex = RegExp(r'\[([\s\S]*?)\]\s*TJ');
    final literalRegex = RegExp(r'\(([^()\\]*(?:\\.[^()\\]*)*)\)');
    for (final m in tjArrayRegex.allMatches(content)) {
      final inner = m.group(1) ?? '';
      final parts = <String>[];
      for (final lit in literalRegex.allMatches(inner)) {
        parts.add(_unescapePdfString(lit.group(1) ?? ''));
      }
      final joined = parts.join('').trim();
      if (joined.isNotEmpty) lines.add(joined);
    }

    return lines.join('\n');
  }

  static String _unescapePdfString(String s) {
    return s
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\n')
        .replaceAll(r'\t', ' ')
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\\', '\\');
  }
}
