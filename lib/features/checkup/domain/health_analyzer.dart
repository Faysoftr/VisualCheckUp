import 'dart:typed_data';

import 'package:healthcheck/features/checkup/domain/analysis_result.dart';
import 'package:healthcheck/features/checkup/domain/check_category.dart';

/// Abstraction for image-based health screening analyzers.
///
/// The MVP ships with an on-device HSV/RGB color sampling implementation
/// (`ColorHealthAnalyzer`). Later, this interface can be backed by a local
/// TensorFlow Lite model or a cloud Vision AI service without changing UI code.
abstract class HealthAnalyzer {
  Future<AnalysisResult> analyzeImage({
    required CheckCategory category,
    required Uint8List imageBytes,
  });
}
