import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';

/// Server-side Cloud Function Vision AI client (`analyzeVisualHealth` in
/// `europe-west1`) that keeps `GEMINI_API_KEY` strictly on the backend.
class CloudFunctionVisionAiClient implements VisionAiClient {
  const CloudFunctionVisionAiClient({
    this.region = 'europe-west1',
  });

  final String region;

  @override
  Future<String> analyzeWithVisionAi(AiVisionRequest request) async {
    final callable = FirebaseFunctions.instanceFor(region: region)
        .httpsCallable(
          'analyzeVisualHealth',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 25)),
        );
    final result = await callable.call<Map<dynamic, dynamic>>(<String, dynamic>{
      'model': request.recommendedModel,
      'mimeType': request.mimeType,
      'imageBase64': base64Encode(request.imageBytes),
      'systemInstruction': request.systemInstruction,
      'userPrompt': request.userPrompt,
      'maxOutputTokens': request.maxOutputTokens,
    });
    final data = result.data;
    final text = data['text']?.toString();
    if (text == null || text.trim().isEmpty) {
      throw Exception('Cloud Function analyzeVisualHealth returned empty text.');
    }
    return text;
  }
}

/// Production Gemini Vision client implementing [VisionAiClient].
///
/// Prefers the secure server-side [CloudFunctionVisionAiClient] in production
/// when Firebase is initialized and no local dev `--dart-define=GEMINI_API_KEY`
/// is supplied; also supports direct REST calls for local development/testing.
class GeminiVisionAiClient implements VisionAiClient {
  GeminiVisionAiClient({
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  static const String envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Returns a configured [VisionAiClient]:
  /// 1. Direct [GeminiVisionAiClient] when `GEMINI_API_KEY` is provided via
  ///    `--dart-define` for local development.
  /// 2. Server-side [CloudFunctionVisionAiClient] when Firebase is initialized
  ///    so no API key is ever shipped in production binaries.
  /// 3. `null` offline/in unit tests so [HybridHealthAnalyzer] runs in 0-cost
  ///    on-device mode.
  static VisionAiClient? fromEnvironment({http.Client? httpClient}) {
    final trimmed = envApiKey.trim();
    if (trimmed.isNotEmpty) {
      return GeminiVisionAiClient(apiKey: trimmed, httpClient: httpClient);
    }
    try {
      if (Firebase.apps.isNotEmpty) {
        return const CloudFunctionVisionAiClient();
      }
    } catch (e) {
      debugPrint('VisionAiClient Firebase check skipped: $e');
    }
    return null;
  }

  final String apiKey;
  final http.Client _httpClient;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  Future<String> analyzeWithVisionAi(AiVisionRequest request) async {
    final fallbackModel = request.modelTier == AiModelTier.standard
        ? 'gemini-2.5-flash'
        : 'gemini-2.5-flash-lite';
    final candidateModels = <String>{
      request.recommendedModel,
      fallbackModel,
    }.toList();

    Object? lastError;
    for (final model in candidateModels) {
      try {
        return await _callModel(model: model, request: request);
      } catch (e) {
        debugPrint('GeminiVisionAiClient model $model error: $e');
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
