import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';

/// Generates and exports clinical health summary reports in PDF format for
/// patients, doctors, and family members.
class HealthReportPdfService {
  HealthReportPdfService._();
  static final HealthReportPdfService instance = HealthReportPdfService._();

  /// Generates the raw PDF bytes for the health report.
  Future<List<int>> generatePdfBytes({
    required String patientName,
    required List<FollowUpTrackStatus> tracks,
    String? chronicConditions,
    String? bloodPressureStr,
    String? bloodSugarStr,
    List<String> medications = const [],
    List<String> recentFindings = const [],
  }) async {
    final document = PdfDocument();
    document.pageSettings.margins.all = 36;

    final page = document.pages.add();
    final graphics = page.graphics;
    final size = page.getClientSize();

    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final subTitleFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final smallFont = PdfStandardFont(PdfFontFamily.helvetica, 8);

    final primaryColor = PdfColor(11, 110, 110); // Teal
    final darkColor = PdfColor(20, 21, 34);
    final grayColor = PdfColor(120, 120, 120);

    double y = 10;

    // Header Banner
    graphics.drawString(
      'VisualCheckUp — Klinik & Bireysel Saglik Karnesi',
      titleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(0, y, size.width, 24),
    );
    y += 28;

    final nowFormatted = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
    graphics.drawString(
      'Hasta / Danisan: $patientName  |  Tarih: $nowFormatted',
      bodyFont,
      brush: PdfSolidBrush(darkColor),
      bounds: Rect.fromLTWH(0, y, size.width, 16),
    );
    y += 20;

    // Divider
    graphics.drawLine(
      PdfPen(primaryColor, width: 1.5),
      Offset(0, y),
      Offset(size.width, y),
    );
    y += 14;

    // Section 1: Vital Signs & Chronic Profile
    graphics.drawString(
      '1. Vital Parametreler ve Kronik Saglik Durumu',
      subTitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(0, y, size.width, 16),
    );
    y += 20;

    final vitalsText = [
      'Tansiyon: ${bloodPressureStr ?? "Normal / Takipte"}',
      'Acik Kan Sekeri: ${bloodSugarStr ?? "Normal aralikta"}',
      if (chronicConditions != null && chronicConditions.isNotEmpty)
        'Kronik Takip: $chronicConditions',
    ].join('   |   ');

    graphics.drawString(
      vitalsText,
      bodyFont,
      brush: PdfSolidBrush(darkColor),
      bounds: Rect.fromLTWH(0, y, size.width, 16),
    );
    y += 24;

    // Section 2: Visual Checkup & Organ Findings
    graphics.drawString(
      '2. Gorsel Saglik Taramalari ve Bulgular (Goz, Tirnak, Dil, Cilt, Idrar)',
      subTitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(0, y, size.width, 16),
    );
    y += 20;

    if (recentFindings.isNotEmpty) {
      for (final finding in recentFindings) {
        graphics.drawString(
          '• $finding',
          bodyFont,
          brush: PdfSolidBrush(darkColor),
          bounds: Rect.fromLTWH(8, y, size.width - 16, 16),
        );
        y += 16;
      }
    } else {
      graphics.drawString(
        '• Yapilan son gorsel analizlerde acil hekim yonlendirmesi gerektiren anormal bulguya rastlanmamistir.',
        bodyFont,
        brush: PdfSolidBrush(darkColor),
        bounds: Rect.fromLTWH(8, y, size.width - 16, 16),
      );
      y += 16;
    }
    y += 12;

    // Section 3: Follow-Up & Adherence Status
    graphics.drawString(
      '3. Bireysel Takip Plani ve Aliskanlik Uyumu',
      subTitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(0, y, size.width, 16),
    );
    y += 20;

    for (final t in tracks.take(6)) {
      final statusText = t.isDueNow
          ? 'Vadesi Doldu / Bugun Yapilmali'
          : '${t.daysRemaining} gun kaldi';
      graphics.drawString(
        '• ${t.track.title}: $statusText (Aralik: ${t.track.intervalDays} gun)',
        bodyFont,
        brush: PdfSolidBrush(darkColor),
        bounds: Rect.fromLTWH(8, y, size.width - 16, 16),
      );
      y += 16;
    }
    y += 12;

    // Section 4: Medications
    if (medications.isNotEmpty) {
      graphics.drawString(
        '4. Duzenli Kullanilan Ilaclar ve Hatirlaticilar',
        subTitleFont,
        brush: PdfSolidBrush(primaryColor),
        bounds: Rect.fromLTWH(0, y, size.width, 16),
      );
      y += 20;

      for (final med in medications) {
        graphics.drawString(
          '• $med',
          bodyFont,
          brush: PdfSolidBrush(darkColor),
          bounds: Rect.fromLTWH(8, y, size.width - 16, 16),
        );
        y += 16;
      }
      y += 14;
    }

    // Footer & Disclaimer
    final footerY = size.height - 30;
    graphics.drawLine(
      PdfPen(grayColor, width: 0.5),
      Offset(0, footerY - 8),
      Offset(size.width, footerY - 8),
    );
    graphics.drawString(
      'YASAL UYARI: Bu rapor hekim teshisi veya recete yerine gecmez. Muayenede hekiminize bilgi saglamak amaciyla olusturulmustur.',
      smallFont,
      brush: PdfSolidBrush(grayColor),
      bounds: Rect.fromLTWH(0, footerY, size.width, 24),
    );

    final List<int> bytes = await document.save();
    document.dispose();
    return bytes;
  }

  /// Creates a multi-section PDF document and opens the OS share sheet.
  Future<String?> generateAndShareHealthReport({
    required String patientName,
    required List<FollowUpTrackStatus> tracks,
    String? chronicConditions,
    String? bloodPressureStr,
    String? bloodSugarStr,
    List<String> medications = const [],
    List<String> recentFindings = const [],
  }) async {
    try {
      final bytes = await generatePdfBytes(
        patientName: patientName,
        tracks: tracks,
        chronicConditions: chronicConditions,
        bloodPressureStr: bloodPressureStr,
        bloodSugarStr: bloodSugarStr,
        medications: medications,
        recentFindings: recentFindings,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/VisualCheckUp_Saglik_Karnesi.pdf');
      await file.writeAsBytes(bytes, flush: true);

      final nowFormatted = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
      // Open share dialog
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: 'VisualCheckUp_Saglik_Karnesi.pdf')],
        text: 'VisualCheckUp Saglik Karnesi — $patientName ($nowFormatted)',
      );

      return file.path;
    } catch (e) {
      debugPrint('[PDF Error] Failed to generate/share PDF: $e');
      return null;
    }
  }
}
