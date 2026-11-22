import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// A single structured visual reference finding (either healthy baseline or
/// an abnormal/warning visual cue) used both for in-app educational guides
/// and as the ground-truth rubric for Vision AI prompts.
class ReferenceFinding {
  const ReferenceFinding({
    required this.id,
    required this.title,
    required this.isHealthyReference,
    required this.riskLevel,
    required this.swatchColor,
    required this.visualSignature,
    required this.possibleAssociations,
    this.redFlagNote,
  });

  /// Stable snake_case identifier used in Vision AI JSON responses.
  final String id;
  final String title;
  final bool isHealthyReference;
  final RiskLevel riskLevel;
  final Color swatchColor;

  /// Objective visual cues (color, pattern, texture, shape) to compare against.
  final String visualSignature;

  /// Non-diagnostic everyday or clinical contexts associated with this cue.
  final String possibleAssociations;

  /// Optional urgent escalation note when accompanying red-flag symptoms exist.
  final String? redFlagNote;

  Map<String, dynamic> toAiRubricMap() => {
        'finding_id': id,
        'title': title,
        'type': isHealthyReference ? 'healthy_reference' : 'abnormal_finding',
        'suggested_risk_level': riskLevel.name,
        'visual_signature': visualSignature,
        'possible_associations': possibleAssociations,
        if (redFlagNote != null) 'red_flag': redFlagNote,
      };
}

/// Complete healthy vs. unhealthy visual reference specification for a module.
class ModuleReferenceSpec {
  const ModuleReferenceSpec({
    required this.category,
    required this.healthySummary,
    required this.captureQualityChecklist,
    required this.findings,
  });

  final CheckCategory category;
  final String healthySummary;
  final List<String> captureQualityChecklist;
  final List<ReferenceFinding> findings;

  List<ReferenceFinding> get healthyReferences =>
      findings.where((f) => f.isHealthyReference).toList();

  List<ReferenceFinding> get abnormalFindings =>
      findings.where((f) => !f.isHealthyReference).toList();
}
