import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

enum RiskLevel {
  normal,
  attention,
  urgent,
}

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.normal:
        return 'Olağan Görünüm';
      case RiskLevel.attention:
        return 'Takip Önerilir';
      case RiskLevel.urgent:
        return 'Doktor Değerlendirmesi Önerilir';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.normal:
        return const Color(0xFF1B8A5A);
      case RiskLevel.attention:
        return const Color(0xFFD9822B);
      case RiskLevel.urgent:
        return const Color(0xFFC93B3B);
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.normal:
        return Icons.check_circle_outline;
      case RiskLevel.attention:
        return Icons.info_outline;
      case RiskLevel.urgent:
        return Icons.warning_amber_rounded;
    }
  }

  static RiskLevel fromName(String name) {
    return RiskLevel.values.firstWhere(
      (r) => r.name == name,
      orElse: () => RiskLevel.attention,
    );
  }
}

class AnalysisResult {
  const AnalysisResult({
    required this.id,
    required this.category,
    required this.riskLevel,
    required this.summaryTitle,
    required this.summaryDetail,
    required this.dominantColorValue,
    required this.observations,
    required this.recommendations,
    required this.warningFlags,
    required this.confidence,
    required this.createdAt,
  });

  final String id;
  final CheckCategory category;
  final RiskLevel riskLevel;
  final String summaryTitle;
  final String summaryDetail;
  final int dominantColorValue;
  final List<String> observations;
  final List<String> recommendations;
  final List<String> warningFlags;
  final double confidence;
  final DateTime createdAt;

  Color get dominantColor => Color(dominantColorValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.id,
      'riskLevel': riskLevel.name,
      'summaryTitle': summaryTitle,
      'summaryDetail': summaryDetail,
      'dominantColorValue': dominantColorValue,
      'observations': observations,
      'recommendations': recommendations,
      'warningFlags': warningFlags,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      category: CheckCategoryX.fromId(json['category'] as String),
      riskLevel: RiskLevelX.fromName(json['riskLevel'] as String),
      summaryTitle: json['summaryTitle'] as String,
      summaryDetail: json['summaryDetail'] as String,
      dominantColorValue: json['dominantColorValue'] as int,
      observations: (json['observations'] as List<dynamic>).cast<String>(),
      recommendations:
          (json['recommendations'] as List<dynamic>).cast<String>(),
      warningFlags: (json['warningFlags'] as List<dynamic>).cast<String>(),
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
