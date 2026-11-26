import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/features/wellness_extras/daily_health_tip_and_birthday.dart';

/// Social Formula Bank-inspired My Profile view used both inside the standalone
/// [MyHealthProfileScreen] (launched from the top of AppDrawer) and inside the
/// "My Profile" tab of [HealthCommunityHubScreen].
class SocialProfileView extends StatefulWidget {
  const SocialProfileView({
    super.key,
    required this.currentUser,
    required this.repository,
    this.uploadService,
    this.photoPicker,
    this.urlLauncher,
    this.onProfileChanged,
  });

  final AuthUser currentUser;
  final HealthCommunityRepository repository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final CommunityUrlLauncher? urlLauncher;
  final VoidCallback? onProfileChanged;

  @override
  State<SocialProfileView> createState() => _SocialProfileViewState();
}

class _SocialProfileViewState extends State<SocialProfileView> {
  late final CommunityImageUploadService _uploadService;

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dailyFocusController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _customConditionController =
      TextEditingController();
  final TextEditingController _musicTitleController = TextEditingController();
  final TextEditingController _musicUrlController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterXController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _snapchatController = TextEditingController();

  bool _loading = true;
  bool _savingProfile = false;
  bool _uploadingAvatar = false;
  bool _creatingProfile = false;
  bool _editingProfile = false;

  HealthCommunityProfile? _myProfile;
  List<MusicListenerRecord> _myMusicListeners = const [];
  List<FriendshipRecord> _friendships = const [];

  String? _photoUrl;
  String? _photoKey;
  String _countryCode = 'TR';
  String _languageCode = 'tr';
  Set<HealthGoalTag> _selectedGoals = {HealthGoalTag.healthyLiving};
  Set<ChronicCondition> _selectedConditions = {};
  HealthMood? _selectedMood;
  bool _showChronicConditions = true;
  bool _showOnlineStatus = true;
  bool _showSocials = true;
  bool _discoverable = true;
  bool _hideRealName = false;
  bool _hidePhoto = false;
  bool _allowMessages = true;
  bool _requireMessageApproval = true;
  bool _onlyFriendsCanMessage = false;

  String get _myUid => widget.currentUser.id;

  @override
  void initState() {
    super.initState();
    _uploadService =
        widget.uploadService ?? R2CommunityImageUploadService.instance;
    _loadProfileData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _nicknameController.dispose();
    _cityController.dispose();
    _dailyFocusController.dispose();
    _bioController.dispose();
    _customConditionController.dispose();
    _musicTitleController.dispose();
    _musicUrlController.dispose();
    _instagramController.dispose();
    _twitterXController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    _snapchatController.dispose();
    super.dispose();
  }

  void _syncFormFromProfile(HealthCommunityProfile? profile) {
    if (profile == null) {
      _displayNameController.text = widget.currentUser.displayName;
      _nicknameController.text = HealthCommunityProfile.sanitizeNickname(
        widget.currentUser.displayName,
      );
      _cityController.text = '';
      _dailyFocusController.text = '';
      _bioController.text = '';
      _customConditionController.text = '';
      _musicTitleController.text = '';
      _musicUrlController.text = '';
      _instagramController.text = '';
      _twitterXController.text = '';
      _tiktokController.text = '';
      _facebookController.text = '';
      _snapchatController.text = '';
      _photoUrl = null;
      _photoKey = null;
      _countryCode = 'TR';
      _languageCode = 'tr';
      _selectedGoals = {HealthGoalTag.healthyLiving};
      _selectedConditions = {};
      _selectedMood = null;
      _showChronicConditions = true;
      _showOnlineStatus = true;
      _showSocials = true;
      _discoverable = true;
      _hideRealName = false;
      _hidePhoto = false;
      _allowMessages = true;
      _requireMessageApproval = true;
      _onlyFriendsCanMessage = false;
      return;
    }
    _displayNameController.text = profile.displayName;
    _nicknameController.text = profile.nickname;
    _cityController.text = profile.city;
    _dailyFocusController.text = profile.dailyFocus;
    _bioController.text = profile.bio;
    _customConditionController.text = profile.customChronicCondition;
    _musicTitleController.text = profile.currentMusicTitle;
    _musicUrlController.text = profile.currentMusicUrl;
    _instagramController.text = profile.instagram;
    _twitterXController.text = profile.twitterX;
    _tiktokController.text = profile.tiktok;
    _facebookController.text = profile.facebook;
    _snapchatController.text = profile.snapchat;
    _photoUrl = profile.photoUrl;
    _photoKey = profile.photoKey;
    _countryCode = profile.countryCode;
    _languageCode = profile.languageCode;
    _selectedGoals = Set<HealthGoalTag>.from(profile.healthGoals);
    _selectedConditions = Set<ChronicCondition>.from(profile.chronicConditions);
    _selectedMood = profile.mood;
    _showChronicConditions = profile.showChronicConditions;
    _showOnlineStatus = profile.showOnlineStatus;
    _showSocials = profile.showSocials;
    _discoverable = profile.discoverable;
    _hideRealName = profile.hideRealName;
    _hidePhoto = profile.hidePhoto;
    _allowMessages = profile.allowMessages;
    _requireMessageApproval = profile.requireMessageApproval;
    _onlyFriendsCanMessage = profile.onlyFriendsCanMessage;
  }

  Future<void> _loadProfileData() async {
    final myProfile = await widget.repository.loadMyProfile(_myUid);
    final listeners = myProfile != null
        ? await widget.repository.loadMusicListeners(_myUid)
        : const <MusicListenerRecord>[];
    final friendships = await widget.repository.loadFriendships(_myUid);
    if (!mounted) return;
    setState(() {
      _myProfile = myProfile;
      _myMusicListeners = listeners;
      _friendships = friendships;
      if (myProfile != null) {
        _creatingProfile = false;
      }
      _syncFormFromProfile(myProfile);
      _loading = false;
    });
  }

  Future<void> _uploadProfileAvatar() async {
    if (_uploadingAvatar) return;
    setState(() => _uploadingAvatar = true);
    try {
      Uint8List? bytes;
      if (widget.photoPicker != null) {
        bytes = await widget.photoPicker!(ImageSource.gallery);
      } else {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          imageQuality: 85,
        );
        if (file != null) {
          bytes = await file.readAsBytes();
        }
      }
      if (bytes == null || !mounted) return;

      final result = await _uploadService.uploadBytes(
        bytes,
        folder: 'community_avatars',
      );
      if (!mounted) return;
      setState(() {
        _photoUrl = result.url;
        _photoKey = result.objectKey;
      });
    } on CommunityUploadException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      // Ignore cancellation.
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _updateQuickMood(HealthMood mood) async {
    final nextMood = _myProfile?.mood == mood ? null : mood;
    final updated = await widget.repository.updateMood(_myUid, nextMood);
    if (!mounted || updated == null) return;
    setState(() {
      _myProfile = updated;
      _selectedMood = updated.mood;
    });
    widget.onProfileChanged?.call();
  }

  Future<void> _saveMyProfile() async {
    if (_savingProfile) return;
    final l10n = context.l10n;
    final name = _displayNameController.text.trim();
    if (name.isEmpty) return;

    final profileTextCheck = ContentSafetyService.checkText(
      '$name ${_nicknameController.text} ${_bioController.text} ${_dailyFocusController.text} ${_customConditionController.text}',
    );
    if (!profileTextCheck.isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.safetyContentBlocked)),
      );
      return;
    }

    final musicUrl = _musicUrlController.text.trim();
    if (!MusicLinkHelper.isSupportedMusicUrl(musicUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commMusicInvalidUrl)),
      );
      return;
    }

    setState(() => _savingProfile = true);
    final now = DateTime.now();
    final profile = HealthCommunityProfile(
      uid: _myUid,
      displayName: name,
      nickname: HealthCommunityProfile.sanitizeNickname(_nicknameController.text),
      photoUrl: _photoUrl,
      photoKey: _photoKey,
      countryCode: _countryCode,
      city: _cityController.text.trim(),
      languageCode: _languageCode,
      healthGoals: _selectedGoals.isEmpty
          ? const [HealthGoalTag.healthyLiving]
          : _selectedGoals.toList(),
      chronicConditions: _selectedConditions.toList(),
      customChronicCondition: _customConditionController.text.trim(),
      showChronicConditions: _showChronicConditions,
      currentMusicUrl: musicUrl,
      currentMusicTitle: _musicTitleController.text.trim(),
      musicLikedBy: _myProfile?.musicLikedBy ?? const [],
      showSocials: _showSocials,
      instagram: _instagramController.text.trim(),
      twitterX: _twitterXController.text.trim(),
      tiktok: _tiktokController.text.trim(),
      facebook: _facebookController.text.trim(),
      snapchat: _snapchatController.text.trim(),
      isOnline: true,
      showOnlineStatus: _showOnlineStatus,
      lastActiveAt: now,
      isVerified: _myProfile?.isVerified ?? false,
      isSuspended: _myProfile?.isSuspended ?? false,
      bio: _bioController.text.trim(),
      dailyFocus: _dailyFocusController.text.trim(),
      mood: _selectedMood,
      hideRealName: _hideRealName,
      hidePhoto: _hidePhoto,
      showBio: true,
      discoverable: _discoverable,
      allowMessages: _allowMessages,
      requireMessageApproval: _requireMessageApproval,
      onlyFriendsCanMessage: _onlyFriendsCanMessage,
      likedBy: _myProfile?.likedBy ?? const [],
      updatedAt: now,
    );

    final saved = await widget.repository.saveMyProfile(profile);
    if (!mounted) return;
    setState(() {
      _myProfile = saved;
      _creatingProfile = false;
      _editingProfile = false;
      _savingProfile = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commProfileSaved)),
    );
    widget.onProfileChanged?.call();
  }

  Future<void> _leaveCommunity() async {
    final l10n = context.l10n;
    await widget.repository.leaveCommunity(_myUid);
    if (!mounted) return;
    setState(() {
      _myProfile = null;
      _creatingProfile = false;
      _editingProfile = false;
      _syncFormFromProfile(null);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commLeftCommunity)),
    );
    widget.onProfileChanged?.call();
  }

  Future<void> _openPreview() async {
    final profile = _myProfile;
    if (profile == null) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthProfileDetailScreen(
          profile: profile,
          myUid: _myUid,
          myDisplayName: profile.visibleName,
          myNickname: profile.nickname,
          myPhotoUrl: profile.visiblePhotoUrl,
          repository: widget.repository,
          uploadService: _uploadService,
          photoPicker: widget.photoPicker,
          urlLauncher: widget.urlLauncher,
        ),
      ),
    );
    await _loadProfileData();
  }

  Future<void> _openLikersSheet() async {
    final likers = await widget.repository.loadProfileLikers(_myUid);
    if (!mounted) return;
    await showProfileLikersSheet(context: context, likers: likers);
  }

  Future<void> _openListenersSheet() async {
    final listeners = await widget.repository.loadMusicListeners(_myUid);
    if (!mounted) return;
    setState(() => _myMusicListeners = listeners);
    await showMusicListenersSheet(
      context: context,
      listeners: listeners,
      musicLikedBy: _myProfile?.musicLikedBy ?? const [],
    );
  }

  Future<void> _openFriendsSheet() async {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final latest = await widget.repository.loadFriendships(_myUid);
    if (!mounted) return;
    setState(() => _friendships = latest);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final accepted = _friendships
                .where((f) => f.status == FriendshipStatus.accepted)
                .toList();
            final pendingIncoming = _friendships
                .where(
                  (f) =>
                      f.status == FriendshipStatus.pending &&
                      f.requesterId != _myUid,
                )
                .toList();
            final pendingOutgoing = _friendships
                .where(
                  (f) =>
                      f.status == FriendshipStatus.pending &&
                      f.requesterId == _myUid,
                )
                .toList();

            Future<void> reload() async {
              final refreshed =
                  await widget.repository.loadFriendships(_myUid);
              if (!mounted) return;
              setState(() => _friendships = refreshed);
              setSheetState(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          color: AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.commFriendsSheetTitle} (${accepted.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_friendships.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            l10n.commFriendsEmpty,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final req in pendingIncoming)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CommunityAvatar(
                                  initials: req.peerNameFor(_myUid).isNotEmpty
                                      ? req
                                          .peerNameFor(_myUid)
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  radius: 20,
                                ),
                                title: Text(
                                  req.peerNameFor(_myUid),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(l10n.commFriendPending),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: l10n.commRequestAccept,
                                      icon: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF16A34A),
                                      ),
                                      onPressed: () async {
                                        await widget.repository
                                            .respondFriendRequest(
                                          pairId: req.pairId,
                                          accept: true,
                                        );
                                        await reload();
                                      },
                                    ),
                                    IconButton(
                                      tooltip: l10n.commRequestDecline,
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        color: colorScheme.error,
                                      ),
                                      onPressed: () async {
                                        await widget.repository
                                            .respondFriendRequest(
                                          pairId: req.pairId,
                                          accept: false,
                                        );
                                        await reload();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            for (final friend in accepted)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CommunityAvatar(
                                  initials:
                                      friend.peerNameFor(_myUid).isNotEmpty
                                          ? friend
                                              .peerNameFor(_myUid)
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : '?',
                                  radius: 20,
                                ),
                                title: Text(
                                  friend.peerNameFor(_myUid),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(l10n.commFriendsConnected),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.person_remove_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () async {
                                    await widget.repository
                                        .removeFriend(friend.pairId);
                                    await reload();
                                  },
                                ),
                              ),
                            for (final out in pendingOutgoing)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CommunityAvatar(
                                  initials: out.peerNameFor(_myUid).isNotEmpty
                                      ? out
                                          .peerNameFor(_myUid)
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  radius: 20,
                                ),
                                title: Text(
                                  out.peerNameFor(_myUid),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(l10n.commFriendPending),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchExternalUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;
    if (widget.urlLauncher != null) {
      await widget.urlLauncher!(uri);
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 1. Not opted in yet -> Clean Social Onboarding Hero
    if (_myProfile == null && !_creatingProfile) {
      return _buildOptInHero(context);
    }

    // 2. Creating or Editing -> Structured Edit Form
    if (_creatingProfile || _editingProfile) {
      return _buildEditForm(context);
    }

    // 3. Opted in -> Sleek Social Formula Bank-style Profile Showcase!
    return _buildProfileShowcase(context, _myProfile!);
  }

  Widget _buildOptInHero(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      key: const Key('comm_my_profile_list'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        // Compact Account Header Card (Social Formula Bank Hero Style)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF103737), Color(0xFF0B2223)]
                  : const [AppTheme.primaryTeal, AppTheme.secondaryMint],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                child: Text(
                  widget.currentUser.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentUser.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    if (widget.currentUser.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.currentUser.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.diversity_1_rounded,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.commOptInTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.commOptInBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    key: const Key('comm_opt_in_button'),
                    onPressed: () => setState(() => _creatingProfile = true),
                    icon: const Icon(Icons.add_reaction_outlined),
                    label: Text(l10n.commOptInButton),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        BirthdayCelebrationCard(displayName: widget.currentUser.displayName),
        const DailyHealthTipCard(),
      ],
    );
  }

  Widget _buildProfileShowcase(
    BuildContext context,
    HealthCommunityProfile profile,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final acceptedFriendsCount = _friendships
        .where((f) => f.status == FriendshipStatus.accepted)
        .length;
    final pendingIncomingCount = _friendships
        .where(
          (f) =>
              f.status == FriendshipStatus.pending && f.requesterId != _myUid,
        )
        .length;

    return ListView(
      key: const Key('comm_my_profile_showcase_list'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      children: [
        // 1. Social Cover + Overlapping Avatar Card (Social Formula Bank Style!)
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 108,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? const [Color(0xFF0E3B3B), Color(0xFF0B6E6E)]
                            : const [
                                AppTheme.primaryTeal,
                                AppTheme.secondaryMint,
                              ],
                      ),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                l10n.commOnlineNow,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CommunityAvatar(
                        initials: profile.initials,
                        photoUrl: profile.visiblePhotoUrl,
                        radius: 40,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            profile.visibleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (profile.nickname.isNotEmpty) '@${profile.nickname}',
                        '${profile.country.flag} ${profile.city.isNotEmpty ? '${profile.city} • ' : ''}${profile.country.label}',
                      ].join('  •  '),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (profile.mood != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              profile.mood!.accentColor.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${profile.mood!.emoji} ${profile.mood!.localizedLabel(l10n)}',
                          style: TextStyle(
                            color: profile.mood!.accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    if (profile.bio.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        profile.bio.trim(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (profile.dailyFocus.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer
                              .withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                profile.dailyFocus.trim(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // 2. 3-Column Interactive Social Stats Strip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProfileStatItem(
                              key: const Key('comm_my_profile_likers_btn'),
                              icon: Icons.favorite_rounded,
                              iconColor: const Color(0xFFE11D48),
                              value: '${profile.likesCount}',
                              label: l10n.commProfileLikersTitle
                                  .split(' ')
                                  .last,
                              onTap: _openLikersSheet,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _ProfileStatItem(
                              key: const Key('comm_my_profile_friends_btn'),
                              icon: Icons.people_alt_rounded,
                              iconColor: AppTheme.primaryTeal,
                              value: pendingIncomingCount > 0
                                  ? '$acceptedFriendsCount (+$pendingIncomingCount)'
                                  : '$acceptedFriendsCount',
                              label: l10n.commFriendsStat,
                              onTap: _openFriendsSheet,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _ProfileStatItem(
                              key: const Key('comm_my_profile_listeners_btn'),
                              icon: Icons.headphones_rounded,
                              iconColor: const Color(0xFF7C3AED),
                              value: '${_myMusicListeners.length}',
                              label: l10n.commMusicListenersTitle
                                  .split(' ')
                                  .last,
                              onTap: _openListenersSheet,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Edit Profile + Preview Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('comm_edit_profile_toggle_btn'),
                            onPressed: () =>
                                setState(() => _editingProfile = true),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(l10n.commEditProfile),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('comm_preview_my_profile_btn'),
                            onPressed: _openPreview,
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: Text(l10n.commPreviewMyProfile),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Today's Mood 1-Tap Selector
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.commMoodSectionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mood in HealthMood.values)
                      ChoiceChip(
                        key: Key('comm_mood_chip_${mood.name}'),
                        label: Text(
                          '${mood.emoji} ${mood.localizedLabel(l10n)}',
                        ),
                        selected: profile.mood == mood,
                        selectedColor: mood.accentColor.withValues(alpha: 0.2),
                        onSelected: (_) => _updateQuickMood(mood),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 5. Chronic Conditions & Health Goals Showcase
        if (profile.hasAnyChronicCondition || profile.healthGoals.isNotEmpty)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile.hasAnyChronicCondition) ...[
                    Text(
                      l10n.commFieldChronicConditions,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final cond in profile.chronicConditions)
                          Chip(
                            avatar: Icon(
                              cond.icon,
                              size: 15,
                              color: cond.accentColor,
                            ),
                            label: Text(cond.localizedLabel(l10n)),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (profile.customChronicCondition.trim().isNotEmpty)
                          Chip(
                            label: Text(
                              '🩺 ${profile.customChronicCondition.trim()}',
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    l10n.commFieldGoals,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final goal in profile.healthGoals)
                        Chip(
                          avatar: Icon(
                            goal.icon,
                            size: 15,
                            color: goal.accentColor,
                          ),
                          label: Text(goal.localizedLabel(l10n)),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),

        // 6. Concentration Music Now-Playing Card
        if (profile.hasMusic) ...[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: CircleAvatar(
                backgroundColor: MusicLinkHelper.detectPlatformColor(
                  profile.currentMusicUrl,
                ).withValues(alpha: 0.14),
                child: Icon(
                  Icons.music_note_rounded,
                  color: MusicLinkHelper.detectPlatformColor(
                    profile.currentMusicUrl,
                  ),
                ),
              ),
              title: Text(
                profile.currentMusicTitle.trim().isNotEmpty
                    ? profile.currentMusicTitle.trim()
                    : l10n.commMusicSectionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${MusicLinkHelper.detectPlatformName(profile.currentMusicUrl)} • ❤️ ${profile.musicLikesCount}',
              ),
              trailing: FilledButton.tonalIcon(
                onPressed: () => _launchExternalUrl(profile.currentMusicUrl),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(l10n.commMusicListenAction),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 7. Social Media Links Card
        if (profile.allSocialHandles.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.commSocialsSectionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (!profile.showSocials)
                        Text(
                          l10n.commSocialsHiddenHint,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in profile.allSocialHandles.entries)
                        ActionChip(
                          label: Text('${entry.key}: @${entry.value}'),
                          onPressed: () {
                            final url = SocialLinksHelper.buildProfileUrl(
                              entry.key,
                              entry.value,
                            );
                            if (url != null) _launchExternalUrl(url);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        BirthdayCelebrationCard(displayName: profile.displayName),
        const DailyHealthTipCard(),
        const SizedBox(height: 14),
        TextButton.icon(
          key: const Key('comm_leave_community_button'),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          onPressed: _leaveCommunity,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: Text(l10n.commLeaveCommunity),
        ),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      key: const Key('comm_my_profile_list'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
      children: [
        if (_myProfile != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  l10n.commEditProfile,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _syncFormFromProfile(_myProfile);
                    setState(() => _editingProfile = false);
                  },
                  child: Text(l10n.commDoneEditing),
                ),
              ],
            ),
          ),

        // Avatar Upload & Quick Stats Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CommunityAvatar(
                  initials: widget.currentUser.initials,
                  photoUrl: _hidePhoto ? null : _photoUrl,
                  radius: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      FilledButton.tonalIcon(
                        key: const Key('comm_upload_avatar_button'),
                        onPressed:
                            _uploadingAvatar ? null : _uploadProfileAvatar,
                        icon: _uploadingAvatar
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.photo_camera_outlined, size: 18),
                        label: Text(l10n.commUploadPhoto),
                      ),
                      if (_photoUrl != null && _photoUrl!.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() {
                            _photoUrl = null;
                            _photoKey = null;
                          }),
                          child: Text(l10n.commRemovePhoto),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Identity Fields
        TextField(
          key: const Key('comm_profile_name_field'),
          controller: _displayNameController,
          decoration: InputDecoration(
            labelText: l10n.commFieldDisplayName,
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('comm_profile_nickname_field'),
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: l10n.commFieldNickname,
            prefixText: '@',
            prefixIcon: const Icon(Icons.alternate_email_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _countryCode,
                decoration: InputDecoration(
                  labelText: l10n.commFieldCountry,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: [
                  for (final c in CommunityCountryOption.all)
                    DropdownMenuItem(
                      value: c.code,
                      child: Text(
                        '${c.flag} ${c.label}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _countryCode = v);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _languageCode,
                decoration: InputDecoration(
                  labelText: l10n.commFieldLanguage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: [
                  for (final lang in LocaleController.supportedLanguages)
                    DropdownMenuItem(
                      value: lang.code,
                      child: Text(
                        lang.nativeName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _languageCode = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: l10n.commFieldCity,
            prefixIcon: const Icon(Icons.location_city_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),

        // Chronic Conditions multi-select
        Text(
          l10n.commFieldChronicConditions,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cond in ChronicCondition.values)
              FilterChip(
                key: Key('comm_profile_condition_${cond.name}'),
                avatar: Icon(cond.icon, size: 16, color: cond.accentColor),
                label: Text(cond.localizedLabel(l10n)),
                selected: _selectedConditions.contains(cond),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedConditions.add(cond);
                    } else {
                      _selectedConditions.remove(cond);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('comm_profile_custom_condition_field'),
          controller: _customConditionController,
          maxLength: 80,
          decoration: InputDecoration(
            labelText: l10n.commFieldCustomCondition,
            hintText: l10n.commFieldCustomConditionHint,
            prefixIcon: const Icon(Icons.medical_information_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),

        // Health Goals multi-select
        Text(
          l10n.commFieldGoals,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final goal in HealthGoalTag.values)
              FilterChip(
                key: Key('comm_profile_goal_${goal.name}'),
                avatar: Icon(goal.icon, size: 16, color: goal.accentColor),
                label: Text(goal.localizedLabel(l10n)),
                selected: _selectedGoals.contains(goal),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGoals.add(goal);
                    } else if (_selectedGoals.length > 1) {
                      _selectedGoals.remove(goal);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _dailyFocusController,
          maxLength: 120,
          decoration: InputDecoration(
            labelText: l10n.commFieldDailyFocus,
            prefixIcon: const Icon(Icons.wb_sunny_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('comm_profile_bio_field'),
          controller: _bioController,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            labelText: l10n.commFieldBio,
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.format_quote_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),

        // Concentration Music Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      size: 19,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.commMusicSectionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('comm_profile_music_title_field'),
                  controller: _musicTitleController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: l10n.commMusicTitleField,
                    prefixIcon: const Icon(Icons.queue_music_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('comm_profile_music_url_field'),
                  controller: _musicUrlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: l10n.commMusicUrlField,
                    hintText: 'https://www.youtube.com/watch?v=...',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Social Media Accounts & Show/Hide Toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  key: const Key('comm_toggle_show_socials'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.commToggleShowSocials,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  subtitle: !_showSocials
                      ? Text(
                          l10n.commSocialsHiddenHint,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        )
                      : null,
                  value: _showSocials,
                  onChanged: (v) => setState(() => _showSocials = v),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('comm_profile_instagram_field'),
                  controller: _instagramController,
                  decoration: InputDecoration(
                    labelText: 'Instagram',
                    prefixText: '@',
                    prefixIcon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFFE4405F),
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_x_field'),
                        controller: _twitterXController,
                        decoration: InputDecoration(
                          labelText: 'X (Twitter)',
                          prefixText: '@',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_tiktok_field'),
                        controller: _tiktokController,
                        decoration: InputDecoration(
                          labelText: 'TikTok',
                          prefixText: '@',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_facebook_field'),
                        controller: _facebookController,
                        decoration: InputDecoration(
                          labelText: 'Facebook',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_snapchat_field'),
                        controller: _snapchatController,
                        decoration: InputDecoration(
                          labelText: 'Snapchat',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Privacy & Messaging Controls
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Text(
                  l10n.commPrivacySection,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleDiscoverable),
                value: _discoverable,
                onChanged: (v) => setState(() => _discoverable = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleShowConditions),
                value: _showChronicConditions,
                onChanged: (v) => setState(() => _showChronicConditions = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleShowOnline),
                value: _showOnlineStatus,
                onChanged: (v) => setState(() => _showOnlineStatus = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleHideRealName),
                value: _hideRealName,
                onChanged: (v) => setState(() => _hideRealName = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleHidePhoto),
                value: _hidePhoto,
                onChanged: (v) => setState(() => _hidePhoto = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleAllowMessages),
                value: _allowMessages,
                onChanged: (v) => setState(() => _allowMessages = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleRequireApproval),
                value: _requireMessageApproval,
                onChanged: (v) => setState(() => _requireMessageApproval = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleOnlyFriendsMsg),
                value: _onlyFriendsCanMessage,
                onChanged: (v) => setState(() => _onlyFriendsCanMessage = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            key: const Key('comm_save_profile_button'),
            onPressed: _savingProfile ? null : _saveMyProfile,
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.commSaveProfile),
          ),
        ),
      ],
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  const _ProfileStatItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
