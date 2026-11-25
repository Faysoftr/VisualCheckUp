import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:visualcheckup/core/ai/gemini_vision_ai_client.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_document_picker.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';

class AiLabExtractionResult {
  const AiLabExtractionResult({
    required this.items,
    this.detectedDate,
    this.hospitalName,
  });

  final List<LabTestItem> items;
  final DateTime? detectedDate;
  final String? hospitalName;
}

/// Abstract contract so widget/unit tests can inject a fake extractor.
abstract class LabDocumentAiExtractor {
  bool get isAvailable;

  Future<AiLabExtractionResult> extractFromDocument(PickedLabDocument document);
}

/// Universal hospital report reader powered by Gemini 2.5 Flash.
///
/// Sends PDF (`application/pdf`) or photo (`image/jpeg`, `image/png`) directly
/// to Gemini so ANY hospital format, layout, or language can be parsed into
/// structured [LabTestItem] rows with value, unit, and hospital reference range.
class GeminiLabReportExtractor implements LabDocumentAiExtractor {
  GeminiLabReportExtractor({
    String? apiKey,
    http.Client? httpClient,
  })  : _apiKey = (apiKey ?? GeminiVisionAiClient.envApiKey).trim(),
        _httpClient = httpClient ?? http.Client();

  final String _apiKey;
  final http.Client _httpClient;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  bool get isAvailable => _apiKey.isNotEmpty;

  @override
  Future<AiLabExtractionResult> extractFromDocument(
    PickedLabDocument document,
  ) async {
    if (!isAvailable) {
      throw StateError('GEMINI_API_KEY is not configured.');
    }

    final rawJson = await _callGemini(
      bytes: document.bytes,
      mimeType: document.mimeType,
    );
    return parseAiJson(rawJson);
  }

  Future<String> _callGemini({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    const models = ['gemini-2.5-flash', 'gemini-2.5-flash-lite'];
    Object? lastError;

    for (final model in models) {
      try {
        final uri = Uri.parse('$_baseUrl/$model:generateContent');
        final payload = <String, dynamic>{
          'systemInstruction': {
            'parts': [
              {
                'text':
                    'You are a high-precision international clinical laboratory report parser. '
                    'You accurately read digital PDFs AND smartphone photographs of paper lab printouts '
                    '(even if slightly tilted, creased, or shadowed) from ANY country or hospital format '
                    '(e.g. Turkey e-Nabız, USA Quest Diagnostics/LabCorp, UK NHS, Germany MVZ/Laborbefund, '
                    'France Biologie Médicale, Spain/LatAm Hemograma, Russia Invitro/Гемотест, India Lal PathLabs/Thyrocare, '
                    'Arabic, Urdu, Bengali, Hindi, and Chinese hospital reports). '
                    'Extract EVERY numeric laboratory test result from ALL pages. Never invent, guess, or omit numeric rows. '
                    'Return strictly valid JSON only.',
              },
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'inlineData': {
                    'mimeType': mimeType,
                    'data': base64Encode(bytes),
                  },
                },
                {
                  'text':
                      'Extract ALL lab test parameters from this hospital report (PDF or paper photograph) into JSON with this exact schema:\n'
                      '{\n'
                      '  "hospitalName": "string or null",\n'
                      '  "reportDate": "YYYY-MM-DD or null",\n'
                      '  "items": [\n'
                      '    {\n'
                      '      "name": "exact test name as printed (e.g. ALT, Demir, HDL Kolesterol, Glucose, Hämoglobin, Гемоглобин, 血红蛋白, LYM%, eGFR)",\n'
                      '      "value": 12.3,\n'
                      '      "unit": "exact printed unit (e.g. mg/dL, mmol/L, g/L, g/dL, umol/L, mmol/mol, U/L, %, 10^3/uL)",\n'
                      '      "refMin": 0.0,\n'
                      '      "refMax": 35.0\n'
                      '    }\n'
                      '  ]\n'
                      '}\n'
                      'Rules:\n'
                      '- Convert decimal commas (14,3) to dots (14.3) and remove thousand separators (245,000 -> 245000).\n'
                      '- Strip high/low flag markers (H, L, HIGH, LOW, *, ↑, ↓, +, -) from numeric values and units.\n'
                      '- Keep the EXACT printed unit (whether SI like mmol/L, g/L, umol/L, mmol/mol or conventional like mg/dL, g/dL, %) — the app handles unit standardization.\n'
                      '- Include EVERY numeric test row across all pages (CBC/hemogram, biochemistry, liver, kidney, lipids, thyroid, iron, vitamins, HbA1c, inflammation, electrolytes).\n'
                      '- Keep # (absolute) and % (percentage) differential tests separate (e.g. LYM# vs LYM%, NEU# vs NEU%).\n'
                      '- Use null for refMin or refMax if only an upper (< 200) or lower (> 40) bound is printed, or if no reference range is printed.\n'
                      '- Do NOT include patient age, birth date, ID/barcode, phone numbers, page numbers, or section headers as items.',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.0,
            'maxOutputTokens': 4096,
            'responseMimeType': 'application/json',
          },
        };

        final response = await _httpClient
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': _apiKey,
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 35));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Gemini HTTP ${response.statusCode}: ${response.body}');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('Gemini returned no candidates.');
        }
        final parts = ((candidates.first as Map<String, dynamic>)['content']
            as Map<String, dynamic>?)?['parts'] as List<dynamic>?;
        final text = (parts?.first as Map<String, dynamic>?)?['text'] as String?;
        if (text == null || text.trim().isEmpty) {
          throw Exception('Gemini returned empty text.');
        }
        return text;
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? Exception('Gemini lab extraction failed.');
  }

  /// Parses the structured JSON returned by Gemini and normalizes every item
  /// through [LabReportAnalyzer.evaluateExtractedItem] so cross-hospital names
  /// align into canonical codes for longitudinal comparison.
  static AiLabExtractionResult parseAiJson(String rawJson) {
    final cleaned = rawJson
        .trim()
        .replaceFirst(RegExp(r'^```json\s*'), '')
        .replaceFirst(RegExp(r'^```\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();

    final decoded = jsonDecode(cleaned) as Map<String, dynamic>;
    final hospitalName = (decoded['hospitalName'] as String?)?.trim();
    final rawDate = (decoded['reportDate'] as String?)?.trim();
    DateTime? detectedDate;
    if (rawDate != null && rawDate.isNotEmpty) {
      detectedDate = DateTime.tryParse(rawDate);
    }

    final rawItems = decoded['items'] as List<dynamic>? ?? const [];
    final byCode = <String, LabTestItem>{};

    for (final entry in rawItems) {
      if (entry is! Map<String, dynamic>) continue;
      final name = (entry['name'] as String?)?.trim() ?? '';
      final rawVal = entry['value'];
      final value = rawVal is num
          ? rawVal.toDouble()
          : double.tryParse(rawVal?.toString().replaceAll(',', '.') ?? '');
      if (name.isEmpty || value == null) continue;

      final unit = (entry['unit'] as String?)?.trim() ?? '';
      final refMin = _parseNullableNum(entry['refMin']);
      final refMax = _parseNullableNum(entry['refMax']);

      final item = LabReportAnalyzer.evaluateExtractedItem(
        rawName: name,
        value: value,
        unit: unit,
        refMin: refMin,
        refMax: refMax,
      );
      byCode[item.code] = item;
    }

    return AiLabExtractionResult(
      items: byCode.values.toList(),
      detectedDate: detectedDate,
      hospitalName:
          (hospitalName != null && hospitalName.isNotEmpty) ? hospitalName : null,
    );
  }

  static double? _parseNullableNum(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString().trim().replaceAll(',', '.'));
  }
}
