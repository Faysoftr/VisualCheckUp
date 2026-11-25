import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_community_hub_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

Uint8List _sampleJpeg() {
  final image = img.Image(width: 48, height: 48);
  img.fill(image, color: img.ColorRgb8(11, 110, 110));
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

Widget _wrapApp(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
}

const _testUser = AuthUser(
  id: 'user_tr_1',
  displayName: 'Fatma Yıldız',
  email: 'fatma@example.com',
  provider: AuthProviderType.google,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HealthCommunityModels & Repository', () {
    test('sanitizes handles and respects hideRealName and hidePhoto privacy', () {
      expect(
        HealthCommunityProfile.sanitizeNickname('Şeker & Sağlıklı Yaşam!'),
        'sekersaglikliyasam',
      );

      final hidden = HealthCommunityProfile(
        uid: 'u1',
        displayName: 'Ayşe Yılmaz',
        nickname: 'ayse_fit',
        photoUrl: 'https://cdn.visualcheckup.test/a.jpg',
        hideRealName: true,
        hidePhoto: true,
        updatedAt: DateTime(2026, 11, 25),
      );
      expect(hidden.visibleName, '@ayse_fit');
      expect(hidden.visiblePhotoUrl, isNull);

      final roundTrip = HealthCommunityProfile.fromJson(hidden.toJson());
      expect(roundTrip.uid, 'u1');
      expect(roundTrip.visibleName, '@ayse_fit');
      expect(roundTrip.requireMessageApproval, isTrue);
    });

    test('supports opt-in profile, global filters, profile likes, message approval, rate limit, image msg, and block', () async {
      DateTime now = DateTime(2026, 11, 25, 12, 0, 0);
      final repo = HealthCommunityRepository(
        useFirebase: false,
        clock: () => now,
      );

      // Opt-in is off by default
      expect(await repo.loadMyProfile('user_tr_1'), isNull);

      // Save opt-in health profile
      await repo.saveMyProfile(
        HealthCommunityProfile(
          uid: 'user_tr_1',
          displayName: 'Fatma Yıldız',
          nickname: 'fatma_wellness',
          countryCode: 'TR',
          city: 'İstanbul',
          languageCode: 'tr',
          healthGoals: const [HealthGoalTag.diabetes, HealthGoalTag.weightDiet],
          bio: 'Sağlıklı beslenme ve yürüyüş',
          updatedAt: now,
        ),
      );
      final loaded = await repo.loadMyProfile('user_tr_1');
      expect(loaded, isNotNull);
      expect(loaded!.nickname, 'fatma_wellness');

      // Filter global discover by diabetes goal and country
      final diabetesPeers = await repo.discoverProfiles(
        myUid: 'user_tr_1',
        goalFilter: HealthGoalTag.diabetes,
      );
      expect(diabetesPeers, isNotEmpty);
      expect(
        diabetesPeers.every((p) => p.healthGoals.contains(HealthGoalTag.diabetes)),
        isTrue,
      );

      final dePeers = await repo.discoverProfiles(
        myUid: 'user_tr_1',
        countryCodeFilter: 'DE',
      );
      expect(dePeers.length, 1);
      expect(dePeers.first.uid, 'sample_de_lukas');

      // Like & unlike a peer profile
      final peer = dePeers.first;
      final beforeLikes = peer.likesCount;
      final liked = await repo.toggleProfileLike(
        targetUid: peer.uid,
        myUid: 'user_tr_1',
      );
      expect(liked!.likesCount, beforeLikes + 1);
      expect(liked.isLikedBy('user_tr_1'), isTrue);

      final unliked = await repo.toggleProfileLike(
        targetUid: peer.uid,
        myUid: 'user_tr_1',
      );
      expect(unliked!.likesCount, beforeLikes);

      // Send first message -> creates pending message request
      final status1 = await repo.sendMessage(
        senderUid: 'user_tr_1',
        senderDisplayName: 'Fatma Yıldız',
        receiver: peer,
        text: 'Merhaba, tansiyon takibi motivasyonu için selam!',
      );
      expect(status1, SendMessageStatus.sent);

      final chatId = CommunityConversation.chatIdFor('user_tr_1', peer.uid);
      final convo = await repo.loadConversation(chatId);
      expect(convo, isNotNull);
      expect(convo!.status, ConversationRequestStatus.pending);
      expect(convo.isPendingIncomingFor(peer.uid), isTrue);

      // Immediate second message hits 3s rate limit
      final rateStatus = await repo.sendMessage(
        senderUid: 'user_tr_1',
        senderDisplayName: 'Fatma Yıldız',
        receiver: peer,
        text: 'Hızlı spam testi',
      );
      expect(rateStatus, SendMessageStatus.rateLimited);

      // Advance clock 5s and send an uploaded photo message
      now = now.add(const Duration(seconds: 5));
      final imgStatus = await repo.sendMessage(
        senderUid: 'user_tr_1',
        senderDisplayName: 'Fatma Yıldız',
        receiver: peer,
        imageUrl: 'https://cdn.visualcheckup.test/community_chat/mock_1.jpg',
        imageKey: 'community_chat/mock_1.jpg',
      );
      expect(imgStatus, SendMessageStatus.sent);

      final msgs = await repo.loadMessages(chatId, myUid: 'user_tr_1');
      expect(msgs.length, 2);
      expect(msgs.last.hasImage, isTrue);

      // Accept request
      await repo.respondToMessageRequest(chatId: chatId, accept: true);
      final acceptedConvo = await repo.loadConversation(chatId);
      expect(acceptedConvo!.status, ConversationRequestStatus.accepted);

      // Block user hides them from Discover & prevents new messages
      await repo.blockUser(myUid: 'user_tr_1', targetUid: peer.uid);
      final afterBlock = await repo.discoverProfiles(
        myUid: 'user_tr_1',
        countryCodeFilter: 'DE',
      );
      expect(afterBlock, isEmpty);

      now = now.add(const Duration(seconds: 5));
      final blockedSend = await repo.sendMessage(
        senderUid: 'user_tr_1',
        senderDisplayName: 'Fatma Yıldız',
        receiver: peer,
        text: 'Engelli deneme',
      );
      expect(blockedSend, SendMessageStatus.blocked);

      // Submit safety report
      await repo.submitReport(
        reporterUid: 'user_tr_1',
        targetType: 'profile',
        targetId: peer.uid,
        reason: CommunityReportReason.medicalMisinformation,
        note: 'Test report',
      );
      expect(await repo.loadSubmittedReportCount(), 1);
    });
  });

  group('HealthCommunityHubScreen, Profile Detail & Chat widget flows', () {
    testWidgets(
      'discovers global profiles, likes, sends text & uploaded photo in chat, and creates opt-in profile with avatar upload',
      (tester) async {
        final repo = HealthCommunityRepository(
          useFirebase: false,
          rateLimitSeconds: 0,
        );
        final mockUploader = MockCommunityImageUploadService();

        await tester.pumpWidget(
          _wrapApp(
            HealthCommunityHubScreen(
              currentUser: _testUser,
              repository: repo,
              uploadService: mockUploader,
              photoPicker: (_) async => _sampleJpeg(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Discover tab shows global wellness profiles
        expect(find.text('Ayşe Demir'), findsOneWidget);

        // Quick-like Ayşe Demir from Discover list
        final ayseLikeBtn =
            find.byKey(const Key('comm_like_btn_sample_tr_ayse'));
        await tester.ensureVisible(ayseLikeBtn);
        await tester.pumpAndSettle();
        await tester.tap(ayseLikeBtn);
        await tester.pumpAndSettle();

        // Open Ayşe Demir's profile detail & open Chat
        final ayseCard =
            find.byKey(const Key('comm_profile_card_sample_tr_ayse'));
        await tester.ensureVisible(ayseCard);
        await tester.pumpAndSettle();
        await tester.tap(ayseCard);
        await tester.pumpAndSettle();

        expect(find.text('Beğenildi'), findsOneWidget);
        await tester.tap(find.byKey(const Key('comm_detail_message_button')));
        await tester.pumpAndSettle();

        // Send a text message
        await tester.enterText(
          find.byKey(const Key('comm_chat_input_field')),
          'Merhaba Ayşe, yürüyüş hedefin çok güzel!',
        );
        await tester.tap(find.byKey(const Key('comm_chat_send_button')));
        await tester.pumpAndSettle();
        expect(
          find.text('Merhaba Ayşe, yürüyüş hedefin çok güzel!'),
          findsOneWidget,
        );

        // Upload & send an image attachment in chat via mock R2 uploader
        await tester.tap(
          find.byKey(const Key('comm_chat_attach_photo_button')),
        );
        await tester.pumpAndSettle();
        expect(mockUploader.uploadCount, 1);

        // Navigate back to Hub and switch to My Profile tab
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Profilim'));
        await tester.pumpAndSettle();

        // Opt-in onboarding card appears by default
        expect(find.byKey(const Key('comm_opt_in_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('comm_opt_in_button')));
        await tester.pumpAndSettle();

        // Upload avatar via mock R2 uploader & save health profile
        await tester.tap(find.byKey(const Key('comm_upload_avatar_button')));
        await tester.pumpAndSettle();
        expect(mockUploader.uploadCount, 2);

        final saveBtn = find.byKey(const Key('comm_save_profile_button'));
        await tester.scrollUntilVisible(
          saveBtn,
          300,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('comm_my_profile_list')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        final savedProfile = await repo.loadMyProfile(_testUser.id);
        expect(savedProfile, isNotNull);
        expect(
          savedProfile!.photoUrl,
          contains('cdn.visualcheckup.test/community_avatars/'),
        );
      },
    );
  });
}
