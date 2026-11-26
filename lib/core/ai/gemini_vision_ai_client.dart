import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';

/// Production Gemini Vision REST client implementing [VisionAiClient].
///
/// Reads `GEMINI_API_KEY` from `--dart-define=GEMINI_API_KEY=...` (or
/// `--dart-define-from-file=dart_defines.local.json`) so no API key is ever
/// hardcoded in tracked source files.
class GeminiVisionAiClient implements VisionAiClient {
  GeminiVisionAiClient({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  static const String envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Returns a configured client when `GEMINI_API_KEY` is provided at build/run
  /// time, or `null` so [HybridHealthAnalyzer] runs in 0-cost on-device mode.
  static GeminiVisionAiClient? fromEnvironment({http.Client? httpClient}) {
    final trimmed = envApiKey.trim();
    if (trimmed.isEmpty) return null;
    return GeminiVisionAiClient(apiKey: trimmed, httpClient: httpClient);
  }

  final String apiKey;
  final http.Client _httpClient;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  Future<String> analyzeWithVisionAi(AiVisionRequest request) async {
    final candidateModels = <String>[
      request.recommendedModel,
      request.modelTier == AiModelTier.standard
          ? 'gemini-2.5-flash'
          : 'gemini-2.5-flash-lite',
    ];

    Object? lastError;
    for (final model in candidateModels) {
      try {
        return await _callModel(model: model, request: request);
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Gemini Vision request failed.');
  }

  Future<String> _callModel({
    required String model,
    required AiVisionRequest request,
  }) async {
    final uri = Uri.parse('$_baseUrl/$model:generateContent');
    final payload = <String, dynamic>{
      'systemInstruction': {
        'parts': [
          {'text': request.systemInstruction},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'inlineData': {
                'mimeType': request.mimeType,
                'data': base64Encode(request.imageBytes),
              },
            },
            {'text': request.userPrompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': request.maxOutputTokens,
        'responseMimeType': 'application/json',
      },
    };

    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gemini API HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini API returned no candidates.');
    }
    final content =
        (candidates.first as Map<String, dynamic>)['content']
            as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini API returned empty content parts.');
    }
    final text = (parts.first as Map<String, dynamic>)['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini API returned empty text.');
    }
    return text;
  }
}
