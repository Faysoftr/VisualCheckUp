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

/// Evidence-based bedside self-check protocol (e.g., Schamroth Window Test for
/// nail clubbing, Diascopy glass test for non-blanching petechiae, ABCDEF nail
/// melanoma rule, Lower Eyelid pallor check, Bristol Stool Scale).
class ClinicalSelfTest {
  const ClinicalSelfTest({
    required this.id,
    required this.title,
    required this.purpose,
    required this.steps,
    required this.normalResult,
    required this.warningResult,
    required this.icon,
  });

  final String id;
  final String title;
  final String purpose;
  final List<String> steps;
  final String normalResult;
  final String warningResult;
  final IconData icon;
}

/// Complete healthy vs. unhealthy visual reference specification for a module.
class ModuleReferenceSpec {
  const ModuleReferenceSpec({
    required this.category,
    required this.healthySummary,
    required this.captureQualityChecklist,
    required this.findings,
    this.selfTests = const [],
    this.clinicalMethodSummary,
  });

  final CheckCategory category;
  final String healthySummary;
  final List<String> captureQualityChecklist;
  final List<ReferenceFinding> findings;

  /// Guided evidence-based home self-checks complementing smartphone photos.
  final List<ClinicalSelfTest> selfTests;

  /// Concise summary of the clinical colorimetry / computer vision method used.
  final String? clinicalMethodSummary;

  List<ReferenceFinding> get healthyReferences =>
      findings.where((f) => f.isHealthyReference).toList();

  List<ReferenceFinding> get abnormalFindings =>
      findings.where((f) => !f.isHealthyReference).toList();
}
