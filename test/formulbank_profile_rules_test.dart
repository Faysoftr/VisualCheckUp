import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/widgets/social_profile_view.dart';
import 'package:visualcheckup/features/pedometer/data/pedometer_service.dart';
import 'package:visualcheckup/features/sobriety/data/sobriety_repository.dart';
import 'package:visualcheckup/features/widgets_hub/presentation/widgets/health_quick_widgets_hub.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Widget _wrapTr(Widget child) {
  return MaterialApp(
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Social Formül Bank Identity, Age, Gender & Quota Rules', () {
    test('Age calculation from dd-MM-yyyy and gender label serialization', () {
      final p = HealthCommunityProfile(
        uid: 'u_age_test',
        displayName: 'Zeynep Kaya',
        nickname: 'zeynep_kaya',
        birthDate: '15-05-1996',
        birthYear: 1996,
        birthMonth: 5,
        birthDay: 15,
        gender: 'Female',
        nameChangeCount: 1,
        nicknameChangeCount: 2,
        updatedAt: DateTime(2026, 11, 27),
      );

      expect(p.ageAt(DateTime(2026, 5, 14)), 29);
      expect(p.ageAt(DateTime(2026, 5, 15)), 30);
      expect(p.localizedGenderLabel, 'Kadın ♀');

      final roundTrip = HealthCommunityProfile.fromJson(p.toJson());
      expect(roundTrip.birthDate, '15-05-1996');
      expect(roundTrip.gender, 'Female');
      expect(roundTrip.nameChangeCount, 1);
      expect(roundTrip.nicknameChangeCount, 2);
      expect(roundTrip.toJson()['nicknameLower'], 'zeynep_kaya');
    });

    test('Nickname uniqueness check detects starter & saved handles and offers free suggestions', () async {
      final repo = HealthCommunityRepository(useFirebase: false);

      // Starter handle 'ayse_saglik' is taken for other users, free for sample_tr_ayse itself
      expect(
        await repo.isNicknameTaken('ayse_saglik', excludeUid: 'other_uid'),
        isTrue,
      );
      expect(
        await repo.isNicknameTaken('ayse_saglik', excludeUid: 'sample_tr_ayse'),
        isFalse,
      );

      final suggestions = await repo.generateNicknameSuggestions(
        'ayse_saglik',
        excludeUid: 'other_uid',
      );
      expect(suggestions, isNotEmpty);
      for (final s in suggestions) {
        expect(
          await repo.isNicknameTaken(s, excludeUid: 'other_uid'),
          isFalse,
        );
      }
    });

    testWidgets(
      'Hydrates BirthDate/Age & Gender from Google Login AuthUser, blocks taken nickname, and enforces 2 Name / 3 Nickname change quotas',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = HealthCommunityRepository(useFirebase: false);
        const loginUser = AuthUser(
          id: 'u_google_1',
          displayName: 'Canan Ersoy',
          email: 'canan@example.com',
          provider: AuthProviderType.google,
          birthDate: '10-03-1998',
          gender: 'Female',
        );

        await tester.pumpWidget(
          _wrapTr(
            SocialProfileView(
              currentUser: loginUser,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Opt-in to open form
        await tester.tap(find.byKey(const Key('comm_opt_in_button')));
        await tester.pumpAndSettle();

        // Verify login birthDate & live age & gender were automatically pulled!
        final birthField = tester.widget<TextField>(
          find.byKey(const Key('comm_profile_birthdate_field')),
        );
        expect(birthField.controller?.text, '10-03-1998');
        expect(find.byKey(const Key('comm_form_live_age_pill')), findsOneWidget);
        final femaleChip = tester.widget<ChoiceChip>(
          find.byKey(const Key('comm_gender_chip_female')),
        );
        expect(femaleChip.selected, isTrue);

        // Try entering an already taken nickname ('ayse_saglik') -> save blocked + suggestions shown!
        await tester.enterText(
          find.byKey(const Key('comm_profile_nickname_field')),
          'ayse_saglik',
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('comm_nickname_status_taken')),
          findsOneWidget,
        );

        Future<void> revealInOuterList(Finder target) async {
          final outerScrollable = find
              .byElementPredicate(
                (el) =>
                    el.widget is Scrollable &&
                    (el.widget as Scrollable).axisDirection ==
                        AxisDirection.down &&
                    el.findAncestorWidgetOfExactType<EditableText>() == null,
              )
              .first;
          final state = tester.state<ScrollableState>(outerScrollable);
          ScaffoldMessenger.maybeOf(state.context)?.clearSnackBars();
          state.position.jumpTo(0);
          await tester.pump();
          var guard = 0;
          while (target.evaluate().isEmpty &&
              state.position.pixels < state.position.maxScrollExtent &&
              guard < 30) {
            final next = (state.position.pixels + 350.0)
                .clamp(0.0, state.position.maxScrollExtent);
            state.position.jumpTo(next);
            await tester.pump();
            guard++;
          }
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
        }

        final saveBtn = find.byKey(const Key('comm_save_profile_button'));
        await revealInOuterList(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Still not saved because nickname is taken!
        expect(await repo.loadMyProfile('u_google_1'), isNull);
        ScaffoldMessenger.of(tester.element(saveBtn)).clearSnackBars();
        await tester.pumpAndSettle();

        // Scroll back up and pick a unique nickname
        final nickField = find.byKey(const Key('comm_profile_nickname_field'));
        await revealInOuterList(nickField);
        await tester.enterText(nickField, 'canan_ersoy_98');
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('comm_nickname_status_available')),
          findsOneWidget,
        );

        // Save initial profile -> initial creation uses 0 change rights!
        await revealInOuterList(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        final created = await repo.loadMyProfile('u_google_1');
        expect(created, isNotNull);
        expect(created!.nameChangeCount, 0);
        expect(created.nicknameChangeCount, 0);
        expect(created.birthDate, '10-03-1998');
        expect(created.gender, 'Female');

        // Showcase displays Age & Gender badges!
        expect(
          find.byKey(const Key('profile_showcase_age_badge')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('profile_showcase_gender_badge')),
          findsOneWidget,
        );

        // Simulate 2 name changes -> 1st edit via UI with confirmation dialog
        await repo.saveMyProfile(
          created.copyWith(
            displayName: 'Canan Ersoy Yılmaz',
            nameChangeCount: 1,
            nicknameChangeCount: 3,
          ),
        );

        // Rebuild view with updated profile (1/2 name changes used, 3/3 nickname changes exhausted!)
        await tester.pumpWidget(
          _wrapTr(
            SocialProfileView(
              key: const ValueKey('reloaded_profile_view'),
              currentUser: loginUser,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Edit Profile button
        final editBtn = find.text('Profili Düzenle');
        await revealInOuterList(editBtn);
        await tester.tap(editBtn);
        await tester.pumpAndSettle();

        // Nickname field is LOCKED (3/3 exhausted), Name field has 1/2 remaining!
        final reloadedNickField = tester.widget<TextField>(
          find.byKey(const Key('comm_profile_nickname_field')),
        );
        expect(reloadedNickField.readOnly, isTrue);

        final reloadedNameField = tester.widget<TextField>(
          find.byKey(const Key('comm_profile_name_field')),
        );
        expect(reloadedNameField.readOnly, isFalse);

        // Consume final (2nd) Name change -> Confirmation dialog pops up!
        await tester.enterText(
          find.byKey(const Key('comm_profile_name_field')),
          'Dr. Canan Yılmaz',
        );
        await revealInOuterList(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(find.text('Profil Değişikliği Onayı'), findsOneWidget);
        await tester.tap(
          find.byKey(const Key('confirm_profile_quota_change_btn')),
        );
        await tester.pumpAndSettle();

        final afterSecondChange = await repo.loadMyProfile('u_google_1');
        expect(afterSecondChange!.displayName, 'Dr. Canan Yılmaz');
        expect(afterSecondChange.nameChangeCount, 2);

        // Open Edit again -> Name field is now LOCKED (2/2 exhausted)!
        await revealInOuterList(editBtn);
        await tester.tap(editBtn);
        await tester.pumpAndSettle();

        final lockedNameField = tester.widget<TextField>(
          find.byKey(const Key('comm_profile_name_field')),
        );
        expect(lockedNameField.readOnly, isTrue);
      },
    );

    testWidgets('Closed Quick Widgets Hub shows 1-tap reopen chip on HomeScreen', (tester) async {
      await tester.pumpWidget(
        _wrapTr(
          SingleChildScrollView(
            child: HealthQuickWidgetsHub(
              pedometerService: PedometerService(profileId: 'reopen_ped'),
              sobrietyRepository: SobrietyRepository(profileId: 'reopen_sob'),
              onOpenPedometer: () {},
              onOpenSobriety: () {},
              onOpenVitals: () {},
              onOpenAlarms: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('close_quick_widgets_hub_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('health_quick_widgets_hub')), findsNothing);
      expect(
        find.byKey(const Key('reopen_quick_widgets_hub_btn')),
        findsOneWidget,
      );

      // Reopen in 1 tap!
      await tester.tap(find.byKey(const Key('reopen_quick_widgets_hub_btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('health_quick_widgets_hub')),
        findsOneWidget,
      );
    });
  });
}
