import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/ai/gemini_vision_ai_client.dart';
import 'package:visualcheckup/features/diet/domain/diet_models.dart';

/// Structured result returned by [MealCalorieAnalyzer] before saving.
class CalorieAnalysisResult {
  const CalorieAnalysisResult({
    required this.dishName,
    required this.totalCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.items,
    required this.healthScore,
    required this.healthComment,
    required this.analyzedByAi,
  });

  final String dishName;
  final int totalCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final List<PlateFoodItem> items;
  final int healthScore;
  final String healthComment;
  final bool analyzedByAi;

  CalorieAnalysisResult scaled(double factor) {
    if (factor == 1.0) return this;
    return CalorieAnalysisResult(
      dishName: dishName,
      totalCalories: (totalCalories * factor).round(),
      proteinG: double.parse((proteinG * factor).toStringAsFixed(1)),
      carbsG: double.parse((carbsG * factor).toStringAsFixed(1)),
      fatG: double.parse((fatG * factor).toStringAsFixed(1)),
      fiberG: double.parse((fiberG * factor).toStringAsFixed(1)),
      items: items.map((i) => i.scaled(factor)).toList(),
      healthScore: healthScore,
      healthComment: healthComment,
      analyzedByAi: analyzedByAi,
    );
  }
}

/// Abstract contract for AI / local plate calorie analysis so widget & unit
/// tests can inject deterministic fake analyzers.
abstract class MealCalorieAnalyzer {
  bool get usesCloudAi;

  Future<CalorieAnalysisResult> analyzePlate({
    Uint8List? imageBytes,
    String? foodDescription,
    MealSlot mealSlot = MealSlot.lunch,
    String languageCode = 'tr',
  });
}

/// Production plate calorie calculator powered by Gemini 2.5 Flash Vision with
/// automatic seamless fallback to [LocalMealCalorieEstimator] when offline or
/// when `GEMINI_API_KEY` is not configured.
class GeminiMealCalorieAnalyzer implements MealCalorieAnalyzer {
  GeminiMealCalorieAnalyzer({
    String? apiKey,
    http.Client? httpClient,
    LocalMealCalorieEstimator? fallback,
  })  : _apiKey = (apiKey ?? GeminiVisionAiClient.envApiKey).trim(),
        _httpClient = httpClient ?? http.Client(),
        _fallback = fallback ?? const LocalMealCalorieEstimator();

  final String _apiKey;
  final http.Client _httpClient;
  final LocalMealCalorieEstimator _fallback;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  bool get usesCloudAi => _apiKey.isNotEmpty;

  @override
  Future<CalorieAnalysisResult> analyzePlate({
    Uint8List? imageBytes,
    String? foodDescription,
    MealSlot mealSlot = MealSlot.lunch,
    String languageCode = 'tr',
  }) async {
    if (!usesCloudAi) {
      return _fallback.analyzePlate(
        imageBytes: imageBytes,
        foodDescription: foodDescription,
        mealSlot: mealSlot,
        languageCode: languageCode,
      );
    }

    try {
      final rawJson = await _callGemini(
        imageBytes: imageBytes,
        foodDescription: foodDescription,
        languageCode: languageCode,
      );
      return parseAiJson(rawJson);
    } catch (_) {
      return _fallback.analyzePlate(
        imageBytes: imageBytes,
        foodDescription: foodDescription,
        mealSlot: mealSlot,
        languageCode: languageCode,
      );
    }
  }

  Future<String> _callGemini({
    Uint8List? imageBytes,
    String? foodDescription,
    required String languageCode,
  }) async {
    const models = ['gemini-2.5-flash', 'gemini-2.5-flash-lite'];
    Object? lastError;

    Uint8List? compressedBytes;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final decoded = img.decodeImage(imageBytes);
      if (decoded != null && (decoded.width > 768 || decoded.height > 768)) {
        final resized = img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? 768 : null,
          height: decoded.height > decoded.width ? 768 : null,
        );
        compressedBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 82));
      } else {
        compressedBytes = imageBytes;
      }
    }

    final noteLine = (foodDescription ?? '').trim().isNotEmpty
        ? 'User meal description / portion note: "${foodDescription!.trim()}".\n'
        : '';

    final userParts = <Map<String, dynamic>>[
      if (compressedBytes != null)
        {
          'inlineData': {
            'mimeType': 'image/jpeg',
            'data': base64Encode(compressedBytes),
          },
        },
      {
        'text':
            'Analyze this meal/plate and estimate realistic calories and macronutrients.\n'
            '$noteLine'
            'Respond in language "$languageCode" with STRICT valid JSON using this exact schema:\n'
            '{\n'
            '  "dishName": "Short clear dish title",\n'
            '  "totalCalories": 520,\n'
            '  "proteinG": 32.0,\n'
            '  "carbsG": 45.0,\n'
            '  "fatG": 18.0,\n'
            '  "fiberG": 7.5,\n'
            '  "healthScore": 8,\n'
            '  "healthComment": "Short plain-language senior-friendly feedback (1-2 sentences) on balance, glycemic impact, or hydration.",\n'
            '  "items": [\n'
            '    {\n'
            '      "name": "Food item name",\n'
            '      "portion": "Estimated portion (e.g. 150 g / 1 bowl)",\n'
            '      "calories": 240,\n'
            '      "proteinG": 28.0,\n'
            '      "carbsG": 0.0,\n'
            '      "fatG": 6.0\n'
            '    }\n'
            '  ]\n'
            '}',
      },
    ];

    for (final model in models) {
      try {
        final uri = Uri.parse('$_baseUrl/$model:generateContent');
        final payload = <String, dynamic>{
          'systemInstruction': {
            'parts': [
              {
                'text':
                    'You are a registered clinical dietitian and computer vision nutrition analyst. '
                    'Estimate realistic portion sizes, calories (kcal), protein, carbs, fat, and fiber '
                    'from meal photographs and/or text descriptions (including Turkish and international cuisine). '
                    'Return strictly valid JSON only.',
              },
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': userParts,
            },
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 1024,
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
            .timeout(const Duration(seconds: 30));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Gemini HTTP ${response.statusCode}');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        final parts = ((candidates?.first as Map<String, dynamic>?)?['content']
            as Map<String, dynamic>?)?['parts'] as List<dynamic>?;
        final text = (parts?.first as Map<String, dynamic>?)?['text'] as String?;
        if (text == null || text.trim().isEmpty) {
          throw Exception('Gemini returned empty text');
        }
        return text;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Gemini plate analysis failed');
  }

  /// Parses Gemini Vision JSON into a clean [CalorieAnalysisResult].
  static CalorieAnalysisResult parseAiJson(String rawText) {
    final cleaned = rawText
        .trim()
        .replaceAll(RegExp(r'^```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^```\s*'), '')
        .replaceAll(RegExp(r'\s*```$'), '');
    final map = jsonDecode(cleaned) as Map<String, dynamic>;
    final rawItems = (map['items'] as List<dynamic>?) ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(PlateFoodItem.fromJson)
        .where((i) => i.name.trim().isNotEmpty)
        .toList();

    final sumCal = items.fold<int>(0, (s, i) => s + i.calories);
    final totalCal = (map['totalCalories'] as num?)?.round() ?? sumCal;

    return CalorieAnalysisResult(
      dishName: (map['dishName'] as String?)?.trim().isNotEmpty == true
          ? (map['dishName'] as String).trim()
          : (items.isNotEmpty ? items.map((e) => e.name).join(', ') : 'Öğün'),
      totalCalories: totalCal > 0 ? totalCal : sumCal,
      proteinG: (map['proteinG'] as num?)?.toDouble() ??
          items.fold<double>(0, (s, i) => s + i.proteinG),
      carbsG: (map['carbsG'] as num?)?.toDouble() ??
          items.fold<double>(0, (s, i) => s + i.carbsG),
      fatG: (map['fatG'] as num?)?.toDouble() ??
          items.fold<double>(0, (s, i) => s + i.fatG),
      fiberG: (map['fiberG'] as num?)?.toDouble() ?? 4.0,
      items: items,
      healthScore: ((map['healthScore'] as num?)?.toInt() ?? 7).clamp(1, 10),
      healthComment: (map['healthComment'] as String?)?.trim() ?? '',
      analyzedByAi: true,
    );
  }
}

class _FoodPreset {
  const _FoodPreset({
    required this.keywords,
    required this.displayName,
    required this.portion,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 1.5,
  });

  final List<String> keywords;
  final String displayName;
  final String portion;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
}

/// Offline / on-device smart calorie estimator using a curated Turkish &
/// international food database + plate photo color-composition analysis.
class LocalMealCalorieEstimator implements MealCalorieAnalyzer {
  const LocalMealCalorieEstimator();

  @override
  bool get usesCloudAi => false;

  static const List<_FoodPreset> _database = [
    _FoodPreset(
      keywords: ['yumurta', 'egg', 'omlet', 'menemen'],
      displayName: 'Yumurta / Omlet',
      portion: '2 adet',
      calories: 155,
      proteinG: 13,
      carbsG: 1.5,
      fatG: 11,
      fiberG: 0,
    ),
    _FoodPreset(
      keywords: ['peynir', 'lor', 'cheese', 'feta', 'kaşar', 'kasar'],
      displayName: 'Peynir',
      portion: '1 dilim (40 g)',
      calories: 110,
      proteinG: 7,
      carbsG: 1,
      fatG: 8.5,
      fiberG: 0,
    ),
    _FoodPreset(
      keywords: ['zeytin', 'olive'],
      displayName: 'Zeytin',
      portion: '6 adet',
      calories: 45,
      proteinG: 0.3,
      carbsG: 1.5,
      fatG: 4.5,
      fiberG: 1,
    ),
    _FoodPreset(
      keywords: ['ekmek', 'bread', 'tost', 'simit'],
      displayName: 'Tam Buğday Ekmek',
      portion: '1 dilim (35 g)',
      calories: 85,
      proteinG: 3.5,
      carbsG: 16,
      fatG: 1,
      fiberG: 2.5,
    ),
    _FoodPreset(
      keywords: ['yulaf', 'oat', 'porridge'],
      displayName: 'Yulaf Ezmesi',
      portion: '4 yemek kaşığı (40 g)',
      calories: 150,
      proteinG: 5,
      carbsG: 27,
      fatG: 2.5,
      fiberG: 4,
    ),
    _FoodPreset(
      keywords: ['tavuk', 'chicken', 'hindi', 'turkey'],
      displayName: 'Izgara Tavuk Göğsü',
      portion: '150 g',
      calories: 245,
      proteinG: 42,
      carbsG: 0,
      fatG: 7,
      fiberG: 0,
    ),
    _FoodPreset(
      keywords: ['köfte', 'kofte', 'et', 'steak', 'biftek', 'kıyma', 'kiyma', 'beef', 'meatball'],
      displayName: 'Izgara Köfte / Et',
      portion: '4 adet (120 g)',
      calories: 280,
      proteinG: 24,
      carbsG: 5,
      fatG: 18,
      fiberG: 0.5,
    ),
    _FoodPreset(
      keywords: ['balık', 'balik', 'somon', 'levrek', 'çipura', 'hamsi', 'ton', 'fish', 'salmon', 'tuna'],
      displayName: 'Izgara Balık / Somon',
      portion: '150 g',
      calories: 270,
      proteinG: 32,
      carbsG: 0,
      fatG: 15,
      fiberG: 0,
    ),
    _FoodPreset(
      keywords: ['bulgur'],
      displayName: 'Bulgur Pilavı',
      portion: '4 yemek kaşığı (120 g)',
      calories: 165,
      proteinG: 5,
      carbsG: 32,
      fatG: 2.5,
      fiberG: 4.5,
    ),
    _FoodPreset(
      keywords: ['pilav', 'pirinç', 'pirinc', 'rice'],
      displayName: 'Pirinç Pilavı',
      portion: '4 yemek kaşığı (120 g)',
      calories: 205,
      proteinG: 3.5,
      carbsG: 38,
      fatG: 4.5,
      fiberG: 0.8,
    ),
    _FoodPreset(
      keywords: ['makarna', 'pasta', 'spagetti', 'erişte'],
      displayName: 'Makarna',
      portion: '1 kase (150 g)',
      calories: 240,
      proteinG: 8,
      carbsG: 44,
      fatG: 4,
      fiberG: 2.5,
    ),
    _FoodPreset(
      keywords: ['mercimek', 'lentil', 'çorba', 'corba', 'soup'],
      displayName: 'Mercimek / Sebze Çorbası',
      portion: '1 kase (250 ml)',
      calories: 155,
      proteinG: 8,
      carbsG: 22,
      fatG: 4,
      fiberG: 4,
    ),
    _FoodPreset(
      keywords: ['fasulye', 'nohut', 'barbunya', 'baklagil', 'bean', 'chickpea'],
      displayName: 'Zeytinyağlı Baklagil Yemeği',
      portion: '1 porsiyon (200 g)',
      calories: 240,
      proteinG: 12,
      carbsG: 34,
      fatG: 6,
      fiberG: 8,
    ),
    _FoodPreset(
      keywords: ['salata', 'salad', 'yeşillik', 'roka', 'marul', 'domates', 'salatalık'],
      displayName: 'Mevsim Salata (Zeytinyağlı)',
      portion: '1 büyük kase',
      calories: 95,
      proteinG: 2,
      carbsG: 9,
      fatG: 6,
      fiberG: 3.5,
    ),
    _FoodPreset(
      keywords: ['yoğurt', 'yogurt', 'cacık', 'cacik', 'ayran', 'kefir'],
      displayName: 'Yoğurt / Ayran / Cacık',
      portion: '1 kase / bardak (200 g)',
      calories: 120,
      proteinG: 7,
      carbsG: 9,
      fatG: 6,
      fiberG: 0,
    ),
    _FoodPreset(
      keywords: ['kabak', 'ıspanak', 'ispanak', 'brokoli', 'sebze', 'patlıcan', 'patlican', 'karnabahar', 'vegetable'],
      displayName: 'Zeytinyağlı Sebze Yemeği',
      portion: '1 porsiyon (200 g)',
      calories: 150,
      proteinG: 4,
      carbsG: 14,
      fatG: 9,
      fiberG: 5,
    ),
    _FoodPreset(
      keywords: ['lahmacun', 'pide', 'pizza', 'börek', 'borek'],
      displayName: 'Lahmacun / Pide / Börek',
      portion: '1 adet / porsiyon',
      calories: 360,
      proteinG: 14,
      carbsG: 44,
      fatG: 14,
      fiberG: 2.5,
    ),
    _FoodPreset(
      keywords: ['döner', 'doner', 'kebap', 'kebab', 'iskender', 'burger'],
      displayName: 'Döner / Kebap Porsiyon',
      portion: '1 porsiyon',
      calories: 520,
      proteinG: 30,
      carbsG: 36,
      fatG: 28,
      fiberG: 2,
    ),
    _FoodPreset(
      keywords: ['elma', 'apple', 'armut', 'portakal', 'mandalina', 'meyve', 'fruit', 'çilek', 'kivi'],
      displayName: 'Taze Meyve',
      portion: '1 orta boy',
      calories: 80,
      proteinG: 0.6,
      carbsG: 20,
      fatG: 0.3,
      fiberG: 3.5,
    ),
    _FoodPreset(
      keywords: ['muz', 'banana'],
      displayName: 'Muz',
      portion: '1 orta boy',
      calories: 105,
      proteinG: 1.3,
      carbsG: 27,
      fatG: 0.4,
      fiberG: 3,
    ),
    _FoodPreset(
      keywords: ['badem', 'ceviz', 'fındık', 'findik', 'nut', 'almond', 'walnut'],
      displayName: 'Çiğ Kuruyemiş (Badem/Ceviz)',
      portion: '1 avuç (20 g)',
      calories: 125,
      proteinG: 4,
      carbsG: 4,
      fatG: 11,
      fiberG: 2,
    ),
    _FoodPreset(
      keywords: ['avokado', 'avocado'],
      displayName: 'Avokado',
      portion: 'Yarım adet',
      calories: 120,
      proteinG: 1.5,
      carbsG: 6,
      fatG: 11,
      fiberG: 5,
    ),
    _FoodPreset(
      keywords: ['patates', 'potato', 'fries', 'kızartma'],
      displayName: 'Patates',
      portion: '1 orta porsiyon',
      calories: 210,
      proteinG: 3.5,
      carbsG: 34,
      fatG: 7,
      fiberG: 3,
    ),
    _FoodPreset(
      keywords: ['tatlı', 'tatli', 'baklava', 'pasta', 'kek', 'çikolata', 'cikolata', 'dessert', 'cake'],
      displayName: 'Tatlı / Pasta',
      portion: '1 porsiyon',
      calories: 320,
      proteinG: 4,
      carbsG: 46,
      fatG: 14,
      fiberG: 1,
    ),
  ];

  @override
  Future<CalorieAnalysisResult> analyzePlate({
    Uint8List? imageBytes,
    String? foodDescription,
    MealSlot mealSlot = MealSlot.lunch,
    String languageCode = 'tr',
  }) async {
    final text = (foodDescription ?? '').trim().toLowerCase();
    final matchedItems = <PlateFoodItem>[];
    double totalFiber = 0;

    if (text.isNotEmpty) {
      for (final preset in _database) {
        if (preset.keywords.any(text.contains)) {
          matchedItems.add(
            PlateFoodItem(
              name: preset.displayName,
              portion: preset.portion,
              calories: preset.calories,
              proteinG: preset.proteinG,
              carbsG: preset.carbsG,
              fatG: preset.fatG,
            ),
          );
          totalFiber += preset.fiberG;
        }
      }
    }

    // If text matched specific foods, sum them accurately!
    if (matchedItems.isNotEmpty) {
      final totalCal = matchedItems.fold<int>(0, (s, i) => s + i.calories);
      final protein = matchedItems.fold<double>(0, (s, i) => s + i.proteinG);
      final carbs = matchedItems.fold<double>(0, (s, i) => s + i.carbsG);
      final fat = matchedItems.fold<double>(0, (s, i) => s + i.fatG);
      final score = _computeBalanceScore(
        calories: totalCal,
        proteinG: protein,
        carbsG: carbs,
        fiberG: totalFiber,
      );
      return CalorieAnalysisResult(
        dishName: matchedItems.map((e) => e.name).take(3).join(' + '),
        totalCalories: totalCal,
        proteinG: double.parse(protein.toStringAsFixed(1)),
        carbsG: double.parse(carbs.toStringAsFixed(1)),
        fatG: double.parse(fat.toStringAsFixed(1)),
        fiberG: double.parse(totalFiber.toStringAsFixed(1)),
        items: matchedItems,
        healthScore: score,
        healthComment: _buildComment(
          calories: totalCal,
          proteinG: protein,
          fiberG: totalFiber,
          languageCode: languageCode,
        ),
        analyzedByAi: false,
      );
    }

    // Otherwise analyze the plate photo's visual color proportions on-device!
    return _estimateFromPlatePhoto(
      imageBytes: imageBytes,
      mealSlot: mealSlot,
      languageCode: languageCode,
    );
  }

  CalorieAnalysisResult _estimateFromPlatePhoto({
    Uint8List? imageBytes,
    required MealSlot mealSlot,
    required String languageCode,
  }) {
    double greenRatio = 0.25;
    double goldenStarchRatio = 0.30;
    double proteinBrownRatio = 0.28;
    double richSauceRedRatio = 0.17;

    if (imageBytes != null && imageBytes.isNotEmpty) {
      final decoded = img.decodeImage(imageBytes);
      if (decoded != null) {
        final sample = img.copyResize(decoded, width: 80, height: 80);
        int green = 0, golden = 0, protein = 0, redSauce = 0, counted = 0;
        for (int y = 10; y < 70; y++) {
          for (int x = 10; x < 70; x++) {
            final p = sample.getPixel(x, y);
            final r = p.r.toInt();
            final g = p.g.toInt();
            final b = p.b.toInt();
            // Skip bright white plate rim pixels
            if (r > 225 && g > 225 && b > 225) continue;
            counted++;
            if (g > r + 12 && g > b + 12) {
              green++;
            } else if (r > 165 && g > 130 && b < 110) {
              golden++;
            } else if (r > g + 35 && r > b + 35) {
              redSauce++;
            } else if (r > 80 && g > 55 && r >= b) {
              protein++;
            }
          }
        }
        if (counted > 50) {
          greenRatio = (green / counted).clamp(0.05, 0.75);
          goldenStarchRatio = (golden / counted).clamp(0.05, 0.70);
          proteinBrownRatio = (protein / counted).clamp(0.10, 0.65);
          richSauceRedRatio = (redSauce / counted).clamp(0.0, 0.45);
        }
      }
    }

    final baseKcal = switch (mealSlot) {
      MealSlot.breakfast => 380,
      MealSlot.morningSnack || MealSlot.afternoonSnack => 190,
      MealSlot.lunch => 520,
      MealSlot.dinner => 470,
    };

    // High salad/green fraction lowers caloric density; starch/sauce raises it.
    final densityMultiplier =
        (0.78 + goldenStarchRatio * 0.55 + richSauceRedRatio * 0.35 - greenRatio * 0.32)
            .clamp(0.65, 1.38);
    final totalCal = (baseKcal * densityMultiplier).round();
    final proteinG =
        double.parse(((totalCal * (0.18 + proteinBrownRatio * 0.22)) / 4).toStringAsFixed(1));
    final fatG =
        double.parse(((totalCal * (0.24 + richSauceRedRatio * 0.16)) / 9).toStringAsFixed(1));
    final carbsG = double.parse(
      (((totalCal - proteinG * 4 - fatG * 9).clamp(20, totalCal)) / 4)
          .toStringAsFixed(1),
    );
    final fiberG = double.parse((3.0 + greenRatio * 12.0).toStringAsFixed(1));

    final isTr = languageCode == 'tr';
    final items = <PlateFoodItem>[
      PlateFoodItem(
        name: isTr ? 'Ana Protein / Yemek Bölümü' : 'Main Protein / Entrée',
        portion: isTr ? 'Tahmini 1 porsiyon' : 'Est. 1 serving',
        calories: (totalCal * 0.46).round(),
        proteinG: double.parse((proteinG * 0.72).toStringAsFixed(1)),
        carbsG: double.parse((carbsG * 0.22).toStringAsFixed(1)),
        fatG: double.parse((fatG * 0.55).toStringAsFixed(1)),
      ),
      PlateFoodItem(
        name: isTr ? 'Tahıl / Yan Garnitür' : 'Grains / Side Starch',
        portion: isTr ? 'Orta porsiyon' : 'Medium side',
        calories: (totalCal * 0.34).round(),
        proteinG: double.parse((proteinG * 0.18).toStringAsFixed(1)),
        carbsG: double.parse((carbsG * 0.62).toStringAsFixed(1)),
        fatG: double.parse((fatG * 0.25).toStringAsFixed(1)),
      ),
      PlateFoodItem(
        name: isTr ? 'Sebze / Salata & Sos' : 'Vegetables / Salad & Dressing',
        portion: isTr ? 'Tabak kenarı' : 'Side portion',
        calories: (totalCal * 0.20).round(),
        proteinG: double.parse((proteinG * 0.10).toStringAsFixed(1)),
        carbsG: double.parse((carbsG * 0.16).toStringAsFixed(1)),
        fatG: double.parse((fatG * 0.20).toStringAsFixed(1)),
      ),
    ];

    final score = _computeBalanceScore(
      calories: totalCal,
      proteinG: proteinG,
      carbsG: carbsG,
      fiberG: fiberG,
    );

    return CalorieAnalysisResult(
      dishName: isTr
          ? 'Tabak Görsel Kalori Analizi'
          : 'Plate Visual Calorie Estimate',
      totalCalories: totalCal,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      fiberG: fiberG,
      items: items,
      healthScore: score,
      healthComment: _buildComment(
        calories: totalCal,
        proteinG: proteinG,
        fiberG: fiberG,
        languageCode: languageCode,
      ),
      analyzedByAi: false,
    );
  }

  int _computeBalanceScore({
    required int calories,
    required double proteinG,
    required double carbsG,
    required double fiberG,
  }) {
    int score = 7;
    if (proteinG >= 22) score += 1;
    if (fiberG >= 6) score += 1;
    if (calories > 750) score -= 2;
    if (carbsG > 75 && fiberG < 5) score -= 1;
    return score.clamp(3, 10);
  }

  String _buildComment({
    required int calories,
    required double proteinG,
    required double fiberG,
    required String languageCode,
  }) {
    if (languageCode != 'tr') {
      if (calories > 700) {
        return 'Higher-calorie meal. Pair with water and keep your next meal lighter with vegetables.';
      }
      if (proteinG >= 22 && fiberG >= 5) {
        return 'Well-balanced plate with good protein and fiber to keep blood sugar steady.';
      }
      return 'Moderate-calorie meal. Adding leafy greens or yogurt can boost fullness and balance.';
    }
    if (calories > 700) {
      return 'Kalori yoğunluğu yüksek bir öğün. Yanında bol su için ve bir sonraki öğünü sebze ağırlıklı daha hafif tutun.';
    }
    if (proteinG >= 22 && fiberG >= 5) {
      return 'Protein ve lif dengesi güçlü bir tabak; kan şekerini dengede tutmaya ve uzun süre tok kalmaya yardımcı olur.';
    }
    return 'Dengeli kalorili bir öğün. Yanına yeşil salata veya yoğurt ekleyerek tokluk süresini uzatabilirsiniz.';
  }
}
