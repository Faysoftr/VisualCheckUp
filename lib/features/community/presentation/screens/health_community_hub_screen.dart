import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';

/// Main Global Health Community hub for VisualCheckUp.
///
/// 3 tabs:
/// 1. Discover — worldwide health buddies filterable by Health Goal, Country,
///    and search query, with live Profile Like buttons.
/// 2. Messages — 1-on-1 conversations and Message Requests with unread counts,
///    mute, and hide controls.
/// 3. My Profile — opt-in health profile editor with R2 avatar upload, health
///    goal tags, wellness motto, and full privacy & messaging toggles.
class HealthCommunityHubScreen extends StatefulWidget {
  const HealthCommunityHubScreen({
    super.key,
    required this.currentUser,
    required this.repository,
    this.uploadService,
    this.photoPicker,
    this.initialTabIndex = 0,
  });

  final AuthUser currentUser;
  final HealthCommunityRepository repository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final int initialTabIndex;

  @override
  State<HealthCommunityHubScreen> createState() =>
      _HealthCommunityHubScreenState();
}

class _HealthCommunityHubScreenState extends State<HealthCommunityHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CommunityImageUploadService _uploadService;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dailyFocusController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _loading = true;
  bool _savingProfile = false;
  bool _uploadingAvatar = false;

  HealthCommunityProfile? _myProfile;
  List<HealthCommunityProfile> _discoverList = const [];
  List<CommunityConversation> _conversations = const [];

  HealthGoalTag? _goalFilter;
  String _countryFilter = 'ALL';

  // Editable form state for My Profile
  bool _creatingProfile = false;
  String? _photoUrl;
  String? _photoKey;
  String _countryCode = 'TR';
  String _languageCode = 'tr';
  Set<HealthGoalTag> _selectedGoals = {HealthGoalTag.healthyLiving};
  bool _discoverable = true;
  bool _hideRealName = false;
  bool _hidePhoto = false;
  bool _allowMessages = true;
  bool _requireMessageApproval = true;

  String get _myUid => widget.currentUser.id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _uploadService =
        widget.uploadService ?? R2CommunityImageUploadService.instance;
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _displayNameController.dispose();
    _nicknameController.dispose();
    _cityController.dispose();
    _dailyFocusController.dispose();
    _bioController.dispose();
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
      _photoUrl = null;
      _photoKey = null;
      _countryCode = 'TR';
      _languageCode = 'tr';
      _selectedGoals = {HealthGoalTag.healthyLiving};
      _discoverable = true;
      _hideRealName = false;
      _hidePhoto = false;
      _allowMessages = true;
      _requireMessageApproval = true;
      return;
    }
    _displayNameController.text = profile.displayName;
    _nicknameController.text = profile.nickname;
    _cityController.text = profile.city;
    _dailyFocusController.text = profile.dailyFocus;
    _bioController.text = profile.bio;
    _photoUrl = profile.photoUrl;
    _photoKey = profile.photoKey;
    _countryCode = profile.countryCode;
    _languageCode = profile.languageCode;
    _selectedGoals = Set<HealthGoalTag>.from(profile.healthGoals);
    _discoverable = profile.discoverable;
    _hideRealName = profile.hideRealName;
    _hidePhoto = profile.hidePhoto;
    _allowMessages = profile.allowMessages;
    _requireMessageApproval = profile.requireMessageApproval;
  }

  Future<void> _loadAll() async {
    final myProfile = await widget.repository.loadMyProfile(_myUid);
    final discover = await widget.repository.discoverProfiles(
      myUid: _myUid,
      goalFilter: _goalFilter,
      countryCodeFilter: _countryFilter,
      searchQuery: _searchController.text,
    );
    final convos = await widget.repository.loadConversations(_myUid);
    if (!mounted) return;
    setState(() {
      _myProfile = myProfile;
      if (myProfile != null) {
        _creatingProfile = false;
      }
      _syncFormFromProfile(myProfile);
      _discoverList = discover;
      _conversations = convos;
      _loading = false;
    });
  }

  Future<void> _refreshDiscover() async {
    final discover = await widget.repository.discoverProfiles(
      myUid: _myUid,
      goalFilter: _goalFilter,
      countryCodeFilter: _countryFilter,
      searchQuery: _searchController.text,
    );
    if (!mounted) return;
    setState(() => _discoverList = discover);
  }

  Future<void> _toggleQuickLike(HealthCommunityProfile target) async {
    final updated = await widget.repository.toggleProfileLike(
      targetUid: target.uid,
      myUid: _myUid,
    );
    if (updated == null || !mounted) return;
    setState(() {
      _discoverList = _discoverList
          .map((p) => p.uid == updated.uid ? updated : p)
          .toList();
    });
  }

  Future<void> _openProfileDetail(HealthCommunityProfile target) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthProfileDetailScreen(
          profile: target,
          myUid: _myUid,
          myDisplayName: _myProfile?.visibleName ?? widget.currentUser.displayName,
          myPhotoUrl: _myProfile?.visiblePhotoUrl,
          repository: widget.repository,
          uploadService: _uploadService,
          photoPicker: widget.photoPicker,
        ),
      ),
    );
    await _loadAll();
  }

  Future<void> _openConversation(CommunityConversation convo) async {
    final peerId = convo.peerIdFor(_myUid);
    final peerProfile = await widget.repository.getProfile(peerId) ??
        HealthCommunityProfile(
          uid: peerId,
          displayName: convo.peerNameFor(_myUid),
          photoUrl: convo.peerPhotoFor(_myUid),
          updatedAt: convo.lastMessageAt,
        );
    if (!mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthChatScreen(
          myUid: _myUid,
          myDisplayName: _myProfile?.visibleName ?? widget.currentUser.displayName,
          myPhotoUrl: _myProfile?.visiblePhotoUrl,
          peer: peerProfile,
          repository: widget.repository,
          uploadService: _uploadService,
          photoPicker: widget.photoPicker,
        ),
      ),
    );
    await _loadAll();
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

  Future<void> _saveMyProfile() async {
    if (_savingProfile) return;
    final l10n = context.l10n;
    final name = _displayNameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _savingProfile = true);
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
      bio: _bioController.text.trim(),
      dailyFocus: _dailyFocusController.text.trim(),
      hideRealName: _hideRealName,
      hidePhoto: _hidePhoto,
      showBio: true,
      discoverable: _discoverable,
      allowMessages: _allowMessages,
      requireMessageApproval: _requireMessageApproval,
      likedBy: _myProfile?.likedBy ?? const [],
      updatedAt: DateTime.now(),
    );

    final saved = await widget.repository.saveMyProfile(profile);
    if (!mounted) return;
    setState(() {
      _myProfile = saved;
      _creatingProfile = false;
      _savingProfile = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commProfileSaved)),
    );
  }

  Future<void> _leaveCommunity() async {
    final l10n = context.l10n;
    await widget.repository.leaveCommunity(_myUid);
    if (!mounted) return;
    setState(() {
      _myProfile = null;
      _creatingProfile = false;
      _syncFormFromProfile(null);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commLeftCommunity)),
    );
  }

  int get _unreadCount => _conversations
      .where((c) => !c.isMutedFor(_myUid) && c.isUnreadFor(_myUid))
      .length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.commMenuTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.public_rounded, size: 19),
              text: l10n.commTabDiscover,
            ),
            Tab(
              icon: const Icon(Icons.forum_outlined, size: 19),
              text: _unreadCount > 0
                  ? '${l10n.commTabMessages} ($_unreadCount)'
                  : l10n.commTabMessages,
            ),
            Tab(
              icon: const Icon(Icons.person_outline_rounded, size: 19),
              text: l10n.commTabMyProfile,
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDiscoverTab(context),
                _buildMessagesTab(context),
                _buildMyProfileTab(context),
              ],
            ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Privacy & Peer-Support Safety Notice
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: colorScheme.primaryContainer.withValues(alpha: 0.38),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 17,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.commSafetyBanner,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search + Country Filter
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('comm_discover_search_field'),
                  controller: _searchController,
                  onChanged: (_) => _refreshDiscover(),
                  decoration: InputDecoration(
                    hintText: l10n.commSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButton<String>(
                    key: const Key('comm_country_filter_dropdown'),
                    value: _countryFilter,
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: 'ALL',
                        child: Text('🌍 ${l10n.commFilterAllCountries}'),
                      ),
                      for (final c in CommunityCountryOption.all)
                        if (c.code != 'GLOBAL')
                          DropdownMenuItem(
                            value: c.code,
                            child: Text('${c.flag} ${c.code}'),
                          ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _countryFilter = v);
                      _refreshDiscover();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Health Goal Filter Chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l10n.commFilterAllGoals),
                  selected: _goalFilter == null,
                  onSelected: (_) {
                    setState(() => _goalFilter = null);
                    _refreshDiscover();
                  },
                ),
              ),
              for (final goal in HealthGoalTag.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: Key('comm_goal_filter_${goal.name}'),
                    avatar: Icon(
                      goal.icon,
                      size: 16,
                      color: _goalFilter == goal
                          ? Colors.white
                          : goal.accentColor,
                    ),
                    label: Text(goal.localizedLabel(l10n)),
                    selected: _goalFilter == goal,
                    selectedColor: goal.accentColor,
                    labelStyle: TextStyle(
                      color: _goalFilter == goal ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(
                        () => _goalFilter = _goalFilter == goal ? null : goal,
                      );
                      _refreshDiscover();
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Discovered Health Profiles List
        Expanded(
          child: _discoverList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      l10n.commEmptyDiscover,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                  itemCount: _discoverList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final profile = _discoverList[index];
                    final isLiked = profile.isLikedBy(_myUid);
                    final accent = profile.healthGoals.first.accentColor;

                    return Card(
                      child: InkWell(
                        key: Key('comm_profile_card_${profile.uid}'),
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _openProfileDetail(profile),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CommunityAvatar(
                                    initials: profile.initials,
                                    photoUrl: profile.visiblePhotoUrl,
                                    radius: 25,
                                    accentColor: accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.visibleName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${profile.country.flag} ${profile.city.isNotEmpty ? '${profile.city} • ' : ''}${profile.country.label}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quick Like button
                                  TextButton.icon(
                                    key: Key('comm_like_btn_${profile.uid}'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: isLiked
                                          ? const Color(0xFFE11D48)
                                          : colorScheme.onSurfaceVariant,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                    ),
                                    onPressed: () => _toggleQuickLike(profile),
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 20,
                                    ),
                                    label: Text(
                                      '${profile.likesCount}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (profile.showBio &&
                                  profile.bio.trim().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  profile.bio.trim(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.35,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final goal in profile.healthGoals)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: goal.accentColor
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            goal.icon,
                                            size: 13,
                                            color: goal.accentColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            goal.localizedLabel(l10n),
                                            style: TextStyle(
                                              color: goal.accentColor,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_chat_unread_outlined,
                size: 56,
                color: colorScheme.primary.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.commInboxEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _conversations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final convo = _conversations[index];
        final peerName = convo.peerNameFor(_myUid);
        final peerPhoto = convo.peerPhotoFor(_myUid);
        final isUnread = convo.isUnreadFor(_myUid);
        final isPending = convo.isPendingIncomingFor(_myUid);
        final isMuted = convo.isMutedFor(_myUid);
        final timeStr = DateFormat('HH:mm').format(convo.lastMessageAt);
        final initials = peerName.trim().isNotEmpty
            ? peerName.trim().substring(0, 1).toUpperCase()
            : 'M';

        return Card(
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () => _openConversation(convo),
            leading: CommunityAvatar(
              initials: initials,
              photoUrl: peerPhoto,
              radius: 23,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    peerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.commMessageRequestBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (isMuted) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
            subtitle: Text(
              convo.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyProfileTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Opt-in onboarding state (default OFF for privacy!)
    if (_myProfile == null && !_creatingProfile) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.diversity_1_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.commOptInTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.commOptInBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
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
        ),
      );
    }

    return ListView(
      key: const Key('comm_my_profile_list'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
      children: [
        // Avatar Upload & Likes Summary
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_myProfile != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '❤️ ${l10n.commLikesCount(_myProfile!.likesCount)}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: const Color(0xFFE11D48),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      Wrap(
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
                                : const Icon(Icons.photo_camera_outlined,
                                    size: 18),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Profile Details Form
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
        if (_myProfile != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            key: const Key('comm_leave_community_button'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            onPressed: _leaveCommunity,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(l10n.commLeaveCommunity),
          ),
        ],
      ],
    );
  }
}
