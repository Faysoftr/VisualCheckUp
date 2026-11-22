# VisualCheckUp (Android & iOS)

Kamera yardımıyla **göz (sklera), tırnak, dil, yüz/cilt, cilt hastalıkları (döküntü/leke/pullanma/ben), idrar rengi ve dışkı rengi** üzerinden görsel ön farkındalık değerlendirmesi sunan Flutter tabanlı mobil uygulama temeli.

> **Önemli Uyarı:** Bu uygulama tıbbi cihaz değildir ve tıbbi teşhis koymaz. Yalnızca bilgilendirme ve ön farkındalık amaçlıdır; kesin değerlendirme için daima bir hekime başvurun.

## Mimari Yapı

- `lib/core/` — Material 3 tema (`app_theme.dart`), tıbbi sorumluluk reddi metinleri (`medical_disclaimer.dart`), çalışma zamanı kamera izin servisi (`camera_permission_service.dart`), CIE $L^*a^*b^*$ + Von Kries beyaz referans renk kalibrasyon motoru (`color_calibrator.dart`) ve arka plan Vision AI istemci/prompt sözleşmesi (`lib/core/ai/`)
- `lib/features/checkup/domain/` — 7 kontrol kategorisi (`check_category.dart`), sonuç modeli (`analysis_result.dart`), kişisel normal/bazal model (`category_baseline.dart`), referans bulgu modelleri (`module_reference.dart`) ve soyut analiz arayüzü (`health_analyzer.dart`)
- `lib/features/checkup/data/` — 7 modül için sağlıklı/sağlıksız referans bulgu kataloğu (`module_reference_catalog.dart`), cihaz içi CIE $L^*a^*b^*$/HSV renk analiz motoru (`color_health_analyzer.dart`) ve yerel geçmiş + bazal deposu (`history_repository.dart`)
- `lib/features/skin/` — Cilt hastalıkları ön kontrol modülü: belirti/bölge seçimi ve ABCDE ben rehberi (`skin_check_screen.dart`), lezyon-çevre cilt karşılaştırmalı analiz motoru (`skin_condition_analyzer.dart`)
- `lib/features/checkup/presentation/` — Ana ekran, izin ve beyaz referans kalibrasyonlu kamera/galeri yakalama ekranı, görsel referans rehberi (`module_reference_sheet.dart`), bazal karşılaştırmalı sonuç ekranı ve geçmiş ekranı

## Çalıştırma

```bash
flutter pub get
flutter run
```

## Test ve Analiz

```bash
flutter analyze
flutter test
```
