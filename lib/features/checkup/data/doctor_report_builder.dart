import 'package:intl/intl.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// Structured non-diagnostic observation summary designed to help users share
/// chronological visual observations and questions during a doctor visit.
class DoctorVisitReport {
  const DoctorVisitReport({
    required this.currentResult,
    required this.previousCategoryResults,
    required this.recommendedSpecialty,
    required this.colorHex,
    required this.questionsForDoctor,
  });

  final AnalysisResult currentResult;
  final List<AnalysisResult> previousCategoryResults;
  final String recommendedSpecialty;
  final String colorHex;
  final List<String> questionsForDoctor;

  bool get hasTimelineHistory => previousCategoryResults.isNotEmpty;

  String toShareableText() {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    final buffer = StringBuffer()
      ..writeln('=== VisualCheckUp • Doktora Hazırlık Özeti ===')
      ..writeln('Tarih: ${dateFmt.format(currentResult.createdAt)}')
      ..writeln('Alan: ${currentResult.category.title}')
      ..writeln('Durum: ${currentResult.riskLevel.label}')
      ..writeln('Danışılabilecek Bölüm: $recommendedSpecialty')
      ..writeln('Özet: ${currentResult.summaryTitle}')
      ..writeln('Detay: ${currentResult.summaryDetail}')
      ..writeln(
        'Renk Kaydı: $colorHex (${currentResult.whiteBalanceCalibrated ? 'Beyaz referans ile kalibre edildi' : 'Standart ölçüm / renk kartı'})',
      );

    if (currentResult.baselineComparisonNote != null) {
      buffer.writeln(
        'Kişisel Normal Kıyas: ${currentResult.baselineComparisonNote}',
      );
    }

    if (currentResult.observations.isNotEmpty) {
      buffer.writeln('\nGözlemler:');
      for (final item in currentResult.observations) {
        buffer.writeln('- $item');
      }
    }

    if (currentResult.warningFlags.isNotEmpty) {
      buffer.writeln('\nDikkat Çeken Belirtiler:');
      for (final flag in currentResult.warningFlags) {
        buffer.writeln('! $flag');
      }
    }

    if (previousCategoryResults.isNotEmpty) {
      buffer.writeln('\nÖnceki Kayıtlarla Zaman Çizelgesi:');
      for (final prev in previousCategoryResults) {
        buffer.writeln(
          '- ${dateFmt.format(prev.createdAt)}: ${prev.summaryTitle} (${prev.riskLevel.label})',
        );
      }
    }

    if (questionsForDoctor.isNotEmpty) {
      buffer.writeln('\nDoktorunuza Sorabileceğiniz Sorular:');
      for (final q in questionsForDoctor) {
        buffer.writeln('? $q');
      }
    }

    buffer
      ..writeln('\n---')
      ..writeln(MedicalDisclaimer.shortBanner);
    return buffer.toString().trim();
  }
}

class DoctorReportBuilder {
  DoctorReportBuilder._();

  static DoctorVisitReport build({
    required AnalysisResult currentResult,
    List<AnalysisResult> allHistory = const [],
  }) {
    final previous = allHistory
        .where(
          (item) =>
              item.category == currentResult.category &&
              item.id != currentResult.id,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final rgb = currentResult.dominantColorValue & 0x00FFFFFF;
    final colorHex = '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';

    return DoctorVisitReport(
      currentResult: currentResult,
      previousCategoryResults: previous.take(4).toList(),
      recommendedSpecialty: currentResult.category.recommendedSpecialty,
      colorHex: colorHex,
      questionsForDoctor: _questionsFor(currentResult),
    );
  }

  static List<String> _questionsFor(AnalysisResult result) {
    final questions = <String>[];
    switch (result.category) {
      case CheckCategory.skinCondition:
        questions.addAll(const [
          'Bu leke/döküntü için dermatoskopi muayenesi gerekir mi?',
          'Boyut, renk veya kenar değişimini ne sıklıkla takip etmeliyim?',
          'Güneşten korunma veya topikal bakım için ne önerirsiniz?',
        ]);
      case CheckCategory.eye:
        questions.addAll(const [
          'Göz akındaki bu renk değişimi ışık/yorgunluk kaynaklı mı yoksa kan tahlili (bilirubin vb.) gerekir mi?',
          'Kızarıklık veya kuruluk için güvenli damla öneriniz nedir?',
        ]);
      case CheckCategory.nail:
        questions.addAll(const [
          'Tırnaktaki bu renk/yapı değişimi mantar, travma veya vitamin/demir eksikliği ile ilişkili olabilir mi?',
          'Kan tahlili veya mikroskobik mantar incelemesi gerekir mi?',
        ]);
      case CheckCategory.tongue:
        questions.addAll(const [
          'Dildeki bu görünüm ağız kuruluğu, mantar veya vitamin eksikliği ile ilgili olabilir mi?',
          'Hangi durumlarda ileri inceleme gerekir?',
        ]);
      case CheckCategory.face:
        questions.addAll(const [
          'Cilt tonundaki bu solgunluk/kızarıklık için tam kan sayımı veya dermatoloji değerlendirmesi önerir misiniz?',
          'Günlük bakım ve güneş koruması açısından nelere dikkat etmeliyim?',
        ]);
      case CheckCategory.urine:
        questions.addAll(const [
          'Bu idrar rengi hidrasyon/beslenme kaynaklı mı yoksa tam idrar tahlili (TİT) yaptırmalı mıyım?',
          'Kullandığım ilaç veya takviyeler bu renk değişimine yol açabilir mi?',
        ]);
      case CheckCategory.stool:
        questions.addAll(const [
          'Bu renk değişimi diyet veya ilaç (demir/bizmut vb.) kaynaklı olabilir mi?',
          'Gaitada gizli kan veya kan tahlili yaptırmam gerekir mi?',
        ]);
    }

    if (result.riskLevel == RiskLevel.urgent) {
      questions.insert(
        0,
        'Bu bulgu için ne kadar kısa sürede ileri tetkik yaptırmalıyım?',
      );
    }

    return questions;
  }
}
