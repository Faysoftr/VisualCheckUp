# HealthCheck (Android & iOS)

Kamera yardımıyla **göz (sklera), tırnak, dil, yüz/cilt, idrar rengi ve dışkı rengi** üzerinden görsel ön farkındalık değerlendirmesi sunan Flutter tabanlı mobil uygulama temeli.

> **Önemli Uyarı:** Bu uygulama tıbbi cihaz değildir ve tıbbi teşhis koymaz. Yalnızca bilgilendirme ve ön farkındalık amaçlıdır; kesin değerlendirme için daima bir hekime başvurun.

## Mimari Yapı

- `lib/core/` — Material 3 tema (`app_theme.dart`) ve tıbbi sorumluluk reddi metinleri (`medical_disclaimer.dart`)
- `lib/features/checkup/domain/` — 6 kontrol kategorisi (`check_category.dart`), sonuç modeli (`analysis_result.dart`) ve soyut analiz arayüzü (`health_analyzer.dart`)
- `lib/features/checkup/data/` — Cihaz içi RGB/HSV renk örnekleme motoru (`color_health_analyzer.dart`) ve yerel geçmiş deposu (`history_repository.dart`)
- `lib/features/checkup/presentation/` — Ana ekran, kamera/galeri yakalama ekranı, sonuç ekranı ve geçmiş ekranı

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
