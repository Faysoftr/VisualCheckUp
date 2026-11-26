import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

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
      maxWidth: 1800,
      maxHeight: 2400,
      imageQuality: 88,
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

/// 100% on-device PDF text extractor supporting modern Turkish/Unicode CID
/// fonts (e-Nabız, hospital digital lab reports) via Syncfusion PDF.
///
/// Uses geometric `(x, y)` row reconstruction via `extractTextLines()` so
/// multi-column hospital tables (Test | Result | Unit | Reference) are ALWAYS
/// joined onto the exact same horizontal line regardless of internal PDF cell
/// drawing order.
class PdfTextExtractor {
  PdfTextExtractor._();

  static String extractText(Uint8List pdfBytes) {
    if (pdfBytes.length < 8) return '';

    try {
      final document = sf.PdfDocument(inputBytes: pdfBytes);
      try {
        final extractor = sf.PdfTextExtractor(document);

        // 1. Best for hospital tables: reconstruct each page row-by-row using
        //    bounding box Y-coordinates and sort cells left-to-right by X.
        final geometric = _extractGeometricRows(document, extractor);
        if (geometric.isNotEmpty) {
          return geometric;
        }

        // 2. Secondary: Syncfusion layoutText / plain text.
        final layoutText = extractor.extractText(layoutText: true).trim();
        if (layoutText.isNotEmpty) {
          return layoutText;
        }
        final plainText = extractor.extractText().trim();
        if (plainText.isNotEmpty) {
          return plainText;
        }
      } finally {
        document.dispose();
      }
    } catch (_) {
      // Fall through to lightweight stream parser for non-standard/minimal PDFs.
    }

    return _extractWithLightweightFallback(pdfBytes);
  }

  static String _extractGeometricRows(
    sf.PdfDocument document,
    sf.PdfTextExtractor extractor,
  ) {
    final pageBuffers = <String>[];
    final pageCount = document.pages.count;

    for (var pageIdx = 0; pageIdx < pageCount; pageIdx++) {
      final lines = extractor.extractTextLines(
        startPageIndex: pageIdx,
        endPageIndex: pageIdx,
      );
      if (lines.isEmpty) continue;

      // Sort all text fragments top-to-bottom, then left-to-right.
      final sorted = [...lines]..sort((a, b) {
          final dy = a.bounds.top - b.bounds.top;
          if (dy.abs() > 2.0) return dy.compareTo(0);
          return a.bounds.left.compareTo(b.bounds.left);
        });

      // Group fragments whose vertical centers fall on the same table row.
      final rows = <List<sf.TextLine>>[];
      for (final item in sorted) {
        final text = item.text.trim();
        if (text.isEmpty) continue;

        final itemMidY = item.bounds.top + (item.bounds.height / 2);
        List<sf.TextLine>? targetRow;

        for (var i = rows.length - 1; i >= 0; i--) {
          final row = rows[i];
          final ref = row.first;
          final refMidY = ref.bounds.top + (ref.bounds.height / 2);
          final tolerance = (ref.bounds.height * 0.65).clamp(4.0, 12.0);
          if ((itemMidY - refMidY).abs() <= tolerance) {
            targetRow = row;
            break;
          }
          if (itemMidY - refMidY > 18.0) break;
        }

        if (targetRow != null) {
          targetRow.add(item);
        } else {
          rows.add([item]);
        }
      }

      final pageLines = <String>[];
      for (final row in rows) {
        row.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
        final joined = row
            .map((e) => e.text.replaceAll(RegExp(r'\s+'), ' ').trim())
            .where((t) => t.isNotEmpty)
            .join('  ');
        if (joined.isNotEmpty) {
          pageLines.add(joined);
        }
      }

      if (pageLines.isNotEmpty) {
        pageBuffers.add(pageLines.join('\n'));
      }
    }

    return pageBuffers.join('\n').trim();
  }

  static String _extractWithLightweightFallback(Uint8List pdfBytes) {
    final raw = latin1.decode(pdfBytes, allowInvalid: true);
    if (!raw.contains('%PDF')) return '';

    final chunks = <String>[];
    final streamRegex = RegExp(r'stream\r?\n([\s\S]*?)\r?\nendstream');

    for (final match in streamRegex.allMatches(raw)) {
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
          continue;
        }
      }

      final extracted = _extractPdfTextOperators(decodedStream);
      if (extracted.isNotEmpty) {
        chunks.add(extracted);
      }
    }

    if (chunks.isEmpty) {
      final direct = _extractPdfTextOperators(raw);
      if (direct.isNotEmpty) chunks.add(direct);
    }

    return chunks.join('\n').trim();
  }

  static String _extractPdfTextOperators(String content) {
    final lines = <String>[];

    final tjRegex = RegExp(r'\(([^()\\]*(?:\\.[^()\\]*)*)\)\s*(?:Tj|\x27)');
    for (final m in tjRegex.allMatches(content)) {
      final decoded = _unescapePdfString(m.group(1) ?? '').trim();
      if (decoded.isNotEmpty) lines.add(decoded);
    }

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
