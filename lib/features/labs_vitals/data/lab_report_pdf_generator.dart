import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

/// Generates a print-ready, Turkish-Unicode clinical summary PDF for doctor
/// visits and shares/saves it via the native OS share sheet.
class LabReportPdfGenerator {
  LabReportPdfGenerator._();

  static Future<Uint8List> generateSummaryPdf({
    required LabReportRecord report,
    LabReportRecord? previousReport,
  }) async {
    final document = sf.PdfDocument();
    document.pageSettings.size = sf.PdfPageSize.a4;
    document.pageSettings.margins.all = 36;

    final fonts = await _loadFonts();
    final df = DateFormat('dd.MM.yyyy');
    final primaryTeal = sf.PdfColor(15, 118, 110);
    final softTint = sf.PdfColor(240, 250, 248);
    final darkInk = sf.PdfColor(23, 35, 34);
    final mutedInk = sf.PdfColor(92, 108, 106);

    var page = document.pages.add();
    final pageWidth = page.getClientSize().width;
    var y = 0.0;

    // 1. Header Banner
    page.graphics.drawRectangle(
      brush: sf.PdfSolidBrush(primaryTeal),
      bounds: Rect.fromLTWH(0, y, pageWidth, 62),
    );
    page.graphics.drawString(
      'VisualCheckUp • Doktor Görüşmesi Tahlil Özeti',
      fonts.title,
      brush: sf.PdfBrushes.white,
      bounds: Rect.fromLTWH(14, y + 12, pageWidth - 28, 22),
    );
    page.graphics.drawString(
      'Rapor Tarihi: ${df.format(report.reportDate)}   |   Danışılabilecek Bölüm: ${report.suggestedSpecialty}',
      fonts.small,
      brush: sf.PdfSolidBrush(sf.PdfColor(220, 245, 240)),
      bounds: Rect.fromLTWH(14, y + 36, pageWidth - 28, 18),
    );
    y += 74;

    // 2. Metadata & Summary Card
    final metaLines = <String>[
      'Rapor: ${report.title}',
      if (report.hasAttachment) 'Ekli Belge: ${report.attachmentFileName}',
      if (report.hospitalDiagnosis != null)
        'Hastane / Doktor Teşhisi: ${report.hospitalDiagnosis}',
      if (report.userComplaintNote != null)
        'Şikayet / Not: ${report.userComplaintNote}',
      'Genel Özet: ${report.overallSummary}',
    ];
    final metaText = metaLines.join('\n');
    final metaLayout = sf.PdfTextElement(
      text: metaText,
      font: fonts.body,
      brush: sf.PdfSolidBrush(darkInk),
    ).draw(
      page: page,
      bounds: Rect.fromLTWH(10, y + 8, pageWidth - 20, 0),
    )!;
    final boxHeight = (metaLayout.bounds.bottom - y) + 10;
    page.graphics.drawRectangle(
      pen: sf.PdfPen(sf.PdfColor(195, 224, 219), width: 0.8),
      bounds: Rect.fromLTWH(0, y, pageWidth, boxHeight),
    );
    page = metaLayout.page;
    y = metaLayout.bounds.bottom + 18;

    // 3. Holistic Clinical Evaluation / Correlations
    if (report.contextualInterpretation != null &&
        report.contextualInterpretation!.trim().isNotEmpty) {
      final heading = sf.PdfTextElement(
        text: 'Bütüncül Ön Değerlendirme & Klinik Örüntüler',
        font: fonts.section,
        brush: sf.PdfSolidBrush(primaryTeal),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
      )!;
      page = heading.page;
      y = heading.bounds.bottom + 6;

      final bodyRes = sf.PdfTextElement(
        text: report.contextualInterpretation!.trim(),
        font: fonts.body,
        brush: sf.PdfSolidBrush(darkInk),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: sf.PdfLayoutFormat(layoutType: sf.PdfLayoutType.paginate),
      )!;
      page = bodyRes.page;
      y = bodyRes.bounds.bottom + 16;
    }

    // 4. Structured Lab Values Table (with previous-report comparison if available)
    if (report.items.isNotEmpty) {
      final prevByCode = <String, LabTestItem>{
        if (previousReport != null)
          for (final item in previousReport.items) item.code: item,
      };
      final hasPrev = prevByCode.isNotEmpty;

      final tableTitle = sf.PdfTextElement(
        text: hasPrev
            ? 'Tahlil Sonuç Tablosu (${report.items.length} Parametre • Önceki Rapor: ${df.format(previousReport!.reportDate)})'
            : 'Tahlil Sonuç Tablosu (${report.items.length} Parametre)',
        font: fonts.section,
        brush: sf.PdfSolidBrush(primaryTeal),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
      )!;
      page = tableTitle.page;
      y = tableTitle.bounds.bottom + 8;

      final grid = sf.PdfGrid();
      grid.columns.add(count: hasPrev ? 5 : 4);
      grid.headers.add(1);

      final header = grid.headers[0];
      header.cells[0].value = 'Parametre';
      header.cells[1].value = 'Sonuç';
      header.cells[2].value = 'Referans';
      header.cells[3].value = 'Durum';
      if (hasPrev) {
        header.cells[4].value = 'Öncekiyle Kıyas';
      }

      header.style = sf.PdfGridRowStyle(
        backgroundBrush: sf.PdfSolidBrush(primaryTeal),
        textBrush: sf.PdfBrushes.white,
        font: fonts.tableHeader,
      );

      for (var i = 0; i < report.items.length; i++) {
        final item = report.items[i];
        final row = grid.rows.add();
        row.cells[0].value = item.name;
        row.cells[1].value = item.formattedValue;
        row.cells[2].value = item.referenceRangeText;
        row.cells[3].value = item.status.label;

        if (hasPrev) {
          final prev = prevByCode[item.code];
          if (prev == null) {
            row.cells[4].value = '-';
          } else {
            final d = item.value - prev.value;
            if (d.abs() < 0.005) {
              row.cells[4].value = 'Sabit';
            } else {
              final sign = d > 0 ? '+' : '';
              row.cells[4].value = '$sign${_fmtCompact(d)} (önceki: ${_fmtCompact(prev.value)})';
            }
          }
        }

        final isAbnormal = item.status.isAbnormal;
        final bg = isAbnormal
            ? (item.status.isCritical
                ? sf.PdfColor(255, 232, 232)
                : sf.PdfColor(255, 245, 230))
            : (i.isEven ? sf.PdfColor(255, 255, 255) : softTint);

        row.style = sf.PdfGridRowStyle(
          backgroundBrush: sf.PdfSolidBrush(bg),
          textBrush: sf.PdfSolidBrush(
            isAbnormal ? sf.PdfColor(175, 55, 35) : darkInk,
          ),
          font: isAbnormal ? fonts.tableBold : fonts.tableBody,
        );
      }

      grid.style = sf.PdfGridStyle(
        cellPadding: sf.PdfPaddings(left: 6, right: 6, top: 5, bottom: 5),
        borderOverlapStyle: sf.PdfBorderOverlapStyle.inside,
      );
      grid.repeatHeader = true;

      final gridRes = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: sf.PdfLayoutFormat(layoutType: sf.PdfLayoutType.paginate),
      )!;
      page = gridRes.page;
      y = gridRes.bounds.bottom + 16;
    }

    // 5. Follow-up Questions for Doctor
    if (report.followUpQuestions.isNotEmpty) {
      if (y > page.getClientSize().height - 90) {
        page = document.pages.add();
        y = 0;
      }
      final qHead = sf.PdfTextElement(
        text: 'Doktorunuza Sorabileceğiniz Sorular',
        font: fonts.section,
        brush: sf.PdfSolidBrush(primaryTeal),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
      )!;
      page = qHead.page;
      y = qHead.bounds.bottom + 6;

      final qText = report.followUpQuestions.map((q) => '• $q').join('\n');
      final qBody = sf.PdfTextElement(
        text: qText,
        font: fonts.body,
        brush: sf.PdfSolidBrush(darkInk),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: sf.PdfLayoutFormat(layoutType: sf.PdfLayoutType.paginate),
      )!;
      page = qBody.page;
      y = qBody.bounds.bottom + 14;
    }

    // 6. Medical Disclaimer Footer
    if (y > page.getClientSize().height - 45) {
      page = document.pages.add();
      y = 0;
    }
    sf.PdfTextElement(
      text: MedicalDisclaimer.shortBanner,
      font: fonts.small,
      brush: sf.PdfSolidBrush(mutedInk),
    ).draw(
      page: page,
      bounds: Rect.fromLTWH(0, y, pageWidth, 0),
    );

    final bytes = Uint8List.fromList(await document.save());
    document.dispose();
    return bytes;
  }

  /// Generates the summary PDF, writes it to a temporary file, and opens the
  /// native Android/iOS Share sheet so the user can save, print, or send it
  /// to their doctor.
  static Future<File> saveAndShareSummaryPdf({
    required LabReportRecord report,
    LabReportRecord? previousReport,
  }) async {
    final pdfBytes = await generateSummaryPdf(
      report: report,
      previousReport: previousReport,
    );
    final dir = await getTemporaryDirectory();
    final dateTag = DateFormat('yyyy-MM-dd').format(report.reportDate);
    final filePath = '${dir.path}${Platform.pathSeparator}VisualCheckUp_Tahlil_Ozeti_$dateTag.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'VisualCheckUp Tahlil Özeti ($dateTag)',
        text: 'Doktor görüşmesi için hazırlanmış kan tahlili özet raporu.',
      ),
    );
    return file;
  }

  /// Generates a unified A4 "Holistic Doctor File PDF" combining the user's
  /// latest blood test report, blood pressure & blood sugar logs, and recent
  /// visual checks in one doctor-ready file.
  static Future<Uint8List> generateHolisticDoctorPdf({
    required String profileName,
    List<LabReportRecord> labReports = const [],
    List<BloodPressureReading> bpReadings = const [],
    List<BloodSugarReading> sugarReadings = const [],
    List<AnalysisResult> visualChecks = const [],
  }) async {
    final document = sf.PdfDocument();
    document.pageSettings.size = sf.PdfPageSize.a4;
    document.pageSettings.margins.all = 36;

    final fonts = await _loadFonts();
    final df = DateFormat('dd.MM.yyyy');
    final dtf = DateFormat('dd.MM.yyyy HH:mm');
    final primaryTeal = sf.PdfColor(15, 118, 110);
    final darkInk = sf.PdfColor(23, 35, 34);
    final mutedInk = sf.PdfColor(92, 108, 106);

    var page = document.pages.add();
    final pageWidth = page.getClientSize().width;
    var y = 0.0;

    page.graphics.drawRectangle(
      brush: sf.PdfSolidBrush(primaryTeal),
      bounds: Rect.fromLTWH(0, y, pageWidth, 60),
    );
    page.graphics.drawString(
      'VisualCheckUp • Bütüncül Doktor Dosyası',
      fonts.title,
      brush: sf.PdfBrushes.white,
      bounds: Rect.fromLTWH(14, y + 10, pageWidth - 28, 22),
    );
    page.graphics.drawString(
      'Profil: $profileName   |   Oluşturma: ${df.format(DateTime.now())}',
      fonts.small,
      brush: sf.PdfSolidBrush(sf.PdfColor(220, 245, 240)),
      bounds: Rect.fromLTWH(14, y + 34, pageWidth - 28, 18),
    );
    y += 74;

    // 1. Blood Pressure & Blood Sugar Summary
    if (bpReadings.isNotEmpty || sugarReadings.isNotEmpty) {
      final h = sf.PdfTextElement(
        text: 'Tansiyon & Kan Şekeri Özeti',
        font: fonts.section,
        brush: sf.PdfSolidBrush(primaryTeal),
      ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0))!;
      page = h.page;
      y = h.bounds.bottom + 6;

      final lines = <String>[];
      if (bpReadings.isNotEmpty) {
        final avgSys = bpReadings.map((e) => e.systolic).reduce((a, b) => a + b) /
            bpReadings.length;
        final avgDia = bpReadings.map((e) => e.diastolic).reduce((a, b) => a + b) /
            bpReadings.length;
        lines.add(
          'Tansiyon (${bpReadings.length} ölçüm • Ortalama: ${avgSys.round()}/${avgDia.round()} mmHg):',
        );
        for (final bp in bpReadings.take(8)) {
          final pulse = bp.pulse != null ? ' • Nabız ${bp.pulse}' : '';
          lines.add('  - ${dtf.format(bp.recordedAt)}: ${bp.formatted}$pulse (${bp.category.label})');
        }
      }
      if (sugarReadings.isNotEmpty) {
        final avgS = sugarReadings.map((e) => e.valueMgDl).reduce((a, b) => a + b) /
            sugarReadings.length;
        lines.add(
          'Kan Şekeri (${sugarReadings.length} ölçüm • Ortalama: ${avgS.round()} mg/dL):',
        );
        for (final s in sugarReadings.take(8)) {
          lines.add('  - ${dtf.format(s.recordedAt)}: ${s.formatted} [${s.measurementType.label}] (${s.category.label})');
        }
      }

      final body = sf.PdfTextElement(
        text: lines.join('\n'),
        font: fonts.body,
        brush: sf.PdfSolidBrush(darkInk),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: sf.PdfLayoutFormat(layoutType: sf.PdfLayoutType.paginate),
      )!;
      page = body.page;
      y = body.bounds.bottom + 14;
    }

    // 2. Latest Lab Report Summary
    if (labReports.isNotEmpty) {
      final latest = labReports.first;
      final h = sf.PdfTextElement(
        text: 'Son Kan Tahlili (${df.format(latest.reportDate)} • ${latest.title})',
        font: fonts.section,
        brush: sf.PdfSolidBrush(primaryTeal),
      ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0))!;
      page = h.page;
      y = h.bounds.bottom + 6;

      final labLines = <String>[
        latest.overallSummary,
        if (latest.contextualInterpretation != null)
          latest.contextualInterpretation!,
        for (final item in latest.items.where((e) => e.status.isAbnormal))
          '  ! ${item.name}: ${item.formattedValue} [${item.status.label}] (Ref: ${item.referenceRangeText})',
      ];
      final body = sf.PdfTextElement(
        text: labLines.join('\n'),
        font: fonts.body,
        brush: sf.PdfSolidBrush(darkInk),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: sf.PdfLayoutFormat(layoutType: sf.PdfLayoutType.paginate),
      )!;
      page = body.page;
      y = body.bounds.bottom + 14;
    }

    // 3. Recent Visual Checkups
    if (visualChecks.isNotEmpty) {
      final h = sf.PdfTextElement(
        text: 'Son Görsel Kontroller (${visualChecks.length} kayıt)',
        font: fonts.section,
        brush: sf.PdfSolidBrush(primaryTeal),
      ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0))!;
      page = h.page;
      y = h.bounds.bottom + 6;

      final vLines = visualChecks.take(10).map((c) {
        return '• ${df.format(c.createdAt)} — ${c.category.title}: ${c.summaryTitle} [${c.riskLevel.label}]';
      }).join('\n');

      final body = sf.PdfTextElement(
        text: vLines,
        font: fonts.body,
        brush: sf.PdfSolidBrush(darkInk),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, y, pageWidth, 0),
        format: sf.PdfLayoutFormat(layoutType: sf.PdfLayoutType.paginate),
      )!;
      page = body.page;
      y = body.bounds.bottom + 14;
    }

    if (y > page.getClientSize().height - 45) {
      page = document.pages.add();
      y = 0;
    }
    sf.PdfTextElement(
      text: MedicalDisclaimer.shortBanner,
      font: fonts.small,
      brush: sf.PdfSolidBrush(mutedInk),
    ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));

    final bytes = Uint8List.fromList(await document.save());
    document.dispose();
    return bytes;
  }

  static Future<File> saveAndShareHolisticDoctorPdf({
    required String profileName,
    List<LabReportRecord> labReports = const [],
    List<BloodPressureReading> bpReadings = const [],
    List<BloodSugarReading> sugarReadings = const [],
    List<AnalysisResult> visualChecks = const [],
  }) async {
    final pdfBytes = await generateHolisticDoctorPdf(
      profileName: profileName,
      labReports: labReports,
      bpReadings: bpReadings,
      sugarReadings: sugarReadings,
      visualChecks: visualChecks,
    );
    final dir = await getTemporaryDirectory();
    final dateTag = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final file = File(
      '${dir.path}${Platform.pathSeparator}VisualCheckUp_Doktor_Dosyasi_$dateTag.pdf',
    );
    await file.writeAsBytes(pdfBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'VisualCheckUp Bütüncül Doktor Dosyası ($dateTag)',
        text: 'Doktor görüşmesi için hazırlanmış bütüncül sağlık özeti.',
      ),
    );
    return file;
  }

  static Future<_PdfFontSet> _loadFonts() async {
    try {
      Uint8List regBytes;
      Uint8List boldBytes;
      try {
        final regData = await rootBundle.load('assets/fonts/roboto-regular.ttf');
        final boldData = await rootBundle.load('assets/fonts/roboto-bold.ttf');
        regBytes = regData.buffer.asUint8List();
        boldBytes = boldData.buffer.asUint8List();
      } catch (_) {
        regBytes = await File('assets/fonts/roboto-regular.ttf').readAsBytes();
        boldBytes = await File('assets/fonts/roboto-bold.ttf').readAsBytes();
      }
      return _PdfFontSet(
        title: sf.PdfTrueTypeFont(boldBytes, 15),
        section: sf.PdfTrueTypeFont(boldBytes, 11.5),
        body: sf.PdfTrueTypeFont(regBytes, 9.8),
        small: sf.PdfTrueTypeFont(regBytes, 8.5),
        tableHeader: sf.PdfTrueTypeFont(boldBytes, 9.2),
        tableBody: sf.PdfTrueTypeFont(regBytes, 9.0),
        tableBold: sf.PdfTrueTypeFont(boldBytes, 9.0),
      );
    } catch (_) {
      return _PdfFontSet(
        title: sf.PdfStandardFont(
          sf.PdfFontFamily.helvetica,
          15,
          style: sf.PdfFontStyle.bold,
        ),
        section: sf.PdfStandardFont(
          sf.PdfFontFamily.helvetica,
          11.5,
          style: sf.PdfFontStyle.bold,
        ),
        body: sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 9.8),
        small: sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 8.5),
        tableHeader: sf.PdfStandardFont(
          sf.PdfFontFamily.helvetica,
          9.2,
          style: sf.PdfFontStyle.bold,
        ),
        tableBody: sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 9.0),
        tableBold: sf.PdfStandardFont(
          sf.PdfFontFamily.helvetica,
          9.0,
          style: sf.PdfFontStyle.bold,
        ),
      );
    }
  }

  static String _fmtCompact(double v) {
    if ((v - v.roundToDouble()).abs() < 0.001) {
      return v.round().toString();
    }
    final two = v.toStringAsFixed(2);
    return two.endsWith('0') ? v.toStringAsFixed(1) : two;
  }
}

class _PdfFontSet {
  const _PdfFontSet({
    required this.title,
    required this.section,
    required this.body,
    required this.small,
    required this.tableHeader,
    required this.tableBody,
    required this.tableBold,
  });

  final sf.PdfFont title;
  final sf.PdfFont section;
  final sf.PdfFont body;
  final sf.PdfFont small;
  final sf.PdfFont tableHeader;
  final sf.PdfFont tableBody;
  final sf.PdfFont tableBold;
}
