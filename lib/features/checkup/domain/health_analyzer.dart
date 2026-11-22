import 'dart:typed_data';

import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// Optional calibration and baseline context passed to an analyzer.
class AnalysisOptions {
  const AnalysisOptions({
    this.useWhiteReference = false,
    this.baseline,
  });

  final bool useWhiteReference;
  final CategoryBaseline? baseline;
}

/// Abstraction for image-based health screening analyzers.
///
/// The MVP uses [ColorHealthAnalyzer] and [SkinConditionAnalyzer] on-device;
/// this interface allows swapping in a TFLite / ML Vision model without
/// changing the UI.
abstract class HealthAnalyzer {
  Future<AnalysisResult> analyzeImage({
    required CheckCategory category,
    required Uint8List imageBytes,
    AnalysisOptions options = const AnalysisOptions(),
  });
}
