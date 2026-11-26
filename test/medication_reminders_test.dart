import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_audio_player.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_watcher.dart';
import 'package:visualcheckup/features/medications/data/medication_reminder_repository.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';
import 'package:visualcheckup/features/medications/presentation/screens/medication_alarm_ring_screen.dart';
import 'package:visualcheckup/features/medications/presentation/screens/medication_reminders_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

class _SpyAlarmScheduler extends NoopMedicationAlarmScheduler {
  final List<String> scheduledIds = [];
  final List<String> cancelledIds = [];
  final List<String> snoozedIds = [];

  @override
  Future<void> scheduleReminder(
    MedicationReminder reminder, {
    required String categoryLabel,
    required String mealTimingLabel,
  }) async {
    scheduledIds.add(reminder.id);
  }

  @override
  Future<void> cancelReminder(String reminderId) async {
    cancelledIds.add(reminderId);
  }

  @override
  Future<void> scheduleSnooze(
    MedicationReminder reminder, {
    int minutes = 10,
    required String categoryLabel,
    required String snoozeBody,
  }) async {
    snoozedIds.add(reminder.id);
  }
}

class _SpyAudioPlayer implements MedicationAlarmAudioPlayer {
  final List<({MedicationAlarmSound sound, bool loop})> played = [];
  int stopCount = 0;

  @override
  Future<void> play(
    MedicationAlarmSound sound, {
    bool loop = false,
  }) async {
    played.add((sound: sound, loop: loop));
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<String?> getSystemAlarmUri() async => null;
}

Uint8List _createSampleJpegBytes() {
  final image = img.Image(width: 64, height: 64);
  img.fill(image, color: img.ColorRgb8(200, 85, 61));
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

Widget _wrapWithApp(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MedicationReminder domain model', () {
    test('serializes and deserializes with all fields intact', () {
      final original = MedicationReminder(
        id: 'med_1',
        title: 'Glifor 1000 mg',
        category: MedicationCategory.diabetesInsulin,
        hour: 8,
        minute: 30,
        weekdays: const {1, 3, 5},
        dosage: '1 tablet',
        description: 'Kahvaltıdan 30 dk önce bol su ile için',
        mealTiming: MealTiming.beforeMeal,
        photoPath: '/tmp/glifor.jpg',
        enabled: true,
        soundEnabled: true,
        vibrateEnabled: false,
        alarmSound: MedicationAlarmSound.urgentAlarm,
        createdAt: DateTime(2026, 11, 25, 7, 0),
      );

      final roundTrip = MedicationReminder.fromJson(original.toJson());
      expect(roundTrip.id, 'med_1');
      expect(roundTrip.title, 'Glifor 1000 mg');
      expect(roundTrip.category, MedicationCategory.diabetesInsulin);
      expect(roundTrip.formattedTime, '08:30');
      expect(roundTrip.weekdays, {1, 3, 5});
      expect(roundTrip.dosage, '1 tablet');
      expect(roundTrip.description, 'Kahvaltıdan 30 dk önce bol su ile için');
      expect(roundTrip.mealTiming, MealTiming.beforeMeal);
      expect(roundTrip.photoPath, '/tmp/glifor.jpg');
      expect(roundTrip.vibrateEnabled, isFalse);
      expect(roundTrip.alarmSound, MedicationAlarmSound.urgentAlarm);

      // Legacy JSON without alarmSound defaults to classicAlarm
      final legacyJson = Map<String, dynamic>.from(original.toJson())
        ..remove('alarmSound');
      final migrated = MedicationReminder.fromJson(legacyJson);
      expect(migrated.alarmSound, MedicationAlarmSound.classicAlarm);
    });

    test('calculates nextTriggerTime across weekdays accurately', () {
      // 2026-11-25 is a Wednesday (ISO weekday 3).
      final wedMorning = DateTime(2026, 11, 25, 8, 0);
      final reminder = MedicationReminder(
        id: 'r1',
        title: 'Akşam İnsülini',
        category: MedicationCategory.diabetesInsulin,
        hour: 20,
        minute: 15,
        weekdays: const {3, 5}, // Wed & Fri
        createdAt: wedMorning,
      );

      // Same day in the future -> Wed 20:15
      expect(
        reminder.nextTriggerTime(wedMorning),
        DateTime(2026, 11, 25, 20, 15),
      );

      // Past Wed 20:15 -> Friday 20:15
      final wedLate = DateTime(2026, 11, 25, 21, 0);
      expect(
        reminder.nextTriggerTime(wedLate),
        DateTime(2026, 11, 27, 20, 15),
      );

      // Disabled alarm -> null
      expect(
        reminder.copyWith(enabled: false).nextTriggerTime(wedMorning),
        isNull,
      );
    });

    test('deterministic notification IDs and payload parsing', () {
      final idMon = LocalMedicationAlarmScheduler.notificationIdFor('med_abc', 1);
      final idTue = LocalMedicationAlarmScheduler.notificationIdFor('med_abc', 2);
      expect(idMon, isPositive);
      expect(idMon, isNot(equals(idTue)));
      expect(
        LocalMedicationAlarmScheduler.parseReminderIdFromPayload(
          'med_alarm:med_abc',
        ),
        'med_abc',
      );
      expect(
        LocalMedicationAlarmScheduler.parseReminderIdFromPayload('other:123'),
        isNull,
      );
    });
  });

  group('MedicationReminderRepository & AlarmWatcher', () {
    test('persists reminders, isolates profiles, and logs daily adherence',
        () async {
      final repoDefault = MedicationReminderRepository(profileId: 'default');
      final repoMom = MedicationReminderRepository(profileId: 'mom');

      final r1 = MedicationReminder(
        id: 'bp_1',
        title: 'Norvasc 5 mg',
        category: MedicationCategory.bloodPressure,
        hour: 9,
        minute: 0,
        weekdays: MedicationReminder.allWeekdays,
        description: 'Sabah tansiyon ölçümünden sonra',
        createdAt: DateTime(2026, 11, 25, 8, 0),
      );

      await repoDefault.saveReminder(r1);
      expect((await repoDefault.loadReminders()).length, 1);
      expect(await repoMom.loadReminders(), isEmpty);

      final today = DateTime(2026, 11, 25, 9, 5);
      await repoDefault.logDoseStatus(
        reminderId: 'bp_1',
        status: MedicationDoseStatus.taken,
        now: today,
      );
      final statuses = await repoDefault.getTodayStatusMap(now: today);
      expect(statuses['bp_1']?.status, MedicationDoseStatus.taken);

      await repoDefault.deleteReminder('bp_1');
      expect(await repoDefault.loadReminders(), isEmpty);
    });

    test('MedicationAlarmWatcher fires once per minute and skips taken doses',
        () async {
      final repo = MedicationReminderRepository(profileId: 'watcher_test');
      final wed0830 = DateTime(2026, 11, 25, 8, 30);
      await repo.saveReminder(
        MedicationReminder(
          id: 'ins_1',
          title: 'Sabah İnsülini',
          category: MedicationCategory.diabetesInsulin,
          hour: 8,
          minute: 30,
          weekdays: const {3}, // Wednesday
          description: '10 ünite göbek çevresinden',
          createdAt: DateTime(2026, 11, 25, 7, 0),
        ),
      );

      final triggered = <String>[];
      final watcher = MedicationAlarmWatcher(
        repositoryProvider: () => repo,
        onAlarmTriggered: (r) => triggered.add(r.id),
        clock: () => wed0830,
      );

      await watcher.checkNow();
      await watcher.checkNow(); // Same minute -> should not double-fire
      expect(triggered, ['ins_1']);

      // New watcher after dose marked taken -> should NOT fire
      await repo.logDoseStatus(
        reminderId: 'ins_1',
        status: MedicationDoseStatus.taken,
        now: wed0830,
      );
      final triggeredAfterTaken = <String>[];
      final watcher2 = MedicationAlarmWatcher(
        repositoryProvider: () => repo,
        onAlarmTriggered: (r) => triggeredAfterTaken.add(r.id),
        clock: () => wed0830,
      );
      await watcher2.checkNow();
      expect(triggeredAfterTaken, isEmpty);
    });
  });

  group('MedicationRemindersScreen & MedicationAlarmRingScreen widgets', () {
    testWidgets(
      'adds diabetes alarm with note, weekdays, and previews ringing screen',
      (tester) async {
        final repo = MedicationReminderRepository(profileId: 'widget_test');
        final spyScheduler = _SpyAlarmScheduler();

        await tester.pumpWidget(
          _wrapWithApp(
            MedicationRemindersScreen(
              repository: repo,
              scheduler: spyScheduler,
              photoPicker: (_) async => _createSampleJpegBytes(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Henüz İlaç Alarmı Yok'), findsOneWidget);

        // Open Add Alarm sheet
        await tester.tap(find.byKey(const Key('med_add_alarm_fab')));
        await tester.pumpAndSettle();

        // Select Diabetes Pill / Insulin category
        await tester.tap(find.text('Şeker Hapı / İğnesi'));
        await tester.pump();

        // Take a photo via mock camera picker
        final takePhotoBtn = find.byKey(const Key('med_take_photo_button'));
        await tester.ensureVisible(takePhotoBtn);
        await tester.tap(takePhotoBtn);
        await tester.pumpAndSettle();

        // Enter medicine name, dosage, and reminder description
        final nameField = find.byKey(const Key('med_name_field'));
        await tester.ensureVisible(nameField);
        await tester.enterText(nameField, 'Glifor 1000 mg');

        final dosageField = find.byKey(const Key('med_dosage_field'));
        await tester.ensureVisible(dosageField);
        await tester.enterText(dosageField, '1 tablet');

        final descField = find.byKey(const Key('med_description_field'));
        await tester.ensureVisible(descField);
        await tester.enterText(
          descField,
          'Kahvaltıdan 30 dk önce bol su ile için',
        );
        await tester.pumpAndSettle();

        // Tap pinned Save button
        final saveBtn = find.byKey(const Key('med_save_alarm_button'));
        await tester.tap(saveBtn);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pumpAndSettle();

        // Alarm is scheduled and displayed with note
        expect(spyScheduler.scheduledIds, hasLength(1));
        expect(find.text('Glifor 1000 mg'), findsOneWidget);
        expect(
          find.text('Kahvaltıdan 30 dk önce bol su ile için'),
          findsOneWidget,
        );

        // Launch Test Alarm Preview (ringing screen)
        await tester.tap(find.text('Alarmı Önizle'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('İLAÇ ZAMANI'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(MedicationAlarmRingScreen),
            matching: find.text('Glifor 1000 mg'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MedicationAlarmRingScreen),
            matching: find.text('Kahvaltıdan 30 dk önce bol su ile için'),
          ),
          findsOneWidget,
        );

        // Mark as taken on ringing screen
        await tester.tap(find.byKey(const Key('alarm_ring_taken_button')));
        await tester.pumpAndSettle();

        expect(find.text('Bugün 1/1 alındı'), findsOneWidget);
      },
    );

    testWidgets(
      'MedicationAlarmRingScreen displays real medicine photo file and snoozes',
      (tester) async {
        final tempDir = Directory.systemTemp.createTempSync('med_photo_test');
        addTearDown(() {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });
        final photoFile = File('${tempDir.path}/insulin.jpg');
        photoFile.writeAsBytesSync(_createSampleJpegBytes());

        final repo = MedicationReminderRepository(profileId: 'ring_photo_test');
        final spyScheduler = _SpyAlarmScheduler();
        final reminder = MedicationReminder(
          id: 'ins_evening',
          title: 'Akşam İnsülini',
          category: MedicationCategory.diabetesInsulin,
          hour: 21,
          minute: 0,
          weekdays: MedicationReminder.allWeekdays,
          dosage: '14 ünite',
          description: 'Yatmadan önce karın bölgesine uygulayın',
          mealTiming: MealTiming.bedtime,
          photoPath: photoFile.path,
          createdAt: DateTime(2026, 11, 25, 10, 0),
        );
        await repo.saveReminder(reminder);

        await tester.pumpWidget(
          _wrapWithApp(
            MedicationAlarmRingScreen(
              reminder: reminder,
              repository: repo,
              scheduler: spyScheduler,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Akşam İnsülini'), findsOneWidget);
        expect(find.text('14 ünite'), findsOneWidget);
        expect(
          find.text('Yatmadan önce karın bölgesine uygulayın'),
          findsOneWidget,
        );
        expect(find.text('Büyütmek için fotoğrafa dokunun'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);

        // Tap Snooze 10 min
        await tester.tap(find.byKey(const Key('alarm_ring_snooze_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(spyScheduler.snoozedIds, ['ins_evening']);
        final statuses = await repo.getTodayStatusMap();
        expect(statuses['ins_evening']?.status, MedicationDoseStatus.snoozed);
      },
    );

    testWidgets('renders localized strings in English and Arabic',
        (tester) async {
      final repo = MedicationReminderRepository(profileId: 'l10n_test');
      final spyScheduler = _SpyAlarmScheduler();

      await tester.pumpWidget(
        _wrapWithApp(
          MedicationRemindersScreen(
            repository: repo,
            scheduler: spyScheduler,
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Medication & Alarm Reminder'), findsOneWidget);
      expect(find.text('Add New Alarm'), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithApp(
          MedicationRemindersScreen(
            repository: repo,
            scheduler: spyScheduler,
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('منبّه الأدوية والجرعات'), findsOneWidget);
      expect(find.text('إضافة منبه جديد'), findsOneWidget);
    });

    testWidgets(
      'supports Herbal Tea category and manual custom category label',
      (tester) async {
        final repo = MedicationReminderRepository(profileId: 'custom_cat_test');
        final spyScheduler = _SpyAlarmScheduler();

        await tester.pumpWidget(
          _wrapWithApp(
            MedicationRemindersScreen(
              repository: repo,
              scheduler: spyScheduler,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Empty state offers Bitki Çayı quick preset
        expect(find.text('Bitki Çayı'), findsOneWidget);

        // Open add sheet and select "Diğer (Elle Gir)"
        await tester.tap(find.byKey(const Key('med_add_alarm_fab')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Diğer (Elle Gir)'));
        await tester.pumpAndSettle();

        // Manual custom category field appears
        final customCatField = find.byKey(const Key('med_custom_category_field'));
        expect(customCatField, findsOneWidget);
        await tester.enterText(customCatField, 'Probiyotik Kür');

        final nameField = find.byKey(const Key('med_name_field'));
        await tester.ensureVisible(nameField);
        await tester.enterText(nameField, 'Akşam Kefir + Probiyotik');
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('med_save_alarm_button')));
        await tester.pumpAndSettle();

        // Saved reminder shows custom manual category label
        expect(find.text('Akşam Kefir + Probiyotik'), findsOneWidget);
        expect(find.textContaining('Probiyotik Kür'), findsOneWidget);

        final saved = (await repo.loadReminders()).single;
        expect(saved.customCategoryLabel, 'Probiyotik Kür');
      },
    );

    test('uses dedicated per-sound notification channels and silent channel', () {
      final base = MedicationReminder(
        id: 'ch_1',
        title: 'Tansiyon Hapı',
        category: MedicationCategory.bloodPressure,
        hour: 9,
        minute: 0,
        weekdays: MedicationReminder.allWeekdays,
        createdAt: DateTime(2026, 11, 25, 8, 0),
      );

      final classicChannel = LocalMedicationAlarmScheduler.channelIdFor(base);
      final urgentChannel = LocalMedicationAlarmScheduler.channelIdFor(
        base.copyWith(alarmSound: MedicationAlarmSound.urgentAlarm),
      );
      final silentChannel = LocalMedicationAlarmScheduler.channelIdFor(
        base.copyWith(soundEnabled: false),
      );

      expect(classicChannel, isNot(equals(urgentChannel)));
      expect(classicChannel, isNot(equals(silentChannel)));
      expect(classicChannel, contains('alarm_classic'));
      expect(urgentChannel, contains('alarm_urgent'));
      expect(silentChannel, contains('silent'));
    });

    testWidgets(
      'selects alarm sound, previews audio, and previews full-screen draft alarm before saving',
      (tester) async {
        final repo = MedicationReminderRepository(profileId: 'sound_test');
        final spyScheduler = _SpyAlarmScheduler();
        final spyAudio = _SpyAudioPlayer();

        await tester.pumpWidget(
          _wrapWithApp(
            MedicationRemindersScreen(
              repository: repo,
              scheduler: spyScheduler,
              audioPlayer: spyAudio,
              photoPicker: (_) async => _createSampleJpegBytes(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open Add Alarm sheet
        await tester.tap(find.byKey(const Key('med_add_alarm_fab')));
        await tester.pumpAndSettle();

        // Enter medicine name
        final nameField = find.byKey(const Key('med_name_field'));
        await tester.ensureVisible(nameField);
        await tester.enterText(nameField, 'Sabah Tansiyon İlacı');
        await tester.pumpAndSettle();

        // Scroll to Alarm Sound picker & preview "Sağlık Zili" (vitalBell)
        final bellPreviewBtn =
            find.byKey(const Key('med_sound_preview_vitalBell'));
        await tester.ensureVisible(bellPreviewBtn);
        await tester.pumpAndSettle();

        await tester.tap(bellPreviewBtn);
        await tester.pump();
        expect(
          spyAudio.played.last,
          (sound: MedicationAlarmSound.vitalBell, loop: false),
        );

        // Tap Stop on same sound preview
        await tester.tap(bellPreviewBtn);
        await tester.pump();
        expect(spyAudio.stopCount, greaterThanOrEqualTo(1));

        // Open full-screen Draft Alarm Preview before saving
        await tester.tap(
          find.byKey(const Key('med_form_preview_alarm_button')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.byType(MedicationAlarmRingScreen), findsOneWidget);
        expect(find.text('ÖNİZLEME'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(MedicationAlarmRingScreen),
            matching: find.text('Sağlık Zili'),
          ),
          findsOneWidget,
        );
        expect(
          spyAudio.played.last,
          (sound: MedicationAlarmSound.vitalBell, loop: true),
        );

        // Tapping Taken on unsaved draft preview closes cleanly without saving dose log
        final stopsBeforeClose = spyAudio.stopCount;
        await tester.tap(find.byKey(const Key('alarm_ring_taken_button')));
        await tester.pumpAndSettle();
        expect(spyAudio.stopCount, greaterThan(stopsBeforeClose));
        expect(await repo.getTodayStatusMap(), isEmpty);

        // Save alarm and verify selected alarmSound persisted
        await tester.tap(find.byKey(const Key('med_save_alarm_button')));
        await tester.pumpAndSettle();

        final saved = (await repo.loadReminders()).single;
        expect(saved.alarmSound, MedicationAlarmSound.vitalBell);
      },
    );
  });
}

