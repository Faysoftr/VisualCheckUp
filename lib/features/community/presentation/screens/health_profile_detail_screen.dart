import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/visual_announcement_effect_service.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/features/community/presentation/widgets/profile_wellness_cards.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';

typedef CommunityUrlLauncher = Future<void> Function(Uri uri);

/// Opens a modal bottom sheet listing everyone who listened to a profile's
/// concentration music, including play counts and music-like hearts.
Future<void> showMusicListenersSheet({
  required BuildContext context,
  required List<MusicListenerRecord> listeners,
  required List<String> musicLikedBy,
}) {
  final l10n = context.l10n;
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (ctx) {
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
                    Icons.headphones_rounded,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.commMusicListenersTitle} (${listeners.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (listeners.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      l10n.commMusicListenersEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: listeners.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final rec = listeners[index];
                      final likedMusic = musicLikedBy.contains(rec.userId);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CommunityAvatar(
                          initials: rec.initials,
                          photoUrl: rec.photoUrl,
                          radius: 20,
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                rec.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (likedMusic) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.favorite_rounded,
                                size: 15,
                                color: Color(0xFFE11D48),
                              ),
                            ],
                          ],
                        ),
                        subtitle: rec.nickname.isNotEmpty
                            ? Text('@${rec.nickname}')
                            : null,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer
                                .withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.commMusicPlayCountBadge(rec.listenCount),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Opens a modal bottom sheet showing members who liked this profile.
Future<void> showProfileLikersSheet({
  required BuildContext context,
  required List<HealthCommunityProfile> likers,
}) {
  final l10n = context.l10n;
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (ctx) {
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
                    Icons.favorite_rounded,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.commProfileLikersTitle} (${likers.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (likers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      l10n.commProfileLikersEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: likers.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final p = likers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CommunityAvatar(
                          initials: p.initials,
                          photoUrl: p.visiblePhotoUrl,
                          radius: 20,
                        ),
                        title: Text(
                          p.visibleName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: p.nickname.isNotEmpty
                            ? Text('@${p.nickname}')
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Detailed public view of a Health Community profile, with Profile Like
/// toggle, Concentration Music + Music Listeners ("Müziği Dinleyenler"),
/// Social Media Accounts with Show/Hide privacy, Direct Message, Report,
/// and Block actions.
class HealthProfileDetailScreen extends StatefulWidget {
  const HealthProfileDetailScreen({
    super.key,
    required this.profile,
    required this.myUid,
    required this.myDisplayName,
    this.myNickname = '',
    this.myPhotoUrl,
    this.myEmail,
    required this.repository,
    this.subscriptionRepository,
    this.uploadService,
    this.photoPicker,
    this.urlLauncher,
  });

  final HealthCommunityProfile profile;
  final String myUid;
  final String myDisplayName;
  final String myNickname;
  final String? myPhotoUrl;
  final String? myEmail;
  final HealthCommunityRepository repository;
  final SubscriptionRepository? subscriptionRepository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final CommunityUrlLauncher? urlLauncher;

  @override
  State<HealthProfileDetailScreen> createState() =>
      _HealthProfileDetailScreenState();
}

class _HealthProfileDetailScreenState extends State<HealthProfileDetailScreen> {
  late HealthCommunityProfile _profile;
  List<MusicListenerRecord> _listeners = const [];
  bool _liking = false;
  bool _likingMusic = false;
  bool _blocked = false;

  bool get _isOwnProfile => _profile.uid == widget.myUid;

  int get _totalMusicPlays =>
      _listeners.fold<int>(0, (sum, rec) => sum + rec.listenCount);

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _loadExtras();
  }

  @override
  void didUpdateWidget(covariant HealthProfileDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile ||
        oldWidget.myUid != widget.myUid) {
      _profile = widget.profile;
      _loadExtras();
    }
  }

  Future<void> _loadExtras() async {
    final blocks = await widget.repository.loadBlockedUsers(widget.myUid);
    final listeners = await widget.repository.loadMusicListeners(_profile.uid);
    if (!mounted) return;
    setState(() {
      _blocked = blocks.contains(_profile.uid);
      _listeners = listeners;
    });
  }

  Future<void> _launchExternal(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) return;
    if (widget.urlLauncher != null) {
      await widget.urlLauncher!(uri);
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    if (_liking || _isOwnProfile) return;
    setState(() => _liking = true);
    final updated = await widget.repository.toggleProfileLike(
      targetUid: _profile.uid,
      myUid: widget.myUid,
    );
    if (!mounted) return;
    setState(() {
      if (updated != null) _profile = updated;
      _liking = false;
    });
  }

  Future<void> _toggleMusicLike() async {
    if (_likingMusic) return;
    setState(() => _likingMusic = true);
    final updated = await widget.repository.toggleMusicLike(
      targetUid: _profile.uid,
      myUid: widget.myUid,
    );
    if (!mounted) return;
    setState(() {
      if (updated != null) _profile = updated;
      _likingMusic = false;
    });
  }

  Future<void> _listenToMusic() async {
    if (!_profile.hasMusic) return;
    await widget.repository.recordMusicListen(
      targetUid: _profile.uid,
      listenerUid: widget.myUid,
      listenerName: widget.myDisplayName,
      listenerNickname: widget.myNickname,
      listenerPhotoUrl: widget.myPhotoUrl,
      musicUrl: _profile.currentMusicUrl,
    );
    final listeners = await widget.repository.loadMusicListeners(_profile.uid);
    if (mounted) {
      setState(() => _listeners = listeners);
    }
    await _launchExternal(_profile.currentMusicUrl);
  }

  Future<void> _openListenersSheet() async {
    final listeners = await widget.repository.loadMusicListeners(_profile.uid);
    if (!mounted) return;
    setState(() => _listeners = listeners);
    await showMusicListenersSheet(
      context: context,
      listeners: listeners,
      musicLikedBy: _profile.musicLikedBy,
    );
  }

  Future<void> _openProfileLikersSheet() async {
    final likers = await widget.repository.loadProfileLikers(_profile.uid);
    if (!mounted) return;
    await showProfileLikersSheet(context: context, likers: likers);
  }

  Future<void> _toggleShowSocials(bool value) async {
    if (!_isOwnProfile) return;
    final updated = await widget.repository.setShowSocials(_profile.uid, value);
    if (!mounted) return;
    setState(() {
      _profile = updated ?? _profile.copyWith(showSocials: value);
    });
  }

  Future<void> _openChat() async {
    final blockedNow = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthChatScreen(
          myUid: widget.myUid,
          myDisplayName: widget.myDisplayName,
          myPhotoUrl: widget.myPhotoUrl,
          myEmail: widget.myEmail,
          peer: _profile,
          repository: widget.repository,
          subscriptionRepository: widget.subscriptionRepository,
          uploadService: widget.uploadService,
          photoPicker: widget.photoPicker,
        ),
      ),
    );
    if (blockedNow == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _toggleBlock() async {
    final l10n = context.l10n;
    if (_blocked) {
      await widget.repository.unblockUser(
        myUid: widget.myUid,
        targetUid: _profile.uid,
      );
      if (!mounted) return;
      setState(() => _blocked = false);
    } else {
      await widget.repository.blockUser(
        myUid: widget.myUid,
        targetUid: _profile.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commBlockedToast)),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLiked = _profile.isLikedBy(widget.myUid);
    final isMusicLiked = _profile.isMusicLikedBy(widget.myUid);
    final accent = _profile.healthGoals.first.accentColor;
    final langName =
        LocaleController.optionForCode(_profile.languageCode).nativeName;
    final socialHandles = _isOwnProfile
        ? _profile.allSocialHandles
        : _profile.visibleSocialHandles;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0C1A1B) : const Color(0xFFE7F5F3),
        surfaceTintColor: Colors.transparent,
        title: Text(_profile.visibleName),
        actions: [
          if (!_isOwnProfile)
            PopupMenuButton<String>(
              key: const Key('comm_profile_safety_menu'),
              onSelected: (value) async {
                if (value == 'report') {
                  await showCommunityReportDialog(
                    context: context,
                    repository: widget.repository,
                    reporterUid: widget.myUid,
                    targetType: 'profile',
                    targetId: _profile.uid,
                  );
                } else if (value == 'block') {
                  await _toggleBlock();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 19,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Text(l10n.commReportUser),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 19,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _blocked ? l10n.commUnblockUser : l10n.commBlockUser,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ProfileAmbientBackground(
        child: ListView(
          key: const Key('comm_profile_detail_list'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF133636), Color(0xFF0E2223)]
                    : const [AppTheme.primaryTeal, AppTheme.secondaryMint],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                CommunityAvatar(
                  initials: _profile.initials,
                  photoUrl: _profile.visiblePhotoUrl,
                  radius: 40,
                  accentColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _profile.visibleName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (_profile.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.lightBlueAccent,
                        size: 20,
                      ),
                    ],
                  ],
                ),
                if (!_profile.hideRealName && _profile.nickname.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${_profile.nickname}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    if (_profile.isVisibleOnline)
                      _HeaderPill(text: '🟢 ${l10n.commOnlineNow}'),
                    if (_profile.showBirthDate && _profile.age != null)
                      _HeaderPill(text: '🎂 ${_profile.age} Yaş'),
                    if (_profile.showGender &&
                        _profile.localizedGenderLabel != null)
                      _HeaderPill(text: _profile.localizedGenderLabel!),
                    if (_profile.mood != null)
                      _HeaderPill(
                        text:
                            '${_profile.mood!.emoji} ${_profile.mood!.localizedLabel(l10n)} hissediyor',
                      ),
                    _HeaderPill(
                      text:
                          '${_profile.country.flag} ${_profile.city.isNotEmpty ? '${_profile.city}, ' : ''}${_profile.country.label}',
                    ),
                    _HeaderPill(text: '🌐 $langName'),
                    InkWell(
                      key: const Key('comm_detail_likers_pill'),
                      onTap: _openProfileLikersSheet,
                      borderRadius: BorderRadius.circular(14),
                      child: _HeaderPill(
                        text: '❤️ ${l10n.commLikesCount(_profile.likesCount)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Celebratory Birthday Banner (Social Formul Bank style)
          if (_profile.isBirthdayToday)
            Container(
              key: const Key('profile_detail_birthday_banner'),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎂', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bugün ${_profile.visibleName}\'in Doğum Günü! 🎉',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Kutlama dileklerini ve sevgilerini ilet!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      VisualAnnouncementEffectService.showEffect(
                        context,
                        type: 'birthday',
                        shape: 'doğum günü',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${_profile.visibleName} için doğum günü tebriğin iletildi! 🎂✨',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE11D48),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.celebration_rounded, size: 16),
                    label: const Text(
                      'Kutla 🎉',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Primary Actions: Like & Send Message (other members)
          if (!_isOwnProfile) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      key: const Key('comm_detail_like_button'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isLiked
                            ? const Color(0xFFE11D48).withValues(alpha: 0.12)
                            : null,
                        foregroundColor: isLiked
                            ? const Color(0xFFE11D48)
                            : colorScheme.onSurface,
                        side: BorderSide(
                          color: isLiked
                              ? const Color(0xFFE11D48)
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      onPressed: _liking ? null : _toggleLike,
                      icon: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      label: Text(
                        isLiked ? l10n.commUnlikeAction : l10n.commLikeAction,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      key: const Key('comm_detail_message_button'),
                      onPressed: (_profile.allowMessages && !_blocked)
                          ? _openChat
                          : null,
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: Text(
                        l10n.commSendMessage,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!_profile.allowMessages) ...[
              const SizedBox(height: 8),
              Text(
                l10n.commMessagesDisabled,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),
          ],

          // Concentration & Calm Music Card + Music Likes + Listeners
          if (_profile.hasMusic || _isOwnProfile) ...[
            _buildConcentrationMusicCard(
              context: context,
              isMusicLiked: isMusicLiked,
            ),
            const SizedBox(height: 12),
          ],

          // Social Media Accounts Card (respects showSocials privacy toggle!)
          if ((_profile.showSocials && _profile.hasAnySocial) ||
              _isOwnProfile) ...[
            _buildSocialMediaCard(
              context: context,
              handles: socialHandles,
            ),
            const SizedBox(height: 12),
          ],

          // Chronic Conditions Section (when visible & non-empty)
          if (_profile.showChronicConditions &&
              _profile.hasAnyChronicCondition) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_information_outlined,
                          size: 18,
                          color: Color(0xFFC8553D),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.commFieldChronicConditions,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final cond in _profile.chronicConditions)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cond.accentColor.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: cond.accentColor.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cond.icon,
                                  size: 15,
                                  color: cond.accentColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cond.localizedLabel(l10n),
                                  style: TextStyle(
                                    color: cond.accentColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_profile.customChronicCondition.trim().isNotEmpty)
                          Chip(
                            avatar: const Icon(
                              Icons.medical_services_outlined,
                              size: 15,
                            ),
                            label: Text(_profile.customChronicCondition.trim()),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Health Goals Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 18, color: accent),
                      const SizedBox(width: 8),
                      Text(
                        l10n.commFieldGoals,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final goal in _profile.healthGoals)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: goal.accentColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: goal.accentColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                goal.icon,
                                size: 15,
                                color: goal.accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                goal.localizedLabel(l10n),
                                style: TextStyle(
                                  color: goal.accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Daily Wellness Focus
          if (_profile.dailyFocus.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                title: Text(
                  l10n.commFieldDailyFocus,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  _profile.dailyFocus.trim(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],

          // Bio / Health Journey
          if (_profile.showBio && _profile.bio.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.commFieldBio,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile.bio.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Motto Card (Public visibility)
          if (_profile.showMotto && _profile.motto.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            ProfileMottoCard(
              profile: _profile,
              isOwner: false,
            ),
          ],

          // Sobriety Showcase Card (Public visibility)
          if (_profile.showSobrietyOnProfile &&
              (_profile.smokeQuitAt != null || _profile.alcoholQuitAt != null)) ...[
            const SizedBox(height: 12),
            ProfileSobrietyShowcaseCard(
              profile: _profile,
              isOwner: false,
            ),
          ],

          // Step Counter Showcase Card (Public visibility)
          if (_profile.showStepsOnProfile &&
              (_profile.todayStepsCount > 0 ||
                  _profile.weekStepsCount > 0 ||
                  _profile.monthStepsCount > 0)) ...[
            const SizedBox(height: 12),
            ProfileStepCounterShowcaseCard(
              profile: _profile,
              isOwner: false,
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildConcentrationMusicCard({
    required BuildContext context,
    required bool isMusicLiked,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final musicAccent = _profile.hasMusic
        ? MusicLinkHelper.detectPlatformColor(_profile.currentMusicUrl)
        : const Color(0xFFE11D48);
    final platformName = _profile.hasMusic
        ? MusicLinkHelper.detectPlatformName(_profile.currentMusicUrl)
        : '';

    return Card(
      key: const Key('comm_detail_music_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note_rounded, size: 20, color: musicAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.commMusicSectionTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  key: const Key('comm_music_listeners_button'),
                  onPressed: _openListenersSheet,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    backgroundColor: musicAccent.withValues(alpha: 0.12),
                    foregroundColor: musicAccent,
                  ),
                  icon: const Icon(Icons.headphones_rounded, size: 15),
                  label: Text(
                    '${l10n.commMusicListenersTitle} (${_listeners.length})',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!_profile.hasMusic)
              Text(
                l10n.commMusicEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: musicAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: musicAccent.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: musicAccent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: musicAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile.currentMusicTitle.trim().isNotEmpty
                                ? _profile.currentMusicTitle.trim()
                                : platformName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$platformName • ${_profile.currentMusicUrl.trim()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      key: const Key('comm_music_listen_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: musicAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: _listenToMusic,
                      icon: const Icon(Icons.headphones_rounded, size: 16),
                      label: Text(l10n.commMusicListenAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    onTap: _openListenersSheet,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '🎧 ${l10n.commMusicUniqueListeners(_listeners.length)}',
                        style: const TextStyle(
                          color: Color(0xFFE11D48),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _openListenersSheet,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '▶ ${l10n.commMusicTotalPlays(_totalMusicPlays)}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('comm_music_like_button'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: isMusicLiked
                          ? const Color(0xFFE11D48)
                          : colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _likingMusic ? null : _toggleMusicLike,
                    icon: Icon(
                      isMusicLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                    ),
                    label: Text(
                      '${_profile.musicLikesCount}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaCard({
    required BuildContext context,
    required Map<String, String> handles,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: const Key('comm_detail_socials_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.share_rounded,
                  size: 18,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.commSocialsSectionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (_isOwnProfile && !_profile.showSocials)
                        Text(
                          l10n.commSocialsHiddenHint,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isOwnProfile)
                  Switch(
                    key: const Key('comm_detail_toggle_socials'),
                    value: _profile.showSocials,
                    onChanged: _toggleShowSocials,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (handles.isEmpty)
              Text(
                l10n.commSocialsEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in handles.entries)
                    _buildSocialChip(context, entry.key, entry.value),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialChip(
    BuildContext context,
    String platform,
    String handle,
  ) {
    final (label, icon, color) = switch (platform) {
      'instagram' => (
          'Instagram',
          Icons.camera_alt_outlined,
          const Color(0xFFE4405F),
        ),
      'x' => ('X', Icons.alternate_email_rounded, const Color(0xFF0F172A)),
      'tiktok' => ('TikTok', Icons.music_video_rounded, const Color(0xFF000000)),
      'facebook' => ('Facebook', Icons.facebook_rounded, const Color(0xFF1877F2)),
      'snapchat' => (
          'Snapchat',
          Icons.chat_bubble_outline_rounded,
          const Color(0xFFD97706),
        ),
      _ => (platform, Icons.link_rounded, AppTheme.primaryTeal),
    };

    final cleanDisplay =
        handle.startsWith('http') ? label : '@${handle.replaceFirst('@', '')}';

    return ActionChip(
      key: Key('comm_social_chip_$platform'),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        '$label • $cleanDisplay',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.10),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      onPressed: () {
        final url = SocialLinksHelper.buildProfileUrl(platform, handle);
        if (url != null) _launchExternal(url);
      },
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
