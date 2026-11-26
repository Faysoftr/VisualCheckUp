import 'package:flutter/material.dart';

enum LabStatus {
  criticalLow,
  low,
  normal,
  high,
  criticalHigh,
}

extension LabStatusX on LabStatus {
  String get label {
    switch (this) {
      case LabStatus.criticalLow:
        return 'Kritik Düşük';
      case LabStatus.low:
        return 'Düşük';
      case LabStatus.normal:
        return 'Normal';
      case LabStatus.high:
        return 'Yüksek';
      case LabStatus.criticalHigh:
        return 'Kritik Yüksek';
    }
  }

  bool get isAbnormal => this != LabStatus.normal;

  bool get isCritical =>
      this == LabStatus.criticalLow || this == LabStatus.criticalHigh;

  Color get color {
    switch (this) {
      case LabStatus.normal:
        return const Color(0xFF1B8A5A);
      case LabStatus.low:
      case LabStatus.high:
        return const Color(0xFFD9822B);
      case LabStatus.criticalLow:
      case LabStatus.criticalHigh:
        return const Color(0xFFC93B3B);
    }
  }

  static LabStatus fromName(String name) {
    return LabStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => LabStatus.normal,
    );
  }
}

enum LabReportSource {
  manual,
  pastedText,
  photoScan,
  pdfUpload,
}

extension LabReportSourceX on LabReportSource {
  String get label {
    switch (this) {
      case LabReportSource.manual:
        return 'Manuel Giriş';
      case LabReportSource.pastedText:
        return 'Rapor Metninden Okundu';
      case LabReportSource.photoScan:
        return 'JPG / Fotoğraf Raporu';
      case LabReportSource.pdfUpload:
        return 'PDF Raporu';
    }
  }

  static LabReportSource fromName(String name) {
    return LabReportSource.values.firstWhere(
      (s) => s.name == name,
      orElse: () => LabReportSource.manual,
    );
  }
}

/// Curated adult reference specification for common blood panel parameters.
/// Note: Lab ranges vary slightly by laboratory, sex, and age.
class LabParameterSpec {
  const LabParameterSpec({
    required this.code,
    required this.name,
    required this.aliases,
    required this.unit,
    required this.minNormal,
    required this.maxNormal,
    this.criticalLow,
    this.criticalHigh,
    required this.lowNote,
    required this.highNote,
    required this.specialtyHint,
  });

  final String code;
  final String name;
  final List<String> aliases;
  final String unit;
  final double minNormal;
  final double maxNormal;
  final double? criticalLow;
  final double? criticalHigh;
  final String lowNote;
  final String highNote;
  final String specialtyHint;
}

class LabTestItem {
  const LabTestItem({
    required this.code,
    required this.name,
    required this.value,
    required this.unit,
    required this.refMin,
    required this.refMax,
    required this.status,
    required this.note,
  });

  final String code;
  final String name;
  final double value;
  final String unit;
  final double? refMin;
  final double? refMax;
  final LabStatus status;
  final String note;

  String get referenceRangeText {
    if (refMin != null && refMax != null) {
      return '${_fmtNum(refMin!)} – ${_fmtNum(refMax!)} $unit';
    }
    if (refMax != null) {
      return '< ${_fmtNum(refMax!)} $unit';
    }
    if (refMin != null) {
      return '> ${_fmtNum(refMin!)} $unit';
    }
    return unit;
  }

  String get formattedValue => '${_fmtNum(value)} $unit';

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'value': value,
        'unit': unit,
        if (refMin != null) 'refMin': refMin,
        if (refMax != null) 'refMax': refMax,
        'status': status.name,
        'note': note,
      };

  factory LabTestItem.fromJson(Map<String, dynamic> json) {
    return LabTestItem(
      code: json['code'] as String,
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      refMin: (json['refMin'] as num?)?.toDouble(),
      refMax: (json['refMax'] as num?)?.toDouble(),
      status: LabStatusX.fromName(json['status'] as String),
      note: json['note'] as String,
    );
  }
}

class LabReportRecord {
  const LabReportRecord({
    required this.id,
    required this.title,
    required this.reportDate,
    required this.source,
    required this.items,
    required this.overallSummary,
    required this.suggestedSpecialty,
    this.rawReportText,
    this.notes,
    this.hospitalDiagnosis,
    this.userComplaintNote,
    this.attachmentFileName,
    this.attachmentMimeType,
    this.contextualInterpretation,
    this.followUpQuestions = const [],
  });

  final String id;
  final String title;
  final DateTime reportDate;
  final LabReportSource source;
  final List<LabTestItem> items;
  final String overallSummary;
  final String suggestedSpecialty;
  final String? rawReportText;
  final String? notes;

  /// Optional hospital/doctor diagnosis or epicrisis text entered by the user.
  final String? hospitalDiagnosis;

  /// Optional user's own complaint, symptoms, or question text.
  final String? userComplaintNote;

  /// Optional uploaded PDF or JPG file metadata.
  final String? attachmentFileName;
  final String? attachmentMimeType;

  /// Plain-Turkish combined interpretation connecting the lab values with the
  /// optional hospital diagnosis and/or user complaint.
  final String? contextualInterpretation;

  /// Tailored questions the user can ask their doctor at follow-up.
  final List<String> followUpQuestions;

  int get abnormalCount => items.where((i) => i.status.isAbnormal).length;
  bool get hasCritical => items.any((i) => i.status.isCritical);
  bool get hasAttachment =>
      attachmentFileName != null && attachmentFileName!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'reportDate': reportDate.toIso8601String(),
        'source': source.name,
        'items': items.map((e) => e.toJson()).toList(),
        'overallSummary': overallSummary,
        'suggestedSpecialty': suggestedSpecialty,
        if (rawReportText != null) 'rawReportText': rawReportText,
        if (notes != null) 'notes': notes,
        if (hospitalDiagnosis != null) 'hospitalDiagnosis': hospitalDiagnosis,
        if (userComplaintNote != null) 'userComplaintNote': userComplaintNote,
        if (attachmentFileName != null)
          'attachmentFileName': attachmentFileName,
        if (attachmentMimeType != null)
          'attachmentMimeType': attachmentMimeType,
        if (contextualInterpretation != null)
          'contextualInterpretation': contextualInterpretation,
        if (followUpQuestions.isNotEmpty)
          'followUpQuestions': followUpQuestions,
      };

  factory LabReportRecord.fromJson(Map<String, dynamic> json) {
    return LabReportRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      source: LabReportSourceX.fromName(json['source'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => LabTestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallSummary: json['overallSummary'] as String,
      suggestedSpecialty: json['suggestedSpecialty'] as String,
      rawReportText: json['rawReportText'] as String?,
      notes: json['notes'] as String?,
      hospitalDiagnosis: json['hospitalDiagnosis'] as String?,
      userComplaintNote: json['userComplaintNote'] as String?,
      attachmentFileName: json['attachmentFileName'] as String?,
      attachmentMimeType: json['attachmentMimeType'] as String?,
      contextualInterpretation: json['contextualInterpretation'] as String?,
      followUpQuestions: (json['followUpQuestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class LabTrendPoint {
  const LabTrendPoint({
    required this.date,
    required this.value,
    required this.status,
  });

  final DateTime date;
  final double value;
  final LabStatus status;
}

class LabParameterTrend {
  const LabParameterTrend({
    required this.code,
    required this.name,
    required this.unit,
    required this.refMin,
    required this.refMax,
    required this.points,
  });

  final String code;
  final String name;
  final String unit;
  final double? refMin;
  final double? refMax;

  /// Chronologically sorted oldest -> newest.
  final List<LabTrendPoint> points;

  LabTrendPoint get latest => points.last;
  LabTrendPoint? get previous =>
      points.length >= 2 ? points[points.length - 2] : null;

  double? get delta => previous == null ? null : latest.value - previous!.value;

  String get deltaSummary {
    final d = delta;
    if (d == null) return 'İlk ölçüm';
    if (d.abs() < 0.01) return 'Öncekiyle sabit';
    final sign = d > 0 ? '+' : '';
    return '$sign${_fmtNum(d)} $unit';
  }
}

String _fmtNum(double v) {
  if ((v - v.roundToDouble()).abs() < 0.001) {
    return v.round().toString();
  }
  return v.toStringAsFixed(1);
}
