import 'dart:typed_data';

import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// Optional calibration, baseline, and cloud-AI opt-in context passed to an
/// analyzer.
class AnalysisOptions {
  const AnalysisOptions({
    this.useWhiteReference = false,
    this.baseline,
    this.allowCloudAi = true,
  });

  final bool useWhiteReference;
  final CategoryBaseline? baseline;

  /// When `false`, forces 0-token on-device analysis even if a [VisionAiClient]
  /// is configured.
  final bool allowCloudAi;
}

/// Abstraction for image-based health screening analyzers.
///
/// The MVP uses [ColorHealthAnalyzer] and [SkinConditionAnalyzer] on-device,
/// and [HybridHealthAnalyzer] wraps them with optional Vision AI support.
abstract class HealthAnalyzer {
  Future<AnalysisResult> analyzeImage({
    required CheckCategory category,
    required Uint8List imageBytes,
    AnalysisOptions options = const AnalysisOptions(),
  });
}
