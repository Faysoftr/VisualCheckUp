import 'package:intl/intl.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

class CrossModuleInsight {
  const CrossModuleInsight({
    required this.title,
    required this.detail,
    required this.sourceLabel,
  });

  final String title;
  final String detail;
  final String sourceLabel;
}

/// Correlates visual checkup findings (Eye, Nail, Tongue, Face, Skin, Urine)
/// with the user's latest saved blood lab reports, blood pressure, and blood
/// sugar logs to surface holistic, doctor-ready connections.
class CrossModuleHealthCorrelator {
  CrossModuleHealthCorrelator._();

  static List<CrossModuleInsight> correlate({
    required AnalysisResult visualResult,
    required List<LabReportRecord> labReports,
    List<BloodPressureReading> bpReadings = const [],
    List<BloodSugarReading> sugarReadings = const [],
    List<AnalysisResult> visualHistory = const [],
  }) {
    final insights = <CrossModuleInsight>[];
    final df = DateFormat('dd.MM.yyyy');
    final visualText =
        '${visualResult.summaryTitle} ${visualResult.summaryDetail} ${visualResult.observations.join(' ')}'
            .toLowerCase();

    final latestLab = labReports.isEmpty
        ? null
        : ([...labReports]..sort((a, b) => b.reportDate.compareTo(a.reportDate)))
            .first;

    if (latestLab != null && latestLab.items.isNotEmpty) {
      final byCode = {for (final i in latestLab.items) i.code: i};
      final labDateStr = df.format(latestLab.reportDate);

      bool isLow(String code) =>
          byCode[code]?.status == LabStatus.low ||
          byCode[code]?.status == LabStatus.criticalLow;
      bool isHigh(String code) =>
          byCode[code]?.status == LabStatus.high ||
          byCode[code]?.status == LabStatus.criticalHigh;

      // 1. Anemia / Iron / B12 / Folate <-> Nail, Tongue, Face, Eye conjunctiva pallor
      if (visualResult.category == CheckCategory.nail ||
          visualResult.category == CheckCategory.tongue ||
          visualResult.category == CheckCategory.face ||
          visualResult.category == CheckCategory.eye) {
        final lowAnemiaMarkers = [
          if (isLow('HGB')) byCode['HGB']!,
          if (isLow('HCT')) byCode['HCT']!,
          if (isLow('IRON')) byCode['IRON']!,
          if (isLow('FERRITIN')) byCode['FERRITIN']!,
          if (isLow('B12')) byCode['B12']!,
          if (isLow('FOLATE')) byCode['FOLATE']!,
        ];
        final visualMatchesAnemia = visualText.contains('soluk') ||
            visualText.contains('anemi') ||
            visualText.contains('kırıl') ||
            visualText.contains('soyul') ||
            visualText.contains('kaşık') ||
            visualText.contains('beyaz') ||
            visualText.contains('yarık') ||
            visualText.contains('çatlak') ||
            (visualResult.category != CheckCategory.eye &&
                visualResult.riskLevel != RiskLevel.normal);

        if (lowAnemiaMarkers.isNotEmpty && visualMatchesAnemia) {
          final markerText = lowAnemiaMarkers
              .map((e) => '${e.code} (${e.formattedValue})')
              .join(', ');
          insights.add(
            CrossModuleInsight(
              title: 'Kan Tahliliyle Örtüşen Bulgu (Demir / Vitamin Profili)',
              detail:
                  '$labDateStr tarihli tahlilinizde düşük görünen $markerText değerleri, tırnak/dil/göz kapağı/yüzdeki solukluk, kırılganlık veya çatlak görünümüyle ilişkili olabilir. İki kaydı doktorunuza birlikte göstermeniz faydalı olur.',
              sourceLabel: 'Tahlil • $labDateStr',
            ),
          );
        }
      }

      // 2. Liver enzymes (ALT/AST/GGT) <-> Eye/Skin/Urine yellowish tint
      if (visualResult.category == CheckCategory.eye ||
          visualResult.category == CheckCategory.face ||
          visualResult.category == CheckCategory.urine) {
        final highLiver = [
          if (isHigh('ALT')) byCode['ALT']!,
          if (isHigh('AST')) byCode['AST']!,
          if (isHigh('GGT')) byCode['GGT']!,
        ];
        final visualYellow =
            visualText.contains('sarı') || visualText.contains('koyu');
        if (highLiver.isNotEmpty && visualYellow) {
          final markerText = highLiver
              .map((e) => '${e.code} (${e.formattedValue})')
              .join(', ');
          insights.add(
            CrossModuleInsight(
              title: 'Karaciğer Enzimleriyle Birlikte Değerlendirme',
              detail:
                  '$labDateStr tarihli tahlilinizde yüksek saptanan $markerText değerleri varken göz akında, ciltte veya idrarda sarımsı/koyu ton görülmesi hekim değerlendirmesi gerektirir.',
              sourceLabel: 'Tahlil • $labDateStr',
            ),
          );
        }
      }

      // 3. Infection / Inflammation (WBC/CRP/NEU%) <-> Eye redness, Tongue coating/fissures, Skin redness
      if (visualResult.category == CheckCategory.eye ||
          visualResult.category == CheckCategory.tongue ||
          visualResult.category == CheckCategory.skinCondition) {
        final highInflam = [
          if (isHigh('WBC')) byCode['WBC']!,
          if (isHigh('CRP')) byCode['CRP']!,
          if (isHigh('NEU_PCT')) byCode['NEU_PCT']!,
        ];
        if (highInflam.isNotEmpty && visualResult.riskLevel != RiskLevel.normal) {
          final markerText = highInflam
              .map((e) => '${e.code} (${e.formattedValue})')
              .join(', ');
          insights.add(
            CrossModuleInsight(
              title: 'Enfeksiyon / İltihap Belirteçleriyle Bağlantı',
              detail:
                  '$labDateStr tarihli tahlilinizde yüksek görünen $markerText değerleriyle bu görsel bulgu (kızarıklık/pas/hassasiyet) aynı döneme denk geliyor olabilir.',
              sourceLabel: 'Tahlil • $labDateStr',
            ),
          );
        }
      }

      // 4. Blood Sugar / HbA1c <-> Tongue dryness/fissures, Skin, Urine
      if (isHigh('GLU') || isHigh('HBA1C')) {
        if (visualResult.category == CheckCategory.tongue ||
            visualResult.category == CheckCategory.skinCondition ||
            visualResult.category == CheckCategory.urine) {
          final markers = [
            if (isHigh('GLU')) 'Glukoz (${byCode['GLU']!.formattedValue})',
            if (isHigh('HBA1C')) 'HbA1c (${byCode['HBA1C']!.formattedValue})',
          ].join(', ');
          insights.add(
            CrossModuleInsight(
              title: 'Kan Şekeri Profiliyle İlişkili Takip',
              detail:
                  '$labDateStr tarihli tahlilinizde yüksek olan $markers nedeniyle ağız/dil kuruluğu, cilt hassasiyeti ve idrar rengi takibi önemlidir.',
              sourceLabel: 'Tahlil • $labDateStr',
            ),
          );
        }
      }
    }

    // 5. Elevated Blood Pressure <-> Eye redness / Face flushing
    if (bpReadings.isNotEmpty &&
        (visualResult.category == CheckCategory.eye ||
            visualResult.category == CheckCategory.face) &&
        visualResult.riskLevel != RiskLevel.normal) {
      final latestBp = ([...bpReadings]
            ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)))
          .first;
      if (latestBp.systolic >= 140 || latestBp.diastolic >= 90) {
        insights.add(
          CrossModuleInsight(
            title: 'Yüksek Tansiyon Kaydıyla Birlikte Değerlendirin',
            detail:
                '${df.format(latestBp.recordedAt)} tarihli son tansiyon ölçümünüz ${latestBp.formatted} (${latestBp.category.label}). Göz kanlanması veya yüzde kızarıklık eşlik ediyorsa tansiyonunuzu tekrar ölçmeniz önerilir.',
            sourceLabel: 'Tansiyon • ${df.format(latestBp.recordedAt)}',
          ),
        );
      }
    }

    // 6. Elevated Home Blood Sugar <-> Tongue / Urine
    if (sugarReadings.isNotEmpty &&
        (visualResult.category == CheckCategory.tongue ||
            visualResult.category == CheckCategory.urine)) {
      final latestSugar = ([...sugarReadings]
            ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)))
          .first;
      if (latestSugar.valueMgDl >= 180) {
        insights.add(
          CrossModuleInsight(
            title: 'Yüksek Şeker Ölçümüyle İlişki',
            detail:
                '${df.format(latestSugar.recordedAt)} tarihli kan şekeri ölçümünüz ${latestSugar.formatted}. Yüksek şeker dönemlerinde ağız kuruluğu ve sıvı ihtiyacı artabilir.',
            sourceLabel: 'Kan Şekeri • ${df.format(latestSugar.recordedAt)}',
          ),
        );
      }
    }

    // 7. Multi-Module Visual Triads across recent visual checks (within 14 days)
    if (visualHistory.isNotEmpty) {
      final recentOthers = visualHistory.where((r) {
        if (r.id == visualResult.id || r.category == visualResult.category) {
          return false;
        }
        final diffDays = visualResult.createdAt.difference(r.createdAt).inDays.abs();
        return diffDays <= 14;
      }).toList();

      bool hasAnyCue(AnalysisResult r, List<String> keywords) {
        final combined =
            '${r.summaryTitle} ${r.summaryDetail} ${r.matchedFindingIds.join(' ')}'
                .toLowerCase();
        return keywords.any(combined.contains);
      }

      // 7a. Hepatobiliary / Jaundice Triad: Eye/Face yellow + Dark urine / Clay stool
      final currentJaundiceCue =
          (visualResult.category == CheckCategory.eye &&
                  hasAnyCue(visualResult, ['sarı', 'jaundice'])) ||
              (visualResult.category == CheckCategory.urine &&
                  hasAnyCue(visualResult, ['kehribar', 'çay', 'dark_amber'])) ||
              (visualResult.category == CheckCategory.stool &&
                  hasAnyCue(visualResult, ['kil', 'beyaz', 'pale_clay'])) ||
              (visualResult.category == CheckCategory.face &&
                  hasAnyCue(visualResult, ['sarı', 'jaundice']));
      if (currentJaundiceCue) {
        final partner = recentOthers.where((r) {
          if (r.category == CheckCategory.eye || r.category == CheckCategory.face) {
            return hasAnyCue(r, ['sarı', 'jaundice']);
          }
          if (r.category == CheckCategory.urine) {
            return hasAnyCue(r, ['kehribar', 'çay', 'dark_amber']);
          }
          if (r.category == CheckCategory.stool) {
            return hasAnyCue(r, ['kil', 'beyaz', 'pale_clay']);
          }
          return false;
        }).firstOrNull;
        if (partner != null) {
          insights.add(
            CrossModuleInsight(
              title: 'Çoklu Modül Sarılık / Safra Yolu Uyarısı',
              detail:
                  '${partner.category.title} kaydınızdaki "${partner.summaryTitle}" bulgusu ile bugünkü ${visualResult.category.title} bulgunuz birlikte görüldüğünde karaciğer/safra yolu (bilirubin) değerlendirmesi için gecikmeden Dahiliye uzmanına başvurmanız önerilir.',
              sourceLabel: 'Çapraz Görsel • ${df.format(partner.createdAt)}',
            ),
          );
        }
      }

      // 7b. Multi-Site Anemia Pallor Triad: Nail + Tongue + Eye conjunctiva + Face
      final currentAnemiaCue = (visualResult.category == CheckCategory.nail ||
              visualResult.category == CheckCategory.tongue ||
              visualResult.category == CheckCategory.eye ||
              visualResult.category == CheckCategory.face) &&
          hasAnyCue(visualResult, [
            'soluk',
            'anemi',
            'pale',
            'conjunctiva_pallor',
            'kaşık',
            'yarık',
          ]);
      if (currentAnemiaCue) {
        final partner = recentOthers.where((r) {
          return (r.category == CheckCategory.nail ||
                  r.category == CheckCategory.tongue ||
                  r.category == CheckCategory.eye ||
                  r.category == CheckCategory.face) &&
              hasAnyCue(r, [
                'soluk',
                'anemi',
                'pale',
                'conjunctiva_pallor',
                'kaşık',
                'yarık',
              ]);
        }).firstOrNull;
        if (partner != null) {
          insights.add(
            CrossModuleInsight(
              title: 'Çoklu Bölge Anemi (Kansızlık) Ön Farkındalığı',
              detail:
                  'Hem ${partner.category.title} hem de ${visualResult.category.title} taramalarında solukluk/eksiklik ipucu saptandı. Birden fazla bölgede solukluk görülmesi tam kan sayımı (HGB, Ferritin, Demir, B12, Folat) kontrolünü destekler.',
              sourceLabel: 'Çapraz Görsel • ${df.format(partner.createdAt)}',
            ),
          );
        }
      }

      // 7c. Cardiopulmonary Oxygenation / Cyanosis Triad: Nail + Tongue + Face
      final currentCyanosisCue = (visualResult.category == CheckCategory.nail ||
              visualResult.category == CheckCategory.tongue ||
              visualResult.category == CheckCategory.face) &&
          hasAnyCue(visualResult, ['mor', 'mavi', 'siyanoz', 'cyanot']);
      if (currentCyanosisCue) {
        final partner = recentOthers.where((r) {
          return (r.category == CheckCategory.nail ||
                  r.category == CheckCategory.tongue ||
                  r.category == CheckCategory.face) &&
              hasAnyCue(r, ['mor', 'mavi', 'siyanoz', 'cyanot']);
        }).firstOrNull;
        if (partner != null) {
          insights.add(
            CrossModuleInsight(
              title: 'Çoklu Bölge Morarma (Oksijenlenme / Dolaşım Uyarısı)',
              detail:
                  'Hem ${partner.category.title} hem de ${visualResult.category.title} kayıtlarında mor/mavimsi ton saptandı. Nefes darlığı, çarpıntı veya göğüs rahatsızlığı eşlik ediyorsa acil tıbbi değerlendirme alın.',
              sourceLabel: 'Çapraz Görsel • ${df.format(partner.createdAt)}',
            ),
          );
        }
      }
    }

    return insights;
  }
}
